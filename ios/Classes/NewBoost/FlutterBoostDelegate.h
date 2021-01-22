//
//  DefaultEngineConfig.h
//  Pods
//
//  Created by wubian on 2021/1/21.
//

#import <Foundation/Foundation.h>
#import "messages.h"

@class FBCommonParams;

typedef void (^NativeRouterHandler)(FBCommonParams* params);

@interface  FlutterBoostDelegate : NSObject<NSObject>

@property(nonatomic, copy) NSString* initialRoute;
@property(nonatomic, copy) NSString* dartEntrypointFunctionName;

@property(nonatomic, copy) NativeRouterHandler pushNativeHandler;
@property(nonatomic, copy) NativeRouterHandler pushFlutterHandler;
@property(nonatomic, copy) NativeRouterHandler popHandler;

@end

