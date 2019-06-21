/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 Alibaba Group
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "FlutterBoostPlugin.h"
#import "FlutterBoostPlugin_private.h"
#import "FLBFactory.h"
#import "FLB2Factory.h"

#import "FLBMessageDispather.h"
#import "FLBMessageImp.h"
#import "NavigationService_closePage.h"
#import "NavigationService_openPage.h"
#import "NavigationService_pageOnStart.h"
#import "NavigationService_onShownContainerChanged.h"
#import "NavigationService_onFlutterPageResult.h"

@interface FlutterBoostPlugin()
@property (nonatomic,strong) FLBMessageDispather *dispatcher;
@end

@implementation FlutterBoostPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_boost"
                                     binaryMessenger:[registrar messenger]];
    FlutterBoostPlugin* instance = [self.class sharedInstance];
    [instance registerHandlers];
    instance.methodChannel = channel;
    instance.broadcastor = [[FLBBroadcastor alloc] initWithMethodChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if([@"__event__" isEqual: call.method]){
        [_broadcastor handleMethodCall:call result:result];
    }else{
        FLBMessageImp *msg = FLBMessageImp.new;
        msg.name = call.method;
        msg.params = call.arguments;
        if(![self.dispatcher dispatch:msg result:result]){
             result(FlutterMethodNotImplemented);
        }
    }
}

- (void)registerHandlers
{
    NSArray *handlers = @[
                        NavigationService_openPage.class,
                        NavigationService_closePage.class,
                        NavigationService_pageOnStart.class,
                        NavigationService_onShownContainerChanged.class,
                        NavigationService_onFlutterPageResult.class
                          ];
    
    for(Class cls in handlers){
        [self.dispatcher registerHandler:cls.new];
    }
}

+ (instancetype)sharedInstance
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self.class new];
    });
    
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _dispatcher = FLBMessageDispather.new;
    }
    
    return self;
}

- (id<FLBFlutterApplicationInterface>)application
{
    return _application;
}


- (id<FLBAbstractFactory>)factory
{
    return _factory;
}

- (void)startFlutterWithPlatform:(id<FLB2Platform>)platform
                         onStart:(void (^)(id<FlutterBinaryMessenger,
                                             FlutterTextureRegistry,
                                           FlutterPluginRegistry> engine))callback;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if([platform respondsToSelector:@selector(userBoost2)] && platform.userBoost2){
            _factory = FLB2Factory.new;
        }else{
            _factory = FLBFactory.new;
        }
        
        _application = [_factory createApplication:platform];
        [_application startFlutterWithPlatform:platform onStart:callback];
    });
}

- (BOOL)isRunning
{
    return [self.application isRunning];
}


- (FlutterViewController *)currentViewController
{
    return [self.application flutterViewController];
}


#pragma mark - broadcast event to/from flutter
- (void)sendEvent:(NSString *)eventName
        arguments:(NSDictionary *)arguments
{
    [_broadcastor sendEvent:eventName
                  arguments:arguments];
}

- (FLBVoidCallback)addEventListener:(FLBEventListener)listner
                            forName:(NSString *)name
{
   return [_broadcastor addEventListener:listner
                           forName:name];
}

@end
