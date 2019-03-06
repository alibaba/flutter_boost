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

#import "FLBFlutterViewContainerManager.h"

@interface FLBFlutterViewContainerManager()
@property (nonatomic,strong) NSMutableArray *idStk;
@property (nonatomic,strong) NSMutableDictionary *existedID;
@end

@implementation FLBFlutterViewContainerManager

- (instancetype)init
{
    if (self = [super init]) {
        _idStk= [NSMutableArray new];
        _existedID = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (BOOL)contains:(FLBFlutterViewContainer  *)vc
{
    if (vc) {
        return _existedID[vc.uniqueIDString]?YES:NO;
    }
    
    return NO;
}

- (void)addUnique:(FLBFlutterViewContainer  *)vc
{
    if (vc) {
        if(!_existedID[vc.uniqueIDString]){
            [_idStk addObject:vc.uniqueIDString];
        }
        _existedID[vc.uniqueIDString] = vc.uniqueIDString;
    }
}

- (void)remove:(FLBFlutterViewContainer  *)vc
{
    if (vc) {
        [_existedID removeObjectForKey:vc.uniqueIDString];
        [_idStk removeObject:vc.uniqueIDString];
    }
}

- (NSString *)peak
{
    return _idStk.lastObject;
}

@end
