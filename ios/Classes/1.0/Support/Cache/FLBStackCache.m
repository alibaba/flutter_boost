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

#import "FLBStackCache.h"

@interface FLBStackCache()

@property (nonatomic,strong) NSMutableArray *keyStack;
@property (nonatomic,strong) NSMutableDictionary *typesMap;
@property (nonatomic,strong) NSMutableDictionary *inMemoryObjectsMap;
@property (nonatomic,strong) NSMutableDictionary *loadinMap;
@property (nonatomic,strong) dispatch_queue_t queueIO;
@end

@implementation FLBStackCache

+ (instancetype)sharedInstance
{
    static id sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [self.class new];
    });
    
    return sInstance;
}

- (BOOL)empty
{
    return _keyStack.count<=0;
}

- (void)clear
{
    [self.keyStack removeAllObjects];
    [self.inMemoryObjectsMap removeAllObjects];
    [self.typesMap removeAllObjects];
    NSError *err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.cacheDir error:&err];
    if (err) {
        NSLog(@"fail to remove cache dir %@",err);
    }
}


- (instancetype)init
{
    if (self = [super init]) {
        _keyStack = [NSMutableArray new];
        _inMemoryObjectsMap = [NSMutableDictionary new];
        _loadinMap = [NSMutableDictionary new];
        _typesMap = [NSMutableDictionary new];
        _queueIO = dispatch_queue_create("Stack cache working queue", NULL);
    }
    _inMemoryCount = 2;
    return self;
}

 - (void)pushObject:(id<FLBStackCacheObject>)obj
                key:(NSString *)key
{
    if (!obj || key.length <= 0) {
        return;
    }
    
    if(![_keyStack containsObject:key]){
        [_keyStack addObject:key];
    }else{
        //return;
    }
    
    obj.key = key;
    _typesMap[key] = obj.class;
    _inMemoryObjectsMap[key] = obj;

    for(NSUInteger i = _keyStack.count - _inMemoryObjectsMap.count ;
        i < _keyStack.count && _inMemoryObjectsMap.count > _inMemoryCount;
        i++){
        
        NSString *keyToSave = _keyStack[i];
        if(_inMemoryObjectsMap[keyToSave]){
            id<FLBStackCacheObject> ob = _inMemoryObjectsMap[keyToSave];
            [_inMemoryObjectsMap removeObjectForKey:keyToSave];
            [ob writeToFileWithKey:keyToSave
                             queue:_queueIO
                             cache:self
                        completion:^(NSError *err, NSString *path) {
                            if (err) {
                                NSLog(@"Caching object to file failed!");
                            }
                        }];
        }
    }
}

- (id<FLBStackCacheObject>)objectForKey:(NSString *)key
{
    return _inMemoryObjectsMap[key];
}

- (id<FLBStackCacheObject>)remove:(NSString *)key
{
    if([self empty]) return nil;
    
    if(![_keyStack containsObject:key]) return nil;
    
    id ob = _inMemoryObjectsMap[key];
    
    [_keyStack removeObject:key];
    [_inMemoryObjectsMap removeObjectForKey:key];
    [_typesMap removeObjectForKey:key];

    [self preloadIfNeeded];
    
    return ob;
}

- (void)invalidate:(NSString *)key
{
    if(!key || [self empty]) return;
    
    if(![_keyStack containsObject:key]) return;
    
    id<FLBStackCacheObject> ob = _inMemoryObjectsMap[key];
    [ob removeCachedFileWithKey:key
                          queue:_queueIO
                          cache:self
                     completion:^(NSError *err, NSString *k) {
    }];
    [_inMemoryObjectsMap removeObjectForKey:key];
    
    [self preloadIfNeeded];
}

- (void)preloadIfNeeded
{
    for(NSString *key in self.keyStack.reverseObjectEnumerator){
        Class typeClass = _typesMap[key];
        id cache = _inMemoryObjectsMap[key];
        if(typeClass && !cache && [typeClass conformsToProtocol: @protocol(FLBStackCacheObject)]){
            _loadinMap[key] = @(YES);
            [typeClass loadFromFileWithKey:key
                                     queue:_queueIO
                                     cache:self
                                completion:^(NSError *err ,id<FLBStackCacheObject> ob){
                                    [self.loadinMap removeObjectForKey:key];
                                    if (ob && !err) {
                                        if(self.typesMap[key]){
                                            self.inMemoryObjectsMap[key] = ob;
                                        }
                                    }else{
                                        NSLog(@"preload object from file failed!");
                                    }
                                }];
        }

        if(_inMemoryObjectsMap.count + _loadinMap.count >= _inMemoryCount){
            break;
        }
    }
}



- (NSString *)cacheDir
{
    static NSString *cachePath = nil;
    if (!cachePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        cachePath = [cacheDirectory stringByAppendingPathComponent:@"FlutterScreenshots"];
    }
    
    BOOL dir = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&dir]){
        NSError *eror = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&eror];
        if (eror) {
            NSLog(@"%@",eror);
        }
    }
    
    return cachePath;
}

@end
