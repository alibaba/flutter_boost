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
#import "BoostMessageChannel.h"
#import "FlutterBoostPlugin_private.h"

@implementation BoostMessageChannel

+ (NSMutableDictionary *)lists{
    static NSMutableDictionary *_list = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _list = [NSMutableDictionary new];
    });
    return _list;
}
 
 + (FlutterMethodChannel *)methodChannel
 {
     return FlutterBoostPlugin.sharedInstance.methodChannel;
 }

+ (void)sendEvent:(NSString *)eventName
        arguments:(NSDictionary *)arguments
{
    if(!eventName) return;
    NSMutableDictionary *msg = [NSMutableDictionary new];
    msg[@"name"] = eventName;
    msg[@"arguments"] = arguments;
    [self.methodChannel invokeMethod:@"__event__"
                 arguments:msg
                    result:^(id r){}];
}

+ (FLBVoidCallback)addEventListener:(FLBEventListener)listner
                            forName:(NSString *)name
{
    if(!name || !listner) return ^{};
    
    NSMutableArray *list = [self lists][name];
    if(!list){
        list = [NSMutableArray new];
        [self lists][name] = list;
    }
    [list addObject:listner];
    return ^{
        [list removeObject:listner];
    };
}

+ (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result
{
    if([call.method isEqual:@"__event__"]){
        NSString *name = call.arguments[@"name"];
        NSDictionary *arguments = call.arguments[@"arguments"];
        if(name){
            NSMutableArray *list = [self lists][name];
            if(list){
                for(FLBEventListener l in list){
                    l(name,arguments);
                }
            }
        }
    }
}

 + (void)onNativePageResult:(void (^)(NSNumber *))result uniqueId:(NSString *)uniqueId key:(NSString *)key resultData:(NSDictionary *)resultData params:(NSDictionary *)params
 {
     NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
     if(uniqueId) tmp[@"uniqueId"] = uniqueId;
     if(key) tmp[@"key"] = key;
     if(resultData) tmp[@"resultData"] = resultData;
     if(params) tmp[@"params"] = params;
     [self.methodChannel invokeMethod:@"onNativePageResult" arguments:tmp result:^(id tTesult) {
         if (result) {
             result(tTesult);
         }
     }];
 }
 
 + (void)didShowPageContainer:(void (^)(NSNumber *))result pageName:(NSString *)pageName params:(NSDictionary *)params uniqueId:(NSString *)uniqueId
 {
     if ([pageName isEqualToString:kIgnoreMessageWithName]) {
         return;
     }
     
     NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
     if(pageName) tmp[@"pageName"] = pageName;
     if(params) tmp[@"params"] = params;
     if(uniqueId) tmp[@"uniqueId"] = uniqueId;
     [self.methodChannel invokeMethod:@"didShowPageContainer" arguments:tmp result:^(id tTesult) {
         if (result) {
             result(tTesult);
         }
     }];
 }
 
 + (void)willShowPageContainer:(void (^)(NSNumber *))result pageName:(NSString *)pageName params:(NSDictionary *)params uniqueId:(NSString *)uniqueId
 {
     if ([pageName isEqualToString:kIgnoreMessageWithName]) {
         return;
     }
     
     NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
     if(pageName) tmp[@"pageName"] = pageName;
     if(params) tmp[@"params"] = params;
     if(uniqueId) tmp[@"uniqueId"] = uniqueId;
     [self.methodChannel invokeMethod:@"willShowPageContainer" arguments:tmp result:^(id tTesult) {
         if (result) {
             result(tTesult);
         }
     }];
 }
 
 + (void)willDisappearPageContainer:(void (^)(NSNumber *))result pageName:(NSString *)pageName params:(NSDictionary *)params uniqueId:(NSString *)uniqueId
 {
     if ([pageName isEqualToString:kIgnoreMessageWithName]) {
         return;
     }
     
     NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
     if(pageName) tmp[@"pageName"] = pageName;
     if(params) tmp[@"params"] = params;
     if(uniqueId) tmp[@"uniqueId"] = uniqueId;
     [self.methodChannel invokeMethod:@"willDisappearPageContainer" arguments:tmp result:^(id tTesult) {
         if (result) {
             result(tTesult);
         }
     }];
 }
 
 + (void)didDisappearPageContainer:(void (^)(NSNumber *))result pageName:(NSString *)pageName params:(NSDictionary *)params uniqueId:(NSString *)uniqueId
 {
     if ([pageName isEqualToString:kIgnoreMessageWithName]) {
         return;
     }
     
     NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
     if(pageName) tmp[@"pageName"] = pageName;
     if(params) tmp[@"params"] = params;
     if(uniqueId) tmp[@"uniqueId"] = uniqueId;
     [self.methodChannel invokeMethod:@"didDisappearPageContainer" arguments:tmp result:^(id tTesult) {
         if (result) {
             result(tTesult);
         }
     }];
 }
 
 + (void)didInitPageContainer:(void (^)(NSNumber *))result pageName:(NSString *)pageName params:(NSDictionary *)params uniqueId:(NSString *)uniqueId
 {
     if ([pageName isEqualToString:kIgnoreMessageWithName]) {
         return;
     }
     
     NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
     if(pageName) tmp[@"pageName"] = pageName;
     if(params) tmp[@"params"] = params;
     if(uniqueId) tmp[@"uniqueId"] = uniqueId;
     [self.methodChannel invokeMethod:@"didInitPageContainer" arguments:tmp result:^(id tTesult) {
         if (result) {
             result(tTesult);
         }
     }];
     
     [FlutterBoostPlugin.sharedInstance.application didInitPageContainer:pageName
                                                                  params:params
                                                                uniqueId:uniqueId];
 }
 
 + (void)willDeallocPageContainer:(void (^)(NSNumber *))result pageName:(NSString *)pageName params:(NSDictionary *)params uniqueId:(NSString *)uniqueId
 {
     if ([pageName isEqualToString:kIgnoreMessageWithName]) {
         return;
     }
     
     NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
     if(pageName) tmp[@"pageName"] = pageName;
     if(params) tmp[@"params"] = params;
     if(uniqueId) tmp[@"uniqueId"] = uniqueId;
     [self.methodChannel invokeMethod:@"willDeallocPageContainer" arguments:tmp result:^(id tTesult) {
         if (result) {
             result(tTesult);
         }
     }];
     
     [FlutterBoostPlugin.sharedInstance.application willDeallocPageContainer:pageName
                                                                      params:params
                                                                    uniqueId:uniqueId];
 }
 
 
 @end
