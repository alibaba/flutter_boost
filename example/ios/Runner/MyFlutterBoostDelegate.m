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


- (void) pushNativeRoute:(NSString *) pageName arguments:(NSDictionary *) arguments {
    BOOL animated = [arguments[@"animated"] boolValue];
    BOOL present= [arguments[@"present"] boolValue];
    UIViewControllerDemo *nvc = [[UIViewControllerDemo alloc] initWithNibName:@"UIViewControllerDemo" bundle:[NSBundle mainBundle]];
    if(present){
        [self.navigationController presentViewController:nvc animated:animated completion:^{
        }];
    }else{
        [self.navigationController pushViewController:nvc animated:animated];
    }
}

- (void)pushFlutterRoute:(FlutterBoostRouteOptions *)options {
    
    FlutterEngine* engine =  [[FlutterBoost instance] engine];
    engine.viewController = nil;

    FBFlutterViewContainer *vc = FBFlutterViewContainer.new ;

    [vc setName:options.pageName uniqueId:options.uniqueId params:options.arguments];

    BOOL animated = [options.arguments[@"animated"] boolValue];
    BOOL present= [options.arguments[@"present"] boolValue];
    if(present){
        [self.navigationController presentViewController:vc animated:animated completion:^{
            options.completion(YES);
        }];
    }else{
        [self.navigationController pushViewController:vc animated:animated];
        options.completion(YES);
    }
}

- (void) popRoute:(FlutterBoostRouteOptions *)options {
    
    FBFlutterViewContainer *vc = (id)self.navigationController.presentedViewController;
    
    if([vc isKindOfClass:FBFlutterViewContainer.class] && [vc.uniqueIDString isEqual: options.uniqueId]){
        [vc dismissViewControllerAnimated:YES completion:^{}];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}



@end
