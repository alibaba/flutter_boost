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
#import "FLBFlutterViewControllerAdaptor.h"

#if RELEASE_1_0

@interface FLBFlutterEngine()
@property (nonatomic,strong) FLBFlutterViewControllerAdaptor *viewController;
@property (nonatomic,strong) FlutterEngine *engine;
@end

@implementation FLBFlutterEngine

- (instancetype)init
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    if (self = [super init]) {
        _engine = [[FlutterEngine alloc] initWithName:@"io.flutter" project:nil];
        [_engine runWithEntrypoint:nil];
        _viewController = [[FLBFlutterViewControllerAdaptor alloc] initWithEngine:_engine
                                                                          nibName:nil
                                                                           bundle:nil];
        [_viewController view];
        Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
        if (clazz) {
            if ([clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
                [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                            withObject:_viewController];
            }
        }
    }
    
    return self;
#pragma clang diagnostic pop
}

- (FlutterViewController *)viewController
{
    return _viewController;
}

- (void)pause
{
    //TODO: [[_engine.get() lifecycleChannel] sendMessage:@"AppLifecycleState.paused"];
    [self.viewController boost_viewWillDisappear:NO];
    [self.viewController boost_viewDidDisappear:NO];
}

- (void)resume
{
    //TODO:   [[_engine.get() lifecycleChannel] sendMessage:@"AppLifecycleState.resumed"];
    [self.viewController boost_viewWillAppear:NO];
    [self.viewController boost_viewDidAppear:NO];
}

- (void)inactive
{
    [[_engine lifecycleChannel] sendMessage:@"AppLifecycleState.inactive"];
}

- (void)setAccessibilityEnable:(BOOL)enable
{
    self.viewController.accessibilityEnable = enable;
}
@end

#endif
