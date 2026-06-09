// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
#import <Foundation/Foundation.h>
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterEngine;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class FBCommonParams;
@class FBStackInfo;
@class FBFlutterContainer;
@class FBFlutterPage;

@interface FBCommonParams : NSObject
+ (instancetype)makeWithOpaque:(nullable NSNumber *)opaque
    key:(nullable NSString *)key
    pageName:(nullable NSString *)pageName
    uniqueId:(nullable NSString *)uniqueId
    arguments:(nullable NSDictionary<NSString *, id> *)arguments;
@property(nonatomic, strong, nullable) NSNumber * opaque;
@property(nonatomic, copy, nullable) NSString * key;
@property(nonatomic, copy, nullable) NSString * pageName;
@property(nonatomic, copy, nullable) NSString * uniqueId;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, id> * arguments;
@end

@interface FBStackInfo : NSObject
+ (instancetype)makeWithIds:(nullable NSArray<NSString *> *)ids
    containers:(nullable NSDictionary<NSString *, FBFlutterContainer *> *)containers;
@property(nonatomic, strong, nullable) NSArray<NSString *> * ids;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, FBFlutterContainer *> * containers;
@end

@interface FBFlutterContainer : NSObject
+ (instancetype)makeWithPages:(nullable NSArray<FBFlutterPage *> *)pages;
@property(nonatomic, strong, nullable) NSArray<FBFlutterPage *> * pages;
@end

@interface FBFlutterPage : NSObject
+ (instancetype)makeWithWithContainer:(nullable NSNumber *)withContainer
    pageName:(nullable NSString *)pageName
    uniqueId:(nullable NSString *)uniqueId
    arguments:(nullable NSDictionary<NSString *, id> *)arguments;
@property(nonatomic, strong, nullable) NSNumber * withContainer;
@property(nonatomic, copy, nullable) NSString * pageName;
@property(nonatomic, copy, nullable) NSString * uniqueId;
@property(nonatomic, strong, nullable) NSDictionary<NSString *, id> * arguments;
@end

/// The codec used by FBNativeRouterApi.
NSObject<FlutterMessageCodec> *FBNativeRouterApiGetCodec(void);

@protocol FBNativeRouterApi
- (void)pushNativeRouteParam:(FBCommonParams *)param;
- (void)pushFlutterRouteParam:(FBCommonParams *)param;
- (void)popRouteParam:(FBCommonParams *)param completion:(void(^)(FlutterError *_Nullable))completion;
- (nullable FBStackInfo *)getStackFromHost;
- (void)saveStackToHostStack:(FBStackInfo *)stack;
- (void)sendEventToNativeParams:(FBCommonParams *)params;
@end

extern void FBNativeRouterApiSetup(NSObject<FBNativeRouterApi> *_Nullable api);

/// The codec used by FBFlutterRouterApi.
NSObject<FlutterMessageCodec> *FBFlutterRouterApiGetCodec(void);

@interface FBFlutterRouterApi : NSObject
- (instancetype)initWithFlutterEngine:(FlutterEngine *)flutterEngine;
- (void)pushRouteParam:(FBCommonParams *)param;
- (void)popRouteParam:(FBCommonParams *)param completion:(void(^)(void))completion;
- (void)removeRouteParam:(FBCommonParams *)param completion:(void(^)(void))completion;
- (void)onForegroundParam:(FBCommonParams *)param completion:(void(^)(void))completion;
- (void)onBackgroundParam:(FBCommonParams *)param completion:(void(^)(void))completion;
- (void)onNativeResultParam:(FBCommonParams *)param completion:(void(^)(void))completion;
- (void)onContainerShowParam:(FBCommonParams *)param completion:(void(^)(void))completion;
- (void)onContainerHideParam:(FBCommonParams *)param completion:(void(^)(void))completion;
- (void)sendEventToFlutterParam:(FBCommonParams *)param completion:(void(^)(void))completion;
- (void)onBackPressedWithCompletion:(void(^)(void))completion;
@end
NS_ASSUME_NONNULL_END
