//
//  UIViewControllerDemo.m
//  Runner
//
//  Created by Jidong Chen on 2018/10/17.
//  Copyright © 2018年 The Chromium Authors. All rights reserved.
//

#import "UIViewControllerDemo.h"
#import <Flutter/Flutter.h>
#import <flutter_boost/FlutterBoostPlugin.h>


@interface UIViewControllerDemo ()

@end

@implementation UIViewControllerDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)pushFlutterPage:(id)sender {
    [FlutterBoostPlugin open:@"first" urlParams:@{kPageCallBackId:@"MycallbackId#1"} exts:@{@"animated":@(YES)} onPageFinished:^(NSDictionary *result) {
        NSLog(@"call me when page finished, and your result is:%@", result);
    } completion:^(BOOL f) {
        NSLog(@"page is opened");
    }];
}

- (IBAction)present:(id)sender {
    [FlutterBoostPlugin open:@"second" urlParams:@{@"present":@(YES),kPageCallBackId:@"MycallbackId#2"} exts:@{@"animated":@(YES)} onPageFinished:^(NSDictionary *result) {
        NSLog(@"call me when page finished, and your result is:%@", result);
    } completion:^(BOOL f) {
        NSLog(@"page is presented");
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
