//
//  FLBFlutterContainer.h
//  flutter_boost
//
//  Created by Jidong Chen on 2019/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FLBFlutterContainer <NSObject>
- (NSString *)name;
- (NSDictionary *)params;
- (NSString *)uniqueIDString;
- (void)setName:(NSString *)name params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
