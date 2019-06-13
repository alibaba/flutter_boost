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


#import "FLBBroadcastor.h"

@interface FLBBroadcastor()
@property (nonatomic,strong) FlutterMethodChannel *channel;
@property (nonatomic,strong) NSMutableDictionary *lists;

@end

@implementation FLBBroadcastor

- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel
{
    if (self = [super init]) {
        _channel = channel;
        _lists = NSMutableDictionary.new;
    }
    return self;
}

- (void)sendEvent:(NSString *)eventName
        arguments:(NSDictionary *)arguments
           result:(void (^)(id _Nonnull))result
{
    if(!eventName) return;
    NSMutableDictionary *msg = NSMutableDictionary.new;
    msg[@"name"] = eventName;
    msg[@"arguments"] = arguments;
    [_channel invokeMethod:@"__event__"
                 arguments:msg
                    result:result];
}

- (FLBVoidCallback)addEventListener:(FLBEventListener)listner
                            forName:(NSString *)name
{
    if(!name || !listner) return ^{};
    
    NSMutableArray *list = _lists[name];
    if(!list){
        list = NSMutableArray.new;
        _lists[name] = list;
    }
    [list addObject:listner];
    return ^{
        [list removeObject:listner];
    };
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result
{
    if([call.method isEqual:@"__event__"]){
        NSString *name = call.arguments[@"name"];
        NSDictionary *arguments = call.arguments[@"arguments"];
        if(name){
            NSMutableArray *list = _lists[name];
            if(list){
                for(FLBEventListener l in list){
                    l(name,arguments);
                }
            }
        }
    }
}

@end
