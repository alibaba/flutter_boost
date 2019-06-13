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
#import "FLBMessageHandlerImp.h"
#import "FLBMessageImp.h"

typedef void (^SendResult)(NSObject *result);

@interface FLBMessageHandlerImp()
@property (nonatomic,strong) NSMutableDictionary *callHandlers;
@property (nonatomic,strong) NSMutableArray *methodNames;
@end

@implementation FLBMessageHandlerImp

- (instancetype)init{
    if (self = [super init]) {
        _callHandlers = [NSMutableDictionary new];
        _methodNames = NSMutableArray.new;
        [self bindCallMethod];
    }
    return self;
}

#pragma mark - method handling logic.
//Farward this msg to old entry.
- (BOOL)handle:(id<FLBMessage>)msg result:(void (^)(id data))result
{
    return [self handleMethodCall:msg.name args:msg.params result:result];
}

- (NSArray *)handledMessageNames
{
    return _methodNames;
}

- (bool)handleMethodCall:(NSString*)call
                    args:(NSDictionary *)args
                  result:(void (^)(id data))result
{
    void (^handler)(NSDictionary *,SendResult) = [self findHandler:call];
    if (handler) {
        handler(args,result);
        return YES;
    }
    
    return NO;
}

- (id)findHandler:(NSString *)call
{
    return _callHandlers[call];
}

- (void)bindCallMethod
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL method = @selector(call:result:);
   
    
    for(NSString *name in self.handledMessageNames){
        if (_callHandlers[name]) {
            continue;
        }
        __weak typeof(self) weakSelf = self;
        _callHandlers[name] = ^(NSDictionary *args,SendResult result){
            id resultBlock = [weakSelf getHandlerBlockForType:weakSelf.returnType result:result];
            if (resultBlock && result) {
                FLBMessageImp *msg = FLBMessageImp.new;
                msg.name = name;
                msg.params = args;
                [weakSelf performSelector:method withObject:msg withObject:resultBlock];
            }else{
#if DEBUG
                [NSException raise:@"invalid call" format:@"missing handler and result!"];
#endif
            }
        };
    }
    
#pragma clang diagnostic pop
}


- (id)getHandlerBlockForType:(NSString *)type result:(SendResult)result
{
    if ([type isEqual:@"int64_t"]) {
        return ^(int64_t value){
            result(@(value));
        };
    }
    
    if ([type isEqual:@"double"]) {
        return ^(double value){
            result(@(value));
        };
    }
    
    if ([type isEqual:@"BOOL"]) {
        return ^(BOOL value){
            result(@(value));
        };
    }
    
    if ([type hasPrefix:@"NSString"]) {
        return ^(NSString *value){
            if ([value isKindOfClass:NSNumber.class]) {
#if DEBUG
                [NSException raise:@"invalid type" format:@"require NSString!"];
#endif
                value = ((NSNumber *)value).stringValue;
            }
            result(value);
        };
    }
    
    if ([type hasPrefix:@"NSArray"]) {
        return ^(NSArray *value){
            result(value);
        };
    }
    
    if ([type hasPrefix:@"NSDictionary"]) {
        return ^(NSDictionary *value){
            result(value);
        };
    }
    
    if ([type isEqual:@"id"]) {
        return result;
    }

    /*
     @"int":@"int64_t",
     @"double":@"double",
     @"bool":@"BOOL",
     @"String":@"NSString *",
     
     */
    
    return nil;
}


- (NSString *)returnType
{
    return @"id";
}

- (NSString *)service
{
    return @"root";
}

@end
