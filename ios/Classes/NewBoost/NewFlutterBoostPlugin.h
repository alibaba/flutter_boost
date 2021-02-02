//
//  FlutterBoostPlugin.h
//  Pods
//
//  Created by wubian on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "messages.h"
#import "FlutterBoostDelegate.h"
#import "FLBFlutterContainer.h"

@interface NewFlutterBoostPlugin : NSObject <FlutterPlugin>
//FlutterBoostDelegate
@property(nonatomic, strong) FBFlutterRouterApi* flutterApi;

- (void)addContainer:(id<FLBFlutterContainer>)vc;
- (void)removeContainer:(id<FLBFlutterContainer>)vc;
@end
