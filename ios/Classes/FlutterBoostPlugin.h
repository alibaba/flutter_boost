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
#import "FBFlutterContainer.h"

@interface FlutterBoostPlugin : NSObject <FlutterPlugin>

@property(nonatomic, strong) FBFlutterRouterApi* flutterApi;

- (void)addContainer:(id<FBFlutterContainer>)vc;
- (void)removeContainer:(id<FBFlutterContainer>)vc;
+ (FlutterBoostPlugin* )getPlugin:(FlutterEngine*)engine ;
@end
