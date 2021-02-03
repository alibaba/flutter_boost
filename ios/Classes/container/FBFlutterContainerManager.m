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
        _idStk= [NSMutableArray new];
        _existedID = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (BOOL)contains:(id<FBFlutterContainer>)vc
{
    if (vc) {
        return _existedID[vc.uniqueIDString]?YES:NO;
    }
    
    return NO;
}
- (BOOL)containUniqueId:(NSString* ) uniqueId {
    return _existedID[uniqueId]?YES:NO;
}


- (void)addUnique:(id<FBFlutterContainer>)vc
{
    if (vc) {
        if(!_existedID[vc.uniqueIDString]){
            [_idStk addObject:vc.uniqueIDString];
        }
        _existedID[vc.uniqueIDString] = vc.name;
    }
#if DEBUG
    [self dump:@"ADD"];
#endif
}

- (void)remove:(id<FBFlutterContainer>)vc
{
    if (vc) {
        [_existedID removeObjectForKey:vc.uniqueIDString];
        [_idStk removeObject:vc.uniqueIDString];
    }
#if DEBUG
    [self dump:@"REMOVE"];
#endif
}

- (NSString *)peak
{
    return _idStk.lastObject;
}

- (NSInteger)pageCount{
    return _idStk.count;
}

#if DEBUG
- (void)dump:(NSString*)flag{
    NSMutableString *log = [[NSMutableString alloc]initWithFormat:@"[DEBUG]--%@--PageStack uid/name", flag];
    for(NSString *uid in _idStk){
        [log appendFormat:@"-->%@/%@",uid, _existedID[uid]];
    }
    NSLog(@"%@\n", log);
}
#endif
@end

