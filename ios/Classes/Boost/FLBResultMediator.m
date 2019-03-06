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

#import "FLBResultMediator.h"

@interface FLBResultMediator()
@property (nonatomic,strong) NSMutableDictionary *handlers;
@end

@implementation FLBResultMediator

- (instancetype)init
{
    if (self = [super init]) {
        _handlers = [NSMutableDictionary new];
    }
    return self;
}

- (void)onResultForKey:(NSString *)vcId
            resultData:(NSDictionary *)resultData
{
    if(!vcId) return;
    
    NSString *key = vcId;
    if(_handlers[key]){
        FLBPageResultHandler handler = _handlers[key];
        handler(key,resultData);
        [_handlers removeObjectForKey: key];
    }
}

- (void)setResultHandler:(FLBPageResultHandler)handler
                  forKey:(NSString *)vcid
{
    if(!handler || !vcid) return;
    _handlers[vcid] = handler;
}

- (void)removeHandlerForKey:(NSString *)vcid
{
    if(!vcid) return;
    [_handlers removeObjectForKey:vcid];
}

@end
