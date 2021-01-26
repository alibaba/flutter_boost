//
//  MyFlutterBoostDelegate.m
//  Runner
//
//  Created by wubian on 2021/1/21.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MyFlutterBoostDelegate.h"
#import "UIViewControllerDemo.h"

@implementation MyFlutterBoostDelegate
    
- (void) pushNativeRoute:(FBCommonParams*) params
         present:(BOOL)present
              completion:(void (^)(BOOL finished))completion{
    
    UIViewControllerDemo *nvc = [[UIViewControllerDemo alloc] initWithNibName:@"UIViewControllerDemo" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:nvc animated:YES];
}

- (void) pushFlutterRoute:(FBCommonParams*)params
         present:(BOOL)present
               completion:(void (^)(BOOL finished))completion{
    
    FlutterEngine* engine =  [[NewFlutterBoost instance ] engine];
    engine.viewController = nil;
    FlutterViewController* vc = [[FlutterViewController alloc] initWithEngine:engine nibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) popRoute:(FBCommonParams*)params
         result:(NSDictionary *)result
       completion:(void (^)(BOOL finished))completion{
    [self.navigationController popViewControllerAnimated:YES];

}

@end


