//
//  FlutterBoostPlugin.h
//  Pods
//
//  Created by wubian on 2021/1/20.
//
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "FlutterBoostDelegate.h"
@interface NewFlutterBoostPlugin : FlutterBoostDelegate<FlutterPlugin>
@property(nonatomic, strong) FBFlutterRouterApi* flutterApi;

@end
