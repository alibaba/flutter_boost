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
#import "FLBMessageDispather.h"

@interface FLBMessageDispather()

@property (nonatomic,strong) NSMutableDictionary *handlerMap;

@end

@implementation FLBMessageDispather

- (instancetype)init
{
    if (self = [super init]) {
        _handlerMap = NSMutableDictionary.new;
    }
    
    return self;
}

- (BOOL)dispatch:(id<FLBMessage>)msg result:(void (^)(id date))result
{
    if (msg) {
        id<FLBMessageHandler> handler = _handlerMap[msg.name];
        [handler handle:msg result:result];
        return handler != nil;
    }else{
        return NO;
    }
}

- (void)registerHandler:(id<FLBMessageHandler>)handler
{
    if(!handler) return;
    
    NSArray *methods = handler.handledMessageNames;
    for(NSString *name in methods){
        if(_handlerMap[name]){
            NSAssert(NO, @"Conflicted method call name results in undefined error!");
        }else{
            _handlerMap[name] = handler;
        }
    }
}

- (void)removeHandler:(id<FLBMessageHandler>)handler
{
    NSArray *methods = handler.handledMessageNames;
    [_handlerMap removeObjectsForKeys:methods];
}

- (void)removeAll
{
    [_handlerMap removeAllObjects];
}

@end
