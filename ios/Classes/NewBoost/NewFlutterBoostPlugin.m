//
//  FlutterBoostPlugin.m
//  flutter_boost
//
//  Created by wubian on 2021/1/20.
//
#import <Foundation/Foundation.h>
#import "NewFlutterBoostPlugin.h"
#import "messages.h"
#import "NewFlutterBoost.h"
#import "FLBFlutterContainerManager.h"


@interface NewFlutterBoostPlugin ()<FBNativeRouterApi>
//@property(nonatomic, strong) FBFlutterRouterApi* flutterApi;

@property(nonatomic, strong) FLBFlutterContainerManager* containerManager;


@end

@implementation NewFlutterBoostPlugin

- (void)addContainer:(id<FLBFlutterContainer>)vc{
    [self.containerManager addUnique:vc];
    
}

- (void)removeContainer:(id<FLBFlutterContainer>)vc{
    [self.containerManager remove:vc];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>  *)registrar {
    NewFlutterBoostPlugin* plugin = [[NewFlutterBoostPlugin alloc] initWithMessenger:(registrar.messenger)];
    [registrar publish:plugin];
    FBNativeRouterApiSetup(registrar.messenger, plugin);
    
}


-(instancetype)initWithMessenger:(id<FlutterBinaryMessenger>)messenger {
  self = [super init];
  if (self) {
    _flutterApi = [[FBFlutterRouterApi alloc] initWithBinaryMessenger:messenger];
    _containerManager= [FLBFlutterContainerManager new];
  }
  return self;
}

-(void)pushNativeRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error{
    
    [[NewFlutterBoost instance].delegate pushNativeRoute:input present:FALSE completion:^(BOOL finished) {
    
    }];
    
//    *error = [FlutterError errorWithCode:@"FlutterBoostPlugin" message:@"no handler set" details:nil];

}
-(void)pushFlutterRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error{
    
    [[NewFlutterBoost instance].delegate pushFlutterRoute:input present: FALSE completion:^(BOOL finished) {
    }] ;

}

-(void)popRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error{
    if([_containerManager containUniqueId:input.uniqueId]){
        [[NewFlutterBoost instance].delegate  popRoute: input result: nil completion:^(BOOL finished) {
        
        }];
    };
}

@end



