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

#import "FLBCollectionHelper.h"

@implementation FLBCollectionHelper

+ (NSDictionary *)deepCopyNSDictionary:(NSDictionary *)origin filter:(FLBCollectionFilter)filter
{
    if(origin.count < 1) return origin;
    NSMutableDictionary *copyed = [NSMutableDictionary new];
    [origin enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        //Filter: Do not include invalid things
        if(filter && !filter(obj)) return;
        
        if([obj isKindOfClass: NSDictionary.class]){
            copyed[key] = [self deepCopyNSDictionary:obj filter:filter];
        }else if([obj isKindOfClass:NSArray.class]){
            copyed[key] = [self deepCopyNSArray:obj filter:filter];
        }else{
            copyed[key] = obj;
        }
    }];
    
    return copyed;
}

+ (NSArray *)deepCopyNSArray:(NSArray *)origin filter:(FLBCollectionFilter)filter
{
    if(origin.count < 1) return origin;
    NSMutableArray *copyed = [NSMutableArray new];
    [origin enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //Filter: Do not include invalid things.
        if(filter && !filter(obj)) return;
        
        id nObj = nil;
        
        if([obj isKindOfClass: NSDictionary.class]){
            nObj = [self deepCopyNSDictionary:obj filter:filter];
        }else if([obj isKindOfClass:NSArray.class]){
            nObj = [self deepCopyNSArray:obj filter:filter];
        }else{
            nObj = obj;
        }
    
        if (nObj) {
            [copyed addObject:nObj];
        }
    }];
    
    return copyed;
}

@end
