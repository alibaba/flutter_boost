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
@property(nonatomic, strong)FBFlutterViewContainer *flutterContainer;
@end

@implementation NativeViewController

- (instancetype)init{
    if (self = [super init]) {
        _flutterContainer = [[FBFlutterViewContainer alloc]init];
        [_flutterContainer setName:@"embedded" uniqueId:nil params:@{} opaque:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.flutterContainer.view.frame = CGRectInset(self.view.bounds, 30, 100);
    [self.view addSubview:self.flutterContainer.view];
    [self addChildViewController:self.flutterContainer];
    
    UIButton *nativeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nativeButton.frame = CGRectMake(50,self.view.bounds.size.height-50,200,40);
    nativeButton.backgroundColor = [UIColor blueColor];
    [nativeButton setTitle:@"Button in Native" forState:UIControlStateNormal];
    [nativeButton addTarget:self action:@selector(pushMe) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nativeButton];
}

- (void)pushMe
{
    UIViewController *vc = [[UIViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //注意这行代码不可缺少
//    [self.flutterContainer.view setNeedsLayout];
//    [self.flutterContainer.view layoutIfNeeded];
}

//NOTES: embed情景下必须实现！！！
- (void)didMoveToParentViewController:(UIViewController *)parent {
    [self.flutterContainer didMoveToParentViewController:parent];
    [super didMoveToParentViewController:parent];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc{
    NSLog(@"dealloc native controller%p", self.flutterContainer);
}

@end
