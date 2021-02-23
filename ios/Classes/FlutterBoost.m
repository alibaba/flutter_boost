//
//  FlutterBoost.m
//  flutter_boost
//
//  Created by wubian on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "FlutterBoost.h"
#import "FlutterBoostPlugin.h"
@interface FlutterBoost ()

@property (nonatomic, assign) BOOL running;
@property (nonatomic, strong) FlutterEngine*  engine;
@property (nonatomic, strong) FlutterBoostPlugin*  plugin;
@property (nonatomic, strong) id<FlutterBoostDelegate> delegate;

@end

@implementation FlutterBoost

- (void)setup:(UIApplication*)application delegate:(id<FlutterBoostDelegate>)delegate callback:(void (^)(FlutterEngine *engine))callback
    {
    if([delegate respondsToSelector:@selector(engine)]){
        self.engine=delegate.engine;
    }else{
        self.engine=[[FlutterEngine alloc ] initWithName:@"io.flutter" project:nil] ;
    }
    
    NSString*  initialRoute=@"/";
    NSString*  dartEntrypointFunctionName=@"main";
    
    if([delegate respondsToSelector:@selector(dartEntrypointFunctionName)]){
        dartEntrypointFunctionName= delegate.dartEntrypointFunctionName ;
    }
    
    if([delegate respondsToSelector:@selector(initialRoute)] ){
        initialRoute =delegate.initialRoute ;
    }
    
    [self.engine runWithEntrypoint:dartEntrypointFunctionName  initialRoute : initialRoute];
    self.running=YES;
        
    if(callback){
        callback(self.engine);
    }

    Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
    SEL selector = NSSelectorFromString(@"registerWithRegistry:");
    if (clazz && selector && self.engine) {
        if ([clazz respondsToSelector:selector]) {
            ((void (*)(id, SEL, NSObject<FlutterPluginRegistry>*registry))[clazz methodForSelector:selector])(clazz, selector, self.engine);
        }
    }
        
    self.delegate=delegate;
    self.plugin= [FlutterBoostPlugin getPlugin:self.engine];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}


+ (instancetype)instance{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self.class new];
    });
    
    return _instance;
}

- (BOOL)isRunning{
    return  self.running;
}

#pragma mark - Some properties.

- (FlutterViewController *) currentViewController{
    return self.engine.viewController;
}

#pragma mark - open/close Page
- (void)open:(NSString *)pageName arguments:(NSDictionary *)arguments  {
   
    [[[FlutterBoost instance] delegate] pushFlutterRoute:pageName arguments:arguments];

}

- (void)close:(NSString *)uniqueId {
        FBCommonParams* params = [[FBCommonParams alloc] init];
        params.uniqueId=uniqueId;
        
        [[FlutterBoost instance].plugin.flutterApi popRoute:params completion:^(NSError* error) {
          } ];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    FBCommonParams* params = [[FBCommonParams alloc] init];
    [ [FlutterBoost instance].plugin.flutterApi onBackground: params completion:^(NSError * error) {
    
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    FBCommonParams* params = [[FBCommonParams alloc] init];
    [ [FlutterBoost instance].plugin.flutterApi onForeground:params completion:^(NSError * error) {
       
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

}

@end
