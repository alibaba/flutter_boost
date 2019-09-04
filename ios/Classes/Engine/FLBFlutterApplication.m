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

#import "FLBFlutterApplication.h"
#import "FlutterBoost.h"
#import "FLBFlutterContainerManager.h"
#import "FLBFlutterEngine.h"

@interface FLBFlutterApplication()
@property (nonatomic,strong) FLBFlutterContainerManager *manager;
@property (nonatomic,strong) id<FLBFlutterProvider> viewProvider;
@property (nonatomic,assign) BOOL isRunning;
@property (nonatomic,strong) NSMutableDictionary *pageResultCallbacks;
@property (nonatomic,strong) NSMutableDictionary *callbackCache;
@end


@implementation FLBFlutterApplication

+ (FLBFlutterApplication *)sharedApplication
{
    static FLBFlutterApplication *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (BOOL)isRunning
{
    return _isRunning;
}

- (id)flutterProvider
{
    return _viewProvider;
}

- (void)startFlutterWithPlatform:(id<FLBPlatform>)platform
                         onStart:(void (^)(id<FlutterBinaryMessenger,FlutterTextureRegistry,FlutterPluginRegistry> _Nonnull))callback
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.platform = platform;
        self.viewProvider = [[FLBFlutterEngine alloc] initWithPlatform:platform];
        self.isRunning = YES;
        if(callback) callback(self.viewProvider.engine);
    });
}

- (instancetype)init
{
    if (self = [super init]) {
        _manager = [FLBFlutterContainerManager new];
        _pageResultCallbacks = NSMutableDictionary.new;
        _callbackCache = NSMutableDictionary.new;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (UIView *)flutterView
{
    return [self flutterViewController].view;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.viewProvider didEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.viewProvider willEnterForeground];
}

- (BOOL)contains:(id<FLBFlutterContainer>)vc
{
    return [_manager contains:vc];
}

- (void)addUniqueViewController:(id<FLBFlutterContainer>)vc
{
    return [_manager addUnique:vc];
}

- (void)removeViewController:(id<FLBFlutterContainer>)vc
{
    return [_manager remove:vc];
}


- (BOOL)isTop:(NSString *)pageId
{
    return [_manager.peak isEqual:pageId];
}

- (void)pause
{
    [self.viewProvider pause];
}

- (void)resume
{
    [self.viewProvider resume];
}

- (void)inactive
{
    [self.viewProvider inactive];
}

- (FlutterViewController *)flutterViewController
{
    return self.flutterProvider.engine.viewController;
}

- (void)close:(NSString *)uniqueId
       result:(NSDictionary *)result
         exts:(NSDictionary *)exts
   completion:(void (^)(BOOL))completion
{
    [self.platform close:uniqueId
                  result:result
                    exts:exts
              completion:completion];
    
    if(_pageResultCallbacks[uniqueId]){
        void (^cb)(NSDictionary *) = _pageResultCallbacks[uniqueId];
        cb(result);
        [_pageResultCallbacks removeObjectForKey:uniqueId];
    }
}

- (void)open:(NSString *)url
   urlParams:(NSDictionary *)urlParams
        exts:(NSDictionary *)exts
       reult:(void (^)(NSDictionary *))resultCallback
  completion:(void (^)(BOOL))completion
{
    NSString *cid = urlParams[@"__calback_id__"];
   
    if(!cid){
        static int64_t sCallbackID = 1;
        cid = @(sCallbackID).stringValue;
        sCallbackID += 2;
    }
    
    _callbackCache[cid] = resultCallback;
    
    [self.platform open:url
              urlParams:urlParams
                   exts:exts
             completion:completion];
}

- (void)didInitPageContainer:(NSString *)url
                      params:(NSDictionary *)urlParams
                    uniqueId:(NSString *)uniqueId
{
    NSString *cid = urlParams[@"__calback_id__"];
    if(cid && _callbackCache[cid]){
        _pageResultCallbacks[uniqueId] = _callbackCache[cid];
        [_callbackCache removeObjectForKey:cid];
    }
}

- (void)willDeallocPageContainer:(NSString *)url
                          params:(NSDictionary *)params
                        uniqueId:(NSString *)uniqueId
{
    if(_pageResultCallbacks[uniqueId]){
        void (^cb)(NSDictionary *) = _pageResultCallbacks[uniqueId];
        cb(@{});
        [_pageResultCallbacks removeObjectForKey:uniqueId];
    }
}

@end
