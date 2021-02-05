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
#import <flutter_boost/FlutterBoost.h>

@implementation MyFlutterBoostDelegate


- (void) pushNativeRoute:(FBCommonParams*) params{
    BOOL animated = [params.arguments[@"animated"] boolValue];
    BOOL present= [params.arguments[@"present"] boolValue];
    UIViewControllerDemo *nvc = [[UIViewControllerDemo alloc] initWithNibName:@"UIViewControllerDemo" bundle:[NSBundle mainBundle]];
    if(present){
        [self.navigationController presentViewController:nvc animated:animated completion:^{
        }];
    }else{
        [self.navigationController pushViewController:nvc animated:animated];
    }
}

- (void) pushFlutterRoute:(FBCommonParams*)params {
    
    FlutterEngine* engine =  [[FlutterBoost instance ] getEngine];
    engine.viewController = nil;
    
    FBFlutterViewContainer *vc = FBFlutterViewContainer.new ;
    
    [vc setName:params.pageName params:params.arguments];
    
    BOOL animated = [params.arguments[@"animated"] boolValue];
    BOOL present= [params.arguments[@"present"] boolValue];
    if(present){
        [self.navigationController presentViewController:vc animated:animated completion:^{
        }];
    }else{
        [self.navigationController pushViewController:vc animated:animated];

    }
}

- (void) popRoute:(FBCommonParams*)params
         result:(NSDictionary *)result{
    
//    [self.navigationController popViewControllerAnimated:YES];

    FBFlutterViewContainer *vc = (id)self.navigationController.presentedViewController;
    
    if([vc isKindOfClass:FBFlutterViewContainer.class] && [vc.uniqueIDString isEqual: params.uniqueId]){
        [vc dismissViewControllerAnimated:YES completion:^{}];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

@end


