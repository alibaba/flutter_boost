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

#import "FLB2FlutterEngine.h"
#import <Flutter/Flutter.h>
#import "FLB2FlutterViewContainer.h"
#import "BoostMessageChannel.h"


@interface FLB2FlutterEngine()
@property (nonatomic,strong) FlutterEngine *engine;
@property (nonatomic,strong)  FLB2FlutterViewContainer *dummy;
@end

@implementation FLB2FlutterEngine
    
- (instancetype)initWithPlatform:(id<FLB2Platform>)platform
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    if (self = [super init]) {
        _engine = [[FlutterEngine alloc] initWithName:@"io.flutter" project:nil];
        if(platform &&
           [platform respondsToSelector: @selector(entryForDart)] &&
           platform.entryForDart){
            [_engine runWithEntrypoint:platform.entryForDart];
        }else{
            [_engine runWithEntrypoint:nil];
        }
        _dummy = [[FLB2FlutterViewContainer alloc] initWithEngine:_engine
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

- (instancetype)init
{
    return [self initWithPlatform:nil];
}

- (void)pause
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.paused"];
    [self detach];
}

- (void)resume
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.resumed"];
    [(FLB2FlutterViewContainer *)_engine.viewController surfaceUpdated:YES];
}

- (void)inactive
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.inactive"];
}


- (void)didEnterBackground
{
    [BoostMessageChannel sendEvent:@"background"
                         arguments:nil];
}

- (void)willEnterForeground
{
    [BoostMessageChannel sendEvent:@"foreground"
                         arguments:nil];
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
//    if ([_dummy respondsToSelector:@selector(setEnableForRunnersBatch:)]) {
//        [_dummy setEnableForRunnersBatch:YES];
//    }
    [self detach];
    [_dummy surfaceUpdated:YES];
}

@end

