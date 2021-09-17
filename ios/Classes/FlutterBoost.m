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
#import <Flutter/Flutter.h>
#import "FlutterBoost.h"
#import "FlutterBoostPlugin.h"
#import "Options.h"
@interface FlutterBoost ()

@property (nonatomic, strong) FlutterEngine*  engine;
@property (nonatomic, strong) FlutterBoostPlugin*  plugin;
@end

@implementation FlutterBoost

- (void)setup:(UIApplication*)application delegate:(id<FlutterBoostDelegate>)delegate callback:(void (^)(FlutterEngine *engine))callback{
    
    //调用默认的配置参数进行初始化
    [self setup:application delegate:delegate callback:callback options:FlutterBoostSetupOptions.createDefault];
    
}

- (void)setup:(UIApplication*)application delegate:(id<FlutterBoostDelegate>)delegate callback:(void (^)(FlutterEngine *engine))callback options:(FlutterBoostSetupOptions*)options{
    
    if([delegate respondsToSelector:@selector(engine)]){
        self.engine = delegate.engine;
    }else{
        self.engine = [[FlutterEngine alloc ] initWithName:@"io.flutter" project:options.dartObject];
    }
    
    //从options中获取参数
    NSString* initialRoute = options.initalRoute;
    NSString* dartEntrypointFunctionName = options.dartEntryPoint;
    
    void(^engineRun)(void) = ^(void) {
        
        [self.engine runWithEntrypoint:dartEntrypointFunctionName  initialRoute : initialRoute];
        
        //根据配置提前预热引擎,配置默认预热引擎
        if(options.warmUpEngine){
            [self warmUpEngine];
        }
        
        Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
        SEL selector = NSSelectorFromString(@"registerWithRegistry:");
        if (clazz && selector && self.engine) {
            if ([clazz respondsToSelector:selector]) {
                ((void (*)(id, SEL, NSObject<FlutterPluginRegistry>*registry))[clazz methodForSelector:selector])(clazz, selector, self.engine);
            }
        }
        
        self.plugin= [FlutterBoostPlugin getPlugin:self.engine];
        self.plugin.delegate=delegate;
        
        if(callback){
            callback(self.engine);
        }
    };
    
    if ([NSThread isMainThread]){
        engineRun();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            engineRun();
        });
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
}

- (void)unsetFlutterBoost{
    void (^engineDestroy)(void) = ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        self.plugin.delegate = nil;
        self.plugin = nil;
        
        [self.engine destroyContext];
        self.engine = nil;
    };
    
    if ([NSThread isMainThread]){
        engineDestroy();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            engineDestroy();
        });
    }
}

///提前预热引擎
- (void)warmUpEngine{
    FlutterViewController* vc = [[FlutterViewController alloc] initWithEngine:self.engine
                                                                      nibName:nil bundle:nil];
    [vc beginAppearanceTransition:YES animated:NO];
    [vc endAppearanceTransition];
    [vc beginAppearanceTransition:NO animated:NO];
    [vc endAppearanceTransition];
}

+ (instancetype)instance{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self.class new];
    });
    
    return _instance;
}


#pragma mark - Some properties.

- (FlutterViewController *) currentViewController{
    return self.engine.viewController;
}

#pragma mark - open/close Page
- (void)open:(NSString *)pageName arguments:(NSDictionary *)arguments completion:(void(^)(BOOL)) completion {
    
    FlutterBoostRouteOptions* options = [[FlutterBoostRouteOptions alloc]init];
    options.pageName = pageName;
    options.arguments = arguments;
    options.completion = completion;
    
    [self.plugin.delegate pushFlutterRoute:options];
}

- (void)open:(FlutterBoostRouteOptions* )options{
    [self.plugin.delegate pushFlutterRoute:options];
}

- (void)close:(NSString *)uniqueId {
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.uniqueId=uniqueId;
    [self.plugin.flutterApi popRoute:params completion:^(NSError* error) {
    } ];
}

- (void)sendResultToFlutterWithPageName:(NSString*)pageName arguments:(NSDictionary*) arguments{
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.pageName = pageName;
    params.arguments = arguments;
    
    [self.plugin.flutterApi onNativeResult:params completion:^(NSError * error) {
        
    }];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    FBCommonParams* params = [[FBCommonParams alloc] init];
    [ self.plugin.flutterApi onBackground: params completion:^(NSError * error) {
        
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    FBCommonParams* params = [[FBCommonParams alloc] init];
    [self.plugin.flutterApi onForeground:params completion:^(NSError * error) {
        
    }];
}


- (FBVoidCallback)addEventListener:(FBEventListener)listener
                           forName:(NSString *)key{
    return [self.plugin addEventListener:listener forName:key];
}

- (void)sendEventToFlutterWith:(NSString*)key arguments:(NSDictionary*)arguments{
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.key = key;
    params.arguments = arguments;
    [self.plugin.flutterApi sendEventToFlutter:params completion:^(NSError * error) {
        
    }];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

@end
