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

@protocol  FlutterBoostDelegate <NSObject>

@optional
- (NSString*) initialRoute=@"/";
- (NSString*) dartEntrypointFunctionName=@"main";
- (FlutterEngine*)  engine;
@required
- (void) pushNativeRoute:(FBCommonParams*) params
         present:(BOOL)present
         completion:(void (^)(BOOL finished))completion;

- (void) pushFlutterRoute:(FBCommonParams*)params
         present:(BOOL)present
         completion:(void (^)(BOOL finished))completion ;

- (void) popRoute:(FBCommonParams*)params
         result:(NSDictionary *)result
        completion:(void (^)(BOOL finished))completion;

@end

