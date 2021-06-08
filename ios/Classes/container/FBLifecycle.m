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
#import <Foundation/Foundation.h>
#import "FBLifecycle.h"
#import "FlutterBoost.h"
#import "FBFlutterContainer.h"

#define ENGINE [[FlutterBoost instance] engine]

@implementation FBLifecycle

+ (void)pause{
    [[ENGINE lifecycleChannel] sendMessage:@"AppLifecycleState.paused"];
    if(ENGINE.viewController != nil){
        //        [(FBFlutterContainer *) ENGINE.viewController  surfaceUpdated:NO];
        ENGINE.viewController = nil;
    }
}
+ (void)resume{
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        [[ENGINE lifecycleChannel] sendMessage:@"AppLifecycleState.resumed"];
    }
}
+ (void)inactive{
    [[ENGINE lifecycleChannel] sendMessage:@"AppLifecycleState.inactive"];
}

@end
