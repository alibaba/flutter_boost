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

@property (nonatomic,assign) BOOL isRunning;
@property(nonatomic, strong)  FlutterEngine*  engine;
@property(nonatomic, strong)  FlutterBoostPlugin*  plugin;
@property(nonatomic, strong) id<FlutterBoostDelegate> delegate;

@end

@implementation FlutterBoost

- (void) setup: (UIApplication*)application delegate:(id<FlutterBoostDelegate>)delegate callback: (void (^)(FlutterEngine *engine))callback
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
    
    if([ delegate respondsToSelector:@selector(initialRoute)] ){
        initialRoute =delegate.initialRoute ;
    }
    
    [self.engine runWithEntrypoint:dartEntrypointFunctionName  initialRoute : initialRoute];
    self.isRunning=YES;
    
    callback(self.engine);

    Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
    if (clazz && self.engine) {
        if ([clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
            [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                        withObject:self.engine];
        }
    }
        
    self.delegate=delegate;
    self.plugin= [self flutterBoostPlugin:self.engine];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (FlutterBoostPlugin* ) flutterBoostPlugin: (FlutterEngine* )engine {
    NSObject *published= [engine valuePublishedByPlugin:@"FlutterBoostPlugin" ];
    if ([published isKindOfClass:[FlutterBoostPlugin class]]) {
        FlutterBoostPlugin *plugin = (FlutterBoostPlugin *)published;
        return  plugin;
    }
    return nil;
}

+ (instancetype)instance{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self.class new];
    });
    
    return _instance;
}

- (FlutterEngine*)  getEngine{
    return  self.engine;
}

- (FlutterBoostPlugin*)   getPlugin{
    return  self.plugin;
}
- (id<FlutterBoostDelegate>)getDelegate{
    return  self.delegate;
}

#pragma mark - Some properties.

- (FlutterViewController *) currentViewController{
    return self.engine.viewController;
}

#pragma mark - open/close Page
- (void)open:(NSString *)pageName arguments:(NSDictionary *)arguments  {
   
        FBCommonParams* params = [[FBCommonParams alloc] init];
        params.pageName=pageName;
        params.arguments=arguments;
        [[FlutterBoost instance].delegate pushFlutterRoute:params ];

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

- (void)destroy{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

}

@end
