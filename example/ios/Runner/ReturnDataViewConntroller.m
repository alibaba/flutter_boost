//
//  ReturnDataViewConntroller.m
//  Runner
//
//  Created by luckysmg on 2021/5/1.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

#import "ReturnDataViewConntroller.h"
#import <flutter_boost/FlutterBoost.h>

@implementation ReturnDataViewConntroller

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton* button = [[UIButton alloc]init];
    [button addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"tap to return data " forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    
    [self.view addSubview:button];
    button.frame = CGRectMake(150, 400, 50, 300);
    [button sizeToFit];

}

-(void) onTap{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"zhangsan" forKey:@"zs"];
    
    [[FlutterBoost instance]sendResultToFlutterWithPageName:@"NativeReturnDataPage" arguments:dic];
}


@end
