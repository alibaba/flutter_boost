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



