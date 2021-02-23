//
//  FlutterBoostPlugin.m
//  flutter_boost
//
//  Created by wubian on 2021/1/20.
//
#import <Foundation/Foundation.h>
#import "FlutterBoostPlugin.h"
#import "messages.h"
#import "FlutterBoost.h"
#import "FBFlutterContainerManager.h"


@interface FlutterBoostPlugin ()<FBNativeRouterApi>

@property(nonatomic, strong) FBFlutterContainerManager* containerManager;

@end

@implementation FlutterBoostPlugin

- (void)addContainer:(id<FBFlutterContainer>)vc{
    [self.containerManager addUnique:vc];
    
}

- (void)removeContainer:(id<FBFlutterContainer>)vc{
    [self.containerManager remove:vc];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>  *)registrar {
    FlutterBoostPlugin* plugin = [[FlutterBoostPlugin alloc] initWithMessenger:(registrar.messenger)];
    [registrar publish:plugin];
    FBNativeRouterApiSetup(registrar.messenger, plugin);
    
}

+ (FlutterBoostPlugin* )getPlugin:(FlutterEngine*)engine{
    NSObject *published = [engine valuePublishedByPlugin:@"FlutterBoostPlugin"];
    if ([published isKindOfClass:[FlutterBoostPlugin class]]) {
        FlutterBoostPlugin *plugin = (FlutterBoostPlugin *)published;
        return plugin;
    }
    return nil;
}


-(instancetype)initWithMessenger:(id<FlutterBinaryMessenger>)messenger {
  self = [super init];
  if (self) {
    _flutterApi = [[FBFlutterRouterApi alloc] initWithBinaryMessenger:messenger];
    _containerManager= [FBFlutterContainerManager new];
  }
  return self;
}

-(void)pushNativeRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error{
    
    [[[FlutterBoost instance] delegate] pushNativeRoute:input.pageName arguments:input.arguments];
    
}
-(void)pushFlutterRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error{
    
    [[[FlutterBoost instance] delegate] pushFlutterRoute:input.pageName arguments:input.arguments] ;

}

-(void)popRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error{
    if([self.containerManager containUniqueId:input.uniqueId]){
        [[[FlutterBoost instance] delegate] popRoute:input.uniqueId];
    };
}

@end



