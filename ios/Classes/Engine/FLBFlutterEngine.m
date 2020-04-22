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
#import "BoostMessageChannel.h"


@interface FLBFlutterEngine()
@property (nonatomic,strong) FlutterEngine *engine;
@property (nonatomic,strong)  FLBFlutterViewContainer *dummy;
@end

@implementation FLBFlutterEngine
    
- (instancetype)initWithPlatform:(id<FLBPlatform> _Nullable)platform engine:(FlutterEngine * _Nullable)engine
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    if (self = [super init]) {
        if(!engine){
            _engine = [[FlutterEngine alloc] initWithName:@"io.flutter" project:nil];
        }else{
            _engine = engine;
        }
        if(platform &&
           [platform respondsToSelector: @selector(entryForDart)] &&
           platform.entryForDart){
            [_engine runWithEntrypoint:platform.entryForDart];
        }else{
            [_engine runWithEntrypoint:nil];
        }
//        _dummy = [[FLBFlutterViewContainer alloc] initWithEngine:_engine
//                                                          nibName:nil
//                                                           bundle:nil];
//        _dummy.name = kIgnoreMessageWithName;
    }
    
    return self;
#pragma clang diagnostic pop
}

- (instancetype)init
{
    return [self initWithPlatform:nil engine:nil];
}

- (void)pause
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.paused"];
    [self detach];
}

- (void)resume
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.resumed"];
}

- (void)inactive
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.inactive"];
}


- (void)didEnterBackground
{
    [BoostMessageChannel sendEvent:@"lifecycle"
                         arguments:@{@"type":@"background"}];
}

- (void)willEnterForeground
{
    [BoostMessageChannel sendEvent:@"lifecycle"
                         arguments:@{@"type":@"foreground"}];
}

- (BOOL)atacheToViewController:(FlutterViewController *)vc
{
    if(_engine.viewController != vc){
        _engine.viewController = vc;
        return YES;
    }
    return NO;
}

- (void)detach
{
    if(_engine.viewController != _dummy){
        [(FLBFlutterViewContainer *)_engine.viewController surfaceUpdated:NO];
        _engine.viewController = _dummy;
    }
}

- (void)prepareEngineIfNeeded
{
//    [(FLBFlutterViewContainer *)_engine.viewController surfaceUpdated:NO];
//    NSLog(@"[XDEBUG]---surface changed--reset-");
//    [self detach];
}

- (void)dealloc{
    [self.engine setViewController:nil];
}
@end

