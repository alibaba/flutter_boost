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

#import "FLBFlutterEngine.h"
#import <Flutter/Flutter.h>
#import "FLBFlutterViewContainer.h"

#if RELEASE_1_0

@interface FLBFlutterEngine()
@property (nonatomic,strong) FlutterEngine *engine;
@property (nonatomic,strong)  FLBFlutterViewContainer *dummy;
@end

@implementation FLBFlutterEngine

- (instancetype)init
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    if (self = [super init]) {
        _engine = [[FlutterEngine alloc] initWithName:@"io.flutter" project:nil];
        [_engine runWithEntrypoint:nil];
        _dummy = [[FLBFlutterViewContainer alloc] initWithEngine:_engine
                                                       nibName:nil
                                                        bundle:nil];
        Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
        if (clazz) {
            if ([clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
                [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                            withObject:_engine];
            }
        }
    }
    
    return self;
#pragma clang diagnostic pop
}

- (void)pause
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.pause"];
}

- (void)resume
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.resume"];
}

- (void)inactive
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.inactive"];
}


- (FlutterEngine *)engine
{
    return _engine;
}

- (void)atacheToViewController:(FlutterViewController *)vc
{
    if(_engine.viewController != vc){
        _engine.viewController = vc;
    }
}

- (void)detach
{
    if(_engine.viewController != _dummy){
        _engine.viewController = _dummy;
    }
}

- (void)prepareEngineIfNeeded
{
    [self detach];
    [_dummy surfaceUpdated:YES];
}

@end

#endif
