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

@end

@implementation FlutterBoost

- (void) setup: (UIApplication*)application delegate:(id<FlutterBoostDelegate>)delegate{
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
    
    Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
    if (clazz && self.engine) {
        if ([clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
            [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                        withObject:self.engine];
        }
    }
    self.delegate=delegate;
    self.flutterBoostPlugin= [self flutterBoostPlugin:self.engine];
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

#pragma mark - Some properties.

- (BOOL)isRunning{
    return  self.isRunning;
}

- (FlutterViewController *) currentViewController{
    return self.engine.viewController;
}

#pragma mark - open/close Page
- (void)open:(NSString *)url urlParams:(NSDictionary *)urlParams  completion:(void (^)(BOOL))completion{
   
        FBCommonParams* params = [[FBCommonParams alloc] init];
        params.pageName=url;
        params.arguments=urlParams;
        [[FlutterBoost instance].delegate pushFlutterRoute:params present: FALSE completion:completion];
}

- (void)present:(NSString *)url urlParams:(NSDictionary *)urlParams  completion:(void (^)(BOOL))completion{
    
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.pageName=url;
    params.arguments=urlParams;
    
    [[FlutterBoost instance].delegate pushFlutterRoute:params present: YES completion:completion] ;
    
}

- (void)close:(NSString *)uniqueId result:(NSDictionary *)resultData completion:(void (^)(BOOL))completion{
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.uniqueId=uniqueId;
    [[FlutterBoost instance].delegate popRoute :params result: resultData completion:completion];
}

- (void)destroyPluginContext{
   
}

@end
