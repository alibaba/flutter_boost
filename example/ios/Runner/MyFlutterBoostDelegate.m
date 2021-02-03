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


- (void) pushNativeRoute:(FBCommonParams*) params
         present:(BOOL)present
              completion:(void (^)(BOOL finished))completion{
    
    UIViewControllerDemo *nvc = [[UIViewControllerDemo alloc] initWithNibName:@"UIViewControllerDemo" bundle:[NSBundle mainBundle]];
    if(present){
        [self.navigationController presentViewController:nvc animated:YES completion:^{
        }];
    }else{
        [self.navigationController pushViewController:nvc animated:YES];
    }
    if(completion) completion(YES);
}

- (void) pushFlutterRoute:(FBCommonParams*)params
         present:(BOOL)present
               completion:(void (^)(BOOL finished))completion{
    
    FlutterEngine* engine =  [[FlutterBoost instance ] engine];
    engine.viewController = nil;
    
    FBFlutterViewContainer *vc = FBFlutterViewContainer.new ;
    
    [vc setName:params.pageName params:params.arguments];
    
    if(present){
        [self.navigationController presentViewController:vc animated:YES completion:^{
        }];
    }else{
        [self.navigationController pushViewController:vc animated:YES];

    }
    if(completion) completion(YES);
}

- (void) popRoute:(FBCommonParams*)params
         result:(NSDictionary *)result
       completion:(void (^)(BOOL finished))completion{
    
//    [self.navigationController popViewControllerAnimated:YES];

    FBFlutterViewContainer *vc = (id)self.navigationController.presentedViewController;
    
    if([vc isKindOfClass:FBFlutterViewContainer.class] && [vc.uniqueIDString isEqual: params.uniqueId]){
        [vc dismissViewControllerAnimated:YES completion:^{}];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if(completion) completion(YES);
}

@end


