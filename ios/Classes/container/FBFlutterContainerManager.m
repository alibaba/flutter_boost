//
//  FBFlutterContainerManager.m
//  flutter_boost
//
//  Created by wubian on 2021/2/3.
//

#import <Foundation/Foundation.h>
#import "FBFlutterContainerManager.h"

@interface FBFlutterContainerManager()
@property (nonatomic,strong) NSMutableArray *idStk;
@property (nonatomic,strong) NSMutableDictionary *existedID;
@end

@implementation FBFlutterContainerManager

- (instancetype)init
{
    if (self = [super init]) {
        self.idStk= [NSMutableArray new];
        self.existedID = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (BOOL)contains:(id<FBFlutterContainer>)vc
{
    if (vc) {
        return self.existedID[vc.uniqueIDString]?YES:NO;
    }
    
    return NO;
}
- (BOOL)containUniqueId:(NSString* ) uniqueId {
    return self.existedID[uniqueId]?YES:NO;
}


- (void)addUnique:(id<FBFlutterContainer>)vc
{
    if (vc) {
        if(!self.existedID[vc.uniqueIDString]){
            [self.idStk addObject:vc.uniqueIDString];
        }
        self.existedID[vc.uniqueIDString] = vc.name;
    }
#if DEBUG
    [self dump:@"ADD"];
#endif
}

- (void)remove:(id<FBFlutterContainer>)vc
{
    if (vc) {
        [self.existedID removeObjectForKey:vc.uniqueIDString];
        [self.idStk removeObject:vc.uniqueIDString];
    }
#if DEBUG
    [self dump:@"REMOVE"];
#endif
}

- (NSString *)peak
{
    return self.idStk.lastObject;
}

- (NSInteger)pageCount{
    return self.idStk.count;
}

#if DEBUG
- (void)dump:(NSString*)flag{
    NSMutableString *log = [[NSMutableString alloc]initWithFormat:@"[DEBUG]--%@--PageStack uid/name", flag];
    for(NSString *uid in self.idStk){
        [log appendFormat:@"-->%@/%@",uid, self.existedID[uid]];
    }
    NSLog(@"%@\n", log);
}
#endif
@end

