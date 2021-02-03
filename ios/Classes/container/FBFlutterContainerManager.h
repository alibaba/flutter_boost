//
//  FBFlutterContainerManager.h
//  Pods
//
//  Created by wubian on 2021/2/3.
//

#import <Foundation/Foundation.h>
#import "FBFlutterContainer.h"

@interface FBFlutterContainerManager : NSObject

- (NSString *)peak;
- (void)addUnique:(id<FBFlutterContainer>)vc;
- (void)remove:(id<FBFlutterContainer>)vc;
- (BOOL)contains:(id<FBFlutterContainer>)vc;
- (NSInteger)pageCount;
- (BOOL)containUniqueId:(NSString* ) uniqueId;

@end
