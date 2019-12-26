//
//  NativeViewController.m
//  Runner
//
//  Created by yujie on 2019/12/26.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "NativeViewController.h"
#import <Flutter/Flutter.h>
#import <flutter_boost/FlutterBoost.h>

@interface NativeViewController ()
@property(nonatomic, strong)FLBFlutterViewContainer *flutterContainer;
@end

@implementation NativeViewController

- (instancetype)init{
    if (self = [super init]) {
        _flutterContainer = [[FLBFlutterViewContainer alloc]init];
        [_flutterContainer setName:@"embeded" params:@{}];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.flutterContainer.view.frame = CGRectInset(self.view.bounds, 30, 50);
    [self.view addSubview:self.flutterContainer.view];
    [self addChildViewController:self.flutterContainer];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //注意这行代码不可缺少
    [self.flutterContainer.view setNeedsLayout];
//    [self.flutterContainer.view layoutIfNeeded];
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
