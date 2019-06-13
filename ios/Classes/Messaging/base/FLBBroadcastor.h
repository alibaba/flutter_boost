//
//  FLBBroadcastor.h
//  flutter_boost
//
//  Created by Jidong Chen on 2019/6/13.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FLBEventListener) (NSString *name ,
                                  NSDictionary *arguments);
typedef void (^FLBVoidCallback)(void);

@interface FLBBroadcastor : NSObject

- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel;

- (void)sendEvent:(NSString *)eventName
        arguments:(NSDictionary *)arguments
           result:(FlutterResult)result;

- (FLBVoidCallback)addEventListener:(FLBEventListener)listner
                            forName:(NSString *)name;

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result;
@end

NS_ASSUME_NONNULL_END
