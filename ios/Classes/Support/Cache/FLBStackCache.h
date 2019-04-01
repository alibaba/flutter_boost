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

@class FLBStackCache;

@protocol FLBStackCacheObject<NSObject>

@required
@property (nonatomic,copy) NSString *key;

- (BOOL)writeToFileWithKey:(NSString *)key
                     queue:(dispatch_queue_t)queue
                     cache:(FLBStackCache *)cache
                completion:(void (^)(NSError *err,NSString *path))completion;

+ (BOOL)loadFromFileWithKey:(NSString *)key
                      queue:(dispatch_queue_t)queue
                     cache:(FLBStackCache *)cache
                 completion:(void (^)(NSError *err ,id<FLBStackCacheObject>))completion;

- (BOOL)removeCachedFileWithKey:(NSString *)key
                          queue:(dispatch_queue_t)queue
                          cache:(FLBStackCache *)cache
                     completion:(void (^)(NSError *, NSString *))completion;


@end


@interface FLBStackCache : NSObject
+ (instancetype)sharedInstance;

/**
 * Num of objects allowed in memory.
 * Default value is set to 2.
 */
@property (nonatomic,assign) NSUInteger inMemoryCount;

#pragma mark - basic operations.
- (void)pushObject:(id<FLBStackCacheObject>)obj key:(NSString *)key;
- (id<FLBStackCacheObject>)remove:(NSString *)key;
- (void)invalidate:(NSString *)key;
- (BOOL)empty;
- (void)clear;
- (id<FLBStackCacheObject>)objectForKey:(NSString *)key;

#pragma mark - Disk thing.
- (NSString *)cacheDir;
@end
