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
@property(nonatomic, strong) FBStackInfo* stackInfo;
@end

@implementation FlutterBoostPlugin

- (void)addContainer:(id<FBFlutterContainer>)vc {
    [self.containerManager addUnique:vc];
    
}

- (void)removeContainer:(id<FBFlutterContainer>)vc {
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

-(void)pushNativeRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error {
    [self.delegate pushNativeRoute:input.pageName arguments:input.arguments];
}

-(void)pushFlutterRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error {
    [self.delegate pushFlutterRoute:input.pageName uniqueId:input.uniqueId arguments:input.arguments completion:^(BOOL completion) {
        //因为这里是flutter端开启新容器push一个页面，所以这里原生用不着，所以这里completion传一个空的即可
    }];
}

-(void)popRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error {
    if([self.containerManager containUniqueId:input.uniqueId]){
        [self.delegate  popRoute:input.uniqueId];
    };
}

-(nullable FBStackInfo *)getStackFromHost:(FlutterError *_Nullable *_Nonnull)error {
    return self.stackInfo;
}

-(void)saveStackToHost:(FBStackInfo*)input error:(FlutterError *_Nullable *_Nonnull)error {
    self.stackInfo = input;
}
@end



