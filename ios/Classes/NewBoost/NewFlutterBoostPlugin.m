//
//  FlutterBoostPlugin.m
//  flutter_boost
//
//  Created by wubian on 2021/1/20.
//
#import <Foundation/Foundation.h>
#import "NewFlutterBoostPlugin.h"
#import "messages.h"
@interface NewFlutterBoostPlugin ()<FBNativeRouterApi>
//@property(nonatomic, strong) FBFlutterRouterApi* flutterApi;
@end

@implementation NewFlutterBoostPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>  *)registrar {
    NewFlutterBoostPlugin* plugin = [[NewFlutterBoostPlugin alloc] initWithMessenger:(registrar.messenger)];
    [registrar publish:plugin];
    FBNativeRouterApiSetup(registrar.messenger, plugin);
}


-(instancetype)initWithMessenger:(id<FlutterBinaryMessenger>)messenger {
  self = [super init];
  if (self) {
    _flutterApi = [[FBFlutterRouterApi alloc] initWithBinaryMessenger:messenger];
  }
  return self;
}

-(void)pushNativeRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error{
    

    if(self.pushNativeHandler){
        self.pushNativeHandler(input);
    }else{
        *error = [FlutterError errorWithCode:@"FlutterBoostPlugin" message:@"no handler set" details:nil];
    }
}
-(void)pushFlutterRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error{
    if(self.pushFlutterHandler){
        self.pushFlutterHandler(input);
    }else{
        *error=[FlutterError errorWithCode:@"FlutterBoostPlugin" message:@"no handler set" details:nil];
    }
}
-(void)popRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error{
    if (self.popHandler) {
      self.popHandler(input);
    } else {
      *error = [FlutterError errorWithCode:@"FlutterBoostPlugin" message:@"no handler set" details:nil];
    }
}

@end



