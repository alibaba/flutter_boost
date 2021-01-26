//
//  FlutterBoost.m
//  flutter_boost
//
//  Created by wubian on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "NewFlutterBoost.h"
#import "NewFlutterBoostPlugin.h"
@interface NewFlutterBoost ()

@property(nonatomic, copy) id<FlutterBoostDelegate> delegate;
@property(nonatomic, copy)  NewFlutterBoostPlugin*  flutterBoostPlugin;
@property (nonatomic,assign) BOOL isRunning;

@end

@implementation NewFlutterBoost

- (void) setup: (UIApplication*)application delegate:(id<FlutterBoostDelegate>)delegate{
    if(delegate.engine){
        self.engine=delegate.engine;
    }else{
        self.engine=[[FlutterEngine alloc ] initWithName:@"io.flutter" project:nil] ;
    }
    [self.engine runWithEntrypoint:delegate.dartEntrypointFunctionName  initialRoute : delegate.initialRoute];
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

- (NewFlutterBoostPlugin* ) flutterBoostPlugin: (FlutterEngine* )engine {
    NSObject *published= [engine valuePublishedByPlugin:@"NewFlutterBoostPlugin" ];
    if ([published isKindOfClass:[NewFlutterBoostPlugin class]]) {
        NewFlutterBoostPlugin *plugin = (NewFlutterBoostPlugin *)published;
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
        [[NewFlutterBoost instance].delegate pushFlutterRoute:params present: FALSE completion:completion];
}

- (void)present:(NSString *)url urlParams:(NSDictionary *)urlParams  completion:(void (^)(BOOL))completion{
    
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.pageName=url;
    params.arguments=urlParams;
    
    [[NewFlutterBoost instance].delegate pushFlutterRoute:params present: YES completion:completion] ;
    
}

- (void)close:(NSString *)uniqueId result:(NSDictionary *)resultData completion:(void (^)(BOOL))completion{
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.uniqueId=uniqueId;
    [[NewFlutterBoost instance].delegate popRoute :params result: resultData completion:completion];
}

- (void)destroyPluginContext{
   
}

@end
