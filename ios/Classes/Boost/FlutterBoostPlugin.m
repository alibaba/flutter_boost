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
#import "BoostMessageChannel.h"
#import "FLBCollectionHelper.h"

#define NSNull2Nil(_x_) if([_x_ isKindOfClass: NSNull.class]) _x_ = nil;

@interface FlutterBoostPlugin()
@end

@implementation FlutterBoostPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_boost"
                                     binaryMessenger:[registrar messenger]];
    FlutterBoostPlugin* instance = [self.class sharedInstance];
    instance.methodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if([@"__event__" isEqual: call.method]){
        [BoostMessageChannel handleMethodCall:call result:result];
    }else if([@"closePage" isEqualToString:call.method]){
        NSDictionary *args = [FLBCollectionHelper deepCopyNSDictionary:call.arguments
                                                                filter:^bool(id  _Nonnull value) {
                                                    return ![value isKindOfClass:NSNull.class];
        }];
        NSDictionary *exts = args[@"exts"];
        NSString *uid = args[@"uniqueId"];
        NSDictionary *resultData = args[@"result"];
        NSNull2Nil(exts);
        NSNull2Nil(resultData);
        NSNull2Nil(uid);
        [[FlutterBoostPlugin sharedInstance].application close:uid
                                                        result:resultData
                                                          exts:exts
                                                    completion:^(BOOL r){
                                                        result(@(r));
                                                    }];
    }else if([@"onShownContainerChanged" isEqualToString:call.method]){
        NSString *newName = call.arguments[@"newName"];
        if(newName){
            [NSNotificationCenter.defaultCenter postNotificationName:@"flutter_boost_container_showed"
                                                              object:newName];
        }
    }else if([@"openPage" isEqualToString:call.method]){
        NSDictionary *args = [FLBCollectionHelper deepCopyNSDictionary:call.arguments
                                                                filter:^bool(id  _Nonnull value) {
                                                                    return ![value isKindOfClass:NSNull.class];
                                                                }];
        NSString *url = args[@"url"];
        NSDictionary *urlParams = args[@"urlParams"];
        NSDictionary *exts = args[@"exts"];
        NSNull2Nil(url);
        NSNull2Nil(urlParams);
        NSNull2Nil(exts);
        [[FlutterBoostPlugin sharedInstance].application open:url
                                                    urlParams:urlParams
                                                         exts:exts
                                                        reult:result
                                                   completion:^(BOOL r) {}];
    }else if([@"pageOnStart" isEqualToString:call.method]){
        NSMutableDictionary *pageInfo = [NSMutableDictionary new];
        pageInfo[@"name"] =[FlutterBoostPlugin sharedInstance].fPagename;
        pageInfo[@"params"] = [FlutterBoostPlugin sharedInstance].fParams;
        pageInfo[@"uniqueId"] = [FlutterBoostPlugin sharedInstance].fPageId;
        if(result) result(pageInfo);
    }else{
        result(FlutterMethodNotImplemented);
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


- (id<FLBFlutterApplicationInterface>)application
{
    return _application;
}


- (id<FLBAbstractFactory>)factory
{
    return _factory;
}

- (void)startFlutterWithPlatform:(id<FLBPlatform>)platform
                         onStart:(void (^)(id<FlutterBinaryMessenger,
                                             FlutterTextureRegistry,
                                           FlutterPluginRegistry> engine))callback;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_factory = FLBFactory.new;
        self->_application = [self->_factory createApplication:platform];
        [self->_application startFlutterWithPlatform:platform
                                       onStart:callback];
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
    [BoostMessageChannel sendEvent:eventName
                         arguments:arguments];
}

- (FLBVoidCallback)addEventListener:(FLBEventListener)listner
                            forName:(NSString *)name
{
   return [BoostMessageChannel addEventListener:listner
                                        forName:name];
}

@end
