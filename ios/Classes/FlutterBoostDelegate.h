//
//  DefaultEngineConfig.h
//  Pods
//
//  Created by wubian on 2021/1/21.
//

#import <Foundation/Foundation.h>
#import "messages.h"
#import <Flutter/Flutter.h>


@protocol  FlutterBoostDelegate <NSObject>

@optional
- (NSString*) initialRoute;
- (NSString*) dartEntrypointFunctionName;
- (FlutterEngine*)  engine;
@required  ;
- (void) pushNativeRoute:(NSString *) pageName arguments:(NSDictionary *) arguments ;

- (void) pushFlutterRoute:(NSString *) pageName arguments:(NSDictionary *) arguments ;

- (void) popRoute:(NSString *)uniqueId ;

@end

