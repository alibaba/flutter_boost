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

@implementation NewFlutterBoost
//- DefaultEngineConfig withDefaultEngine ;
//- init:()

//public final static String ENGINE_ID = "flutter_boost_default_engine";

- (void) setup: (UIApplication*)application delegate:(FlutterBoostDelegate*)delegate{
    _engine=[[FlutterEngine alloc ] initWithName:@"io.flutter" project:nil] ;
    [_engine runWithEntrypoint:delegate.dartEntrypointFunctionName  initialRoute : delegate.initialRoute];

    Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
    if (clazz && _engine) {
        if ([clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
            [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                        withObject:_engine];
        }
    }
//


    _flutterBoostPlugin= [self flutterBoostPlugin:_engine];
    _flutterBoostPlugin.popHandler=delegate.popHandler;
    _flutterBoostPlugin.pushFlutterHandler=delegate.pushFlutterHandler;
    _flutterBoostPlugin.pushNativeHandler=delegate.pushNativeHandler;
    
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



@end
