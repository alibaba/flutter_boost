/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 Alibaba Group
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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

