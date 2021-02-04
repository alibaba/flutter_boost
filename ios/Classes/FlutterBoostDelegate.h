//
//  DefaultEngineConfig.h
//  Pods
//
//  Created by wubian on 2021/1/21.
//

#import <Foundation/Foundation.h>
#import "messages.h"
#import <Flutter/Flutter.h>

@class FBCommonParams;

typedef void (^NativeRouterHandler)(FBCommonParams* params);

@protocol  FlutterBoostDelegate <NSObject>

@optional
- (NSString*) initialRoute;
- (NSString*) dartEntrypointFunctionName;
- (FlutterEngine*)  engine;
@required
- (void) pushNativeRoute:(FBCommonParams*) params;

- (void) pushFlutterRoute:(FBCommonParams*)params ;

- (void) popRoute:(FBCommonParams*)params
         result:(NSDictionary *)result;

@end

