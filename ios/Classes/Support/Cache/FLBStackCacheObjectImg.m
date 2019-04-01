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

#import "FLBStackCacheObjectImg.h"

@interface FLBStackCacheObjectImg()
@property (nonatomic,strong) UIImage *image;
@end

@implementation FLBStackCacheObjectImg

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        _image = image;
    }
    
    return self;
}



+ (BOOL)loadFromFileWithKey:(NSString *)key
                      queue:(dispatch_queue_t)queue
                      cache:(FLBStackCache *)cache
                 completion:(void (^)(NSError *, id<FLBStackCacheObject>))completion
{
    dispatch_async(queue, ^{
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self filePathByKey:key dirPath:cache.cacheDir]];
        if (completion) {
            if (image) {
                FLBStackCacheObjectImg *ob = [[FLBStackCacheObjectImg alloc] initWithImage:image];
                ob.key = key;
                completion(nil,ob);
            }else{
                completion([NSError new],nil);
            }
        }
    });
    
    return YES;
}

+ (NSString *)filePathByKey:(NSString *)key dirPath:(NSString *)cacheDir
{
    key = [key stringByReplacingOccurrencesOfString:@"/" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *path = [cacheDir stringByAppendingPathComponent:key];
    return path;
}

- (BOOL)writeToFileWithKey:(NSString *)key
                     queue:(dispatch_queue_t)queue
                     cache:(FLBStackCache *)cache
                completion:(void (^)(NSError *, NSString *))completion
{
    if(!_image){
        return NO;
    }
    
    dispatch_async(queue, ^{
        NSData *imgData = UIImagePNGRepresentation(self.image);
        NSString *filePath = [FLBStackCacheObjectImg filePathByKey:key dirPath:cache.cacheDir];
        [imgData writeToFile:filePath atomically:YES];
        if (completion) {
            completion(nil,key);
        }
    });
    
    return YES;
}

- (BOOL)removeCachedFileWithKey:(NSString *)key
                          queue:(dispatch_queue_t)queue
                          cache:(FLBStackCache *)cache
                     completion:(void (^)(NSError *, NSString *))completion
{
    if(!key){
        return NO;
    }
    
    dispatch_async(queue, ^{
        NSString *filePath = [FLBStackCacheObjectImg filePathByKey:key dirPath:cache.cacheDir];
        NSError *err = nil;
        [NSFileManager.defaultManager removeItemAtPath:filePath error:&err];
        if (completion) {
            completion(err,key);
        }
    });
    
    return YES;
}


@end
