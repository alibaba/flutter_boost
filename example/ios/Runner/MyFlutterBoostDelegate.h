//
//  MyFlutterBoostDelegate.h
//  Runner
//
//  Created by wubian on 2021/1/21.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//
#import <flutter_boost/FlutterBoost.h>
#import <Foundation/Foundation.h>

@interface MyFlutterBoostDelegate : NSObject<FlutterBoostDelegate>
    
@property (nonatomic,strong) UINavigationController *navigationController;


@end
