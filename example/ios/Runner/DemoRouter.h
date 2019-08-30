//
//  DemoRouter.h
//  Runner
//
//  Created by Jidong Chen on 2018/10/22.
//  Copyright © 2018年 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <flutter_boost/FlutterBoost2.h>

NS_ASSUME_NONNULL_BEGIN


@interface DemoRouter : NSObject<FLB2Platform>

@property (nonatomic,strong) UINavigationController *navigationController;

+ (DemoRouter *)sharedRouter;


@end

NS_ASSUME_NONNULL_END
