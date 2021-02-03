//
//  FBFlutterContainer.h
//  Pods
//
//  Created by wubian on 2021/2/3.
//

#import <Foundation/Foundation.h>

@protocol FBFlutterContainer <NSObject>
- (NSString *)name;
- (NSDictionary *)params;
- (NSString *)uniqueIDString;
- (void)setName:(NSString *)name params:(NSDictionary *)params;
@end
