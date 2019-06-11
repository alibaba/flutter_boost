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

#import "FLBFlutterViewControllerAdaptor.h"
#import <objc/runtime.h>

@interface FLBFlutterViewControllerAdaptor ()
@end

@implementation FLBFlutterViewControllerAdaptor

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    //Left blank intentionally.
}

- (void)viewDidAppear:(BOOL)animated
{
   //Left blank intentionally.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    //Avoid super call intentionally.
}

- (void)viewDidDisappear:(BOOL)animated
{
    //Avoid super call intentionally.
     [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


- (void)boost_viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)boost_viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)boost_viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)boost_viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (UIEdgeInsets)paddingEdgeInsets{
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        edgeInsets = UIEdgeInsetsMake(0, self.view.safeAreaInsets.left, self.view.safeAreaInsets.bottom, self.view.safeAreaInsets.right);
    } else {
        edgeInsets = UIEdgeInsetsZero;
    }
    return edgeInsets;
}

- (void)installSplashScreenViewIfNecessary {
  //Override this to avoid unnecessary splash Screen.
}

- (void)fixed_onAccessibilityStatusChanged:(NSNotification*)notification {
    if(self.accessibilityEnable){
        [self fixed_onAccessibilityStatusChanged:notification];
    }
}


@end
