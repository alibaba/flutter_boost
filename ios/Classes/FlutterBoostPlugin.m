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
#import "FBLifecycle.h"


@interface FlutterBoostPlugin ()<FBNativeRouterApi>
@property(nonatomic, strong) FBFlutterContainerManager* containerManager;
@property(nonatomic, strong) FBStackInfo* stackInfo;
@property(nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray<FBEventListener>*>* listenersTable;
@end

@implementation FlutterBoostPlugin


- (void)containerCreated:(id<FBFlutterContainer>)vc {
    [self.containerManager addContainer:vc forUniqueId:vc.uniqueIDString];
    if (self.containerManager.containerSize == 1) {
        [FBLifecycle resume];
    }
}

- (void)containerWillAppear:(id<FBFlutterContainer>)vc {
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.pageName = vc.name;
    params.arguments = vc.params;
    params.uniqueId = vc.uniqueId;
    params.opaque = [[NSNumber alloc] initWithBool:vc.opaque];

    [self.flutterApi pushRoute: params completion:^(NSError * e) {

    }];
    [self.containerManager activeContainer:vc forUniqueId:vc.uniqueIDString];
}

- (void)containerAppeared:(id<FBFlutterContainer>)vc {
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.uniqueId = vc.uniqueId;
    [self.flutterApi onContainerShow:params completion:^(NSError * e) {

    }];
}

- (void)containerDisappeared:(id<FBFlutterContainer>)vc {
    FBCommonParams* params = [[FBCommonParams alloc] init];
    params.uniqueId = vc.uniqueId;
    [self.flutterApi onContainerHide:params completion:^(NSError * e) {

    }];
}

- (void)containerDestroyed:(id<FBFlutterContainer>)vc {
    FBCommonParams* params =[[FBCommonParams alloc] init ];
    params.pageName = vc.name;
    params.arguments = vc.params;
    params.uniqueId = vc.uniqueId;
    [self.flutterApi removeRoute: params  completion:^(NSError * e) {

    }];
    [self.containerManager removeContainerByUniqueId:vc.uniqueIDString];
    if (self.containerManager.containerSize == 0) {
        [FBLifecycle pause];
    }
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
        _listenersTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)pushNativeRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error {
    [self.delegate pushNativeRoute:input.pageName arguments:input.arguments];
}

-(void)pushFlutterRoute:(FBCommonParams*)input error:(FlutterError *_Nullable *_Nonnull)error {
    FlutterBoostRouteOptions* options = [[FlutterBoostRouteOptions alloc]init];
    options.pageName = input.pageName;
    options.uniqueId = input.uniqueId;
    options.arguments = input.arguments;
    options.opaque = [input.opaque boolValue];

    //因为这里是flutter端开启新容器push一个页面，所以这里原生用不着，所以这里completion传一个空的即可
    options.completion = ^(BOOL completion) {

    };

    [self.delegate pushFlutterRoute: options];
}

-(void)popRoute:(nullable FBCommonParams *)input completion:(void(^)(FlutterError *_Nullable))completion
{
    if([self.containerManager findContainerByUniqueId:input.uniqueId]){
        //封装成options传回代理
        FlutterBoostRouteOptions* options = [[FlutterBoostRouteOptions alloc]init];
        options.pageName = input.pageName;
        options.uniqueId = input.uniqueId;
        options.arguments = input.arguments;
        options.completion = ^(BOOL ret) {
            completion(nil);
        };
        //调用代理回调给调用层
        [self.delegate popRoute:options];
    };
}

-(FBStackInfo *)getStackFromHost:(FlutterError *_Nullable *_Nonnull)error {
    if (self.stackInfo == nil) {
        return [[FBStackInfo alloc] init];
    }
    return self.stackInfo;
}

-(void)saveStackToHost:(FBStackInfo*)input error:(FlutterError *_Nullable *_Nonnull)error {
    self.stackInfo = input;
}

//flutter端将会调用此方法给native发送信息,所以这里将是接收事件的逻辑
- (void)sendEventToNative:(nonnull FBCommonParams *)input error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {

    NSString* key = input.key;
    NSDictionary* args = input.arguments;

    assert(key != nil);

    //如果arg是null，那么就生成一个空的字典传过去，避免null造成的崩溃
    if(args == nil){
        args = [NSDictionary dictionary];
    }

    //从总事件表中找到和key对应的事件监听者列表
    NSMutableArray* listeners = self.listenersTable[key];

    if(listeners == nil) return;

    for (FBEventListener listener in listeners) {
        listener(key,args);
    }
}

- (FBVoidCallback)addEventListener:(FBEventListener)listener
                           forName:(NSString *)key{
    assert(key != nil && listener != nil);

    NSMutableArray<FBEventListener>* listeners = self.listenersTable[key];
    if(listeners == nil){
        listeners = [[NSMutableArray alloc] init];
        self.listenersTable[key] = listeners;
    }

    [listeners addObject:listener];

    return ^{
        [listeners removeObject:listener];
    };
}

@end



