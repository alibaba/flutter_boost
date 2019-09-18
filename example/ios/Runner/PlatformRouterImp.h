//
//  DemoRouter.h
//  Runner
//
//  Created by Jidong Chen on 2018/10/22.
//  Copyright © 2018年 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <flutter_boost/FlutterBoost.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FLBPlatform;

/**
 * 实现平台侧的页面打开和关闭，不建议直接使用用于页面打开，建议使用FlutterBoostPlugin中的open和close方法来打开或关闭页面；
 * FlutterBoostPlugin带有页面返回数据的能力
 */
@interface PlatformRouterImp : NSObject<FLBPlatform>
@property (nonatomic,strong) UINavigationController *navigationController;
@end

NS_ASSUME_NONNULL_END
