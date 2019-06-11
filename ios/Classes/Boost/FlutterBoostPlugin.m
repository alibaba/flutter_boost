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
#import "FLBResultMediator.h"
#import "FlutterBoostPlugin_private.h"

@implementation FlutterBoostPlugin

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
        _resultMediator = [FLBResultMediator new];
    }
    
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_boost"
            binaryMessenger:[registrar messenger]];
  FlutterBoostPlugin* instance = [self.class sharedInstance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}


- (void)startFlutterWithPlatform:(id<FLB2Platform>)platform
                         onStart:(void (^)(id<FlutterBinaryMessenger,
                                             FlutterTextureRegistry,
                                           FlutterPluginRegistry> engine))callback;
{
    //TODO:
    [self.application startFlutterWithPlatform:platform
                                        onStart:callback];
}

- (BOOL)isRunning
{
    return [self.application isRunning];
}

- (FlutterViewController *)currentViewController
{
    return [self.application flutterViewController];
}

- (void)openPage:(NSString *)name
          params:(NSDictionary *)params animated:(BOOL)animated
      completion:(void (^)(BOOL))completion
   resultHandler:(void (^)(NSString *, NSDictionary *))resultHandler
{
    static int kRid = 0;
    NSString *resultId = [NSString stringWithFormat:@"result_id_%d",kRid++];
    [_resultMediator setResultHandler:^(NSString * _Nonnull resultId, NSDictionary * _Nonnull resultData) {
        if(resultHandler) resultHandler(resultId,resultData);
    } forKey:resultId];
}

- (void)onResultForKey:(NSString *)vcId resultData:(NSDictionary *)resultData params:(NSDictionary *)params
{
    [_resultMediator onResultForKey:vcId resultData:resultData params:params];
}

- (void)setResultHandler:(void (^)(NSString *, NSDictionary *))handler forKey:(NSString *)vcid
{
    [_resultMediator setResultHandler:handler forKey:vcid];
}

- (void)removeHandlerForKey:(NSString *)vcid
{
    [_resultMediator removeHandlerForKey:vcid];
}

@end
