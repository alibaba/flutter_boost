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

#import "FLBFlutterEngineOld.h"
#import "FLBFlutterViewControllerAdaptor.h"

@interface FLBFlutterEngineOld()
@property (nonatomic,strong) FLBFlutterViewControllerAdaptor *viewController;
@end

@implementation FLBFlutterEngineOld

- (instancetype)init
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    if (self = [super init]) {
        _viewController = [FLBFlutterViewControllerAdaptor new];
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
    [self.viewController boost_viewWillDisappear:NO];
    [self.viewController boost_viewDidDisappear:NO];
}

- (void)resume
{
    [self.viewController boost_viewWillAppear:NO];
    [self.viewController boost_viewDidAppear:NO];
}

- (void)inactive
{
    NSString *channel = @"flutter/lifecycle";
    NSString *message = @"AppLifecycleState.inactive";
    NSData *data = [[FlutterStringCodec sharedInstance] encode:message];
    [self.viewController sendOnChannel:channel message:data];
}

- (void)resumeFlutterOnly
{
    NSString *channel = @"flutter/lifecycle";
    NSString *message = @"AppLifecycleState.resumed";
    NSData *data = [[FlutterStringCodec sharedInstance] encode:message];
    [self.viewController sendOnChannel:channel message:data];
}

@end
