// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
#import "messages.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSDictionary<NSString *, id> *wrapResult(id result, FlutterError *error) {
  NSDictionary *errorDict = (NSDictionary *)[NSNull null];
  if (error) {
    errorDict = @{
        @"code": (error.code ?: [NSNull null]),
        @"message": (error.message ?: [NSNull null]),
        @"details": (error.details ?: [NSNull null]),
        };
  }
  return @{
      @"result": (result ?: [NSNull null]),
      @"error": errorDict,
      };
}
static id GetNullableObject(NSDictionary* dict, id key) {
  id result = dict[key];
  return (result == [NSNull null]) ? nil : result;
}
static id GetNullableObjectAtIndex(NSArray* array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}

static NSString *const FBFlutterBoostBridgeName = @"com.idlefish.flutterboost.direct.FlutterBoostRouterApi";
static const int32_t FBFlutterBoostFastMessageKindRequest = 0;
static const int32_t FBMethodPushNativeRoute = 1;
static const int32_t FBMethodPushFlutterRoute = 2;
static const int32_t FBMethodPopNativeRoute = 3;
static const int32_t FBMethodGetStackFromHost = 4;
static const int32_t FBMethodSaveStackToHost = 5;
static const int32_t FBMethodSendEventToNative = 6;
static const int32_t FBMethodPushRoute = 101;
static const int32_t FBMethodPopRoute = 102;
static const int32_t FBMethodRemoveRoute = 103;
static const int32_t FBMethodOnForeground = 104;
static const int32_t FBMethodOnBackground = 105;
static const int32_t FBMethodOnNativeResult = 106;
static const int32_t FBMethodOnContainerShow = 107;
static const int32_t FBMethodOnContainerHide = 108;
static const int32_t FBMethodSendEventToFlutter = 109;
static const int32_t FBMethodOnBackPressed = 110;


@interface FBCommonParams ()
+ (FBCommonParams *)fromMap:(NSDictionary *)dict;
+ (nullable FBCommonParams *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FBStackInfo ()
+ (FBStackInfo *)fromMap:(NSDictionary *)dict;
+ (nullable FBStackInfo *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FBFlutterContainer ()
+ (FBFlutterContainer *)fromMap:(NSDictionary *)dict;
+ (nullable FBFlutterContainer *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FBFlutterPage ()
+ (FBFlutterPage *)fromMap:(NSDictionary *)dict;
+ (nullable FBFlutterPage *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FBFlutterRouterApi (NativeFastBridge)
+ (void)handleDartReply:(int64_t)replyId;
@end

@implementation FBCommonParams
+ (instancetype)makeWithOpaque:(nullable NSNumber *)opaque
    key:(nullable NSString *)key
    pageName:(nullable NSString *)pageName
    uniqueId:(nullable NSString *)uniqueId
    arguments:(nullable NSDictionary<NSString *, id> *)arguments {
  FBCommonParams* result = [[FBCommonParams alloc] init];
  result.opaque = opaque;
  result.key = key;
  result.pageName = pageName;
  result.uniqueId = uniqueId;
  result.arguments = arguments;
  return result;
}
+ (FBCommonParams *)fromMap:(NSDictionary *)dict {
  FBCommonParams *result = [[FBCommonParams alloc] init];
  result.opaque = GetNullableObject(dict, @"opaque");
  result.key = GetNullableObject(dict, @"key");
  result.pageName = GetNullableObject(dict, @"pageName");
  result.uniqueId = GetNullableObject(dict, @"uniqueId");
  result.arguments = GetNullableObject(dict, @"arguments");
  return result;
}
+ (nullable FBCommonParams *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [FBCommonParams fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"opaque" : (self.opaque ?: [NSNull null]),
    @"key" : (self.key ?: [NSNull null]),
    @"pageName" : (self.pageName ?: [NSNull null]),
    @"uniqueId" : (self.uniqueId ?: [NSNull null]),
    @"arguments" : (self.arguments ?: [NSNull null]),
  };
}
@end

@implementation FBStackInfo
+ (instancetype)makeWithIds:(nullable NSArray<NSString *> *)ids
    containers:(nullable NSDictionary<NSString *, FBFlutterContainer *> *)containers {
  FBStackInfo* result = [[FBStackInfo alloc] init];
  result.ids = ids;
  result.containers = containers;
  return result;
}
+ (FBStackInfo *)fromMap:(NSDictionary *)dict {
  FBStackInfo *result = [[FBStackInfo alloc] init];
  result.ids = GetNullableObject(dict, @"ids");
  result.containers = GetNullableObject(dict, @"containers");
  return result;
}
+ (nullable FBStackInfo *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [FBStackInfo fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"ids" : (self.ids ?: [NSNull null]),
    @"containers" : (self.containers ?: [NSNull null]),
  };
}
@end

@implementation FBFlutterContainer
+ (instancetype)makeWithPages:(nullable NSArray<FBFlutterPage *> *)pages {
  FBFlutterContainer* result = [[FBFlutterContainer alloc] init];
  result.pages = pages;
  return result;
}
+ (FBFlutterContainer *)fromMap:(NSDictionary *)dict {
  FBFlutterContainer *result = [[FBFlutterContainer alloc] init];
  result.pages = GetNullableObject(dict, @"pages");
  return result;
}
+ (nullable FBFlutterContainer *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [FBFlutterContainer fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"pages" : (self.pages ?: [NSNull null]),
  };
}
@end

@implementation FBFlutterPage
+ (instancetype)makeWithWithContainer:(nullable NSNumber *)withContainer
    pageName:(nullable NSString *)pageName
    uniqueId:(nullable NSString *)uniqueId
    arguments:(nullable NSDictionary<NSString *, id> *)arguments {
  FBFlutterPage* result = [[FBFlutterPage alloc] init];
  result.withContainer = withContainer;
  result.pageName = pageName;
  result.uniqueId = uniqueId;
  result.arguments = arguments;
  return result;
}
+ (FBFlutterPage *)fromMap:(NSDictionary *)dict {
  FBFlutterPage *result = [[FBFlutterPage alloc] init];
  result.withContainer = GetNullableObject(dict, @"withContainer");
  result.pageName = GetNullableObject(dict, @"pageName");
  result.uniqueId = GetNullableObject(dict, @"uniqueId");
  result.arguments = GetNullableObject(dict, @"arguments");
  return result;
}
+ (nullable FBFlutterPage *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [FBFlutterPage fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"withContainer" : (self.withContainer ?: [NSNull null]),
    @"pageName" : (self.pageName ?: [NSNull null]),
    @"uniqueId" : (self.uniqueId ?: [NSNull null]),
    @"arguments" : (self.arguments ?: [NSNull null]),
  };
}
@end

@interface FBNativeRouterApiCodecReader : FlutterStandardReader
@end
@implementation FBNativeRouterApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FBCommonParams fromMap:[self readValue]];
    
    case 129:     
      return [FBFlutterContainer fromMap:[self readValue]];
    
    case 130:     
      return [FBFlutterPage fromMap:[self readValue]];
    
    case 131:     
      return [FBStackInfo fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FBNativeRouterApiCodecWriter : FlutterStandardWriter
@end
@implementation FBNativeRouterApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FBCommonParams class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FBFlutterContainer class]]) {
    [self writeByte:129];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FBFlutterPage class]]) {
    [self writeByte:130];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FBStackInfo class]]) {
    [self writeByte:131];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FBNativeRouterApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FBNativeRouterApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FBNativeRouterApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FBNativeRouterApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FBNativeRouterApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FBNativeRouterApiCodecReaderWriter *readerWriter = [[FBNativeRouterApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


void FBNativeRouterApiSetup(NSObject<FBNativeRouterApi> *api) {
  if (!api) {
    [FlutterEngine setNativeFastMessageHandlerForBridgeName:FBFlutterBoostBridgeName handler:nil];
    return;
  }
  [FlutterEngine setNativeFastMessageHandlerForBridgeName:FBFlutterBoostBridgeName
                                                  handler:^(int method, NSData *_Nullable message, int64_t replyId) {
    if (replyId < 0) {
      [FBFlutterRouterApi handleDartReply:replyId];
      return;
    }

    NSObject<FlutterMessageCodec> *codec = FBNativeRouterApiGetCodec();
    id decoded = message ? [codec decode:message] : nil;
    NSDictionary *wrapped = nil;
    @try {
      switch (method) {
        case FBMethodPushNativeRoute: {
          NSArray *args = decoded;
          FBCommonParams *arg_param = GetNullableObjectAtIndex(args, 0);
          [api pushNativeRouteParam:arg_param];
          wrapped = wrapResult(nil, nil);
          [FlutterEngine returnNativeFastMessageToDartWithBridgeName:FBFlutterBoostBridgeName
                                                             replyId:replyId
                                                             message:[codec encode:wrapped]];
          break;
        }
        case FBMethodPushFlutterRoute: {
          NSArray *args = decoded;
          FBCommonParams *arg_param = GetNullableObjectAtIndex(args, 0);
          [api pushFlutterRouteParam:arg_param];
          wrapped = wrapResult(nil, nil);
          [FlutterEngine returnNativeFastMessageToDartWithBridgeName:FBFlutterBoostBridgeName
                                                             replyId:replyId
                                                             message:[codec encode:wrapped]];
          break;
        }
        case FBMethodPopNativeRoute: {
          NSArray *args = decoded;
          FBCommonParams *arg_param = GetNullableObjectAtIndex(args, 0);
          [api popRouteParam:arg_param completion:^(FlutterError *_Nullable error) {
            NSDictionary *result = wrapResult(nil, error);
            [FlutterEngine returnNativeFastMessageToDartWithBridgeName:FBFlutterBoostBridgeName
                                                               replyId:replyId
                                                               message:[codec encode:result]];
          }];
          break;
        }
        case FBMethodGetStackFromHost: {
          FBStackInfo *output = [api getStackFromHost];
          wrapped = wrapResult(output, nil);
          [FlutterEngine returnNativeFastMessageToDartWithBridgeName:FBFlutterBoostBridgeName
                                                             replyId:replyId
                                                             message:[codec encode:wrapped]];
          break;
        }
        case FBMethodSaveStackToHost: {
          NSArray *args = decoded;
          FBStackInfo *arg_stack = GetNullableObjectAtIndex(args, 0);
          [api saveStackToHostStack:arg_stack];
          wrapped = wrapResult(nil, nil);
          [FlutterEngine returnNativeFastMessageToDartWithBridgeName:FBFlutterBoostBridgeName
                                                             replyId:replyId
                                                             message:[codec encode:wrapped]];
          break;
        }
        case FBMethodSendEventToNative: {
          NSArray *args = decoded;
          FBCommonParams *arg_params = GetNullableObjectAtIndex(args, 0);
          [api sendEventToNativeParams:arg_params];
          wrapped = wrapResult(nil, nil);
          [FlutterEngine returnNativeFastMessageToDartWithBridgeName:FBFlutterBoostBridgeName
                                                             replyId:replyId
                                                             message:[codec encode:wrapped]];
          break;
        }
        default:
          wrapped = wrapResult(nil, [FlutterError errorWithCode:@"unknown-method"
                                                        message:[NSString stringWithFormat:@"Unknown NativeRouterApi method: %d", method]
                                                        details:nil]);
          [FlutterEngine returnNativeFastMessageToDartWithBridgeName:FBFlutterBoostBridgeName
                                                             replyId:replyId
                                                             message:[codec encode:wrapped]];
          break;
      }
    } @catch (NSException *exception) {
      FlutterError *error = [FlutterError errorWithCode:exception.name
                                                message:exception.reason
                                                details:exception.callStackSymbols];
      [FlutterEngine returnNativeFastMessageToDartWithBridgeName:FBFlutterBoostBridgeName
                                                         replyId:replyId
                                                         message:[codec encode:wrapResult(nil, error)]];
    }
  }];
}
@interface FBFlutterRouterApiCodecReader : FlutterStandardReader
@end
@implementation FBFlutterRouterApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FBCommonParams fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FBFlutterRouterApiCodecWriter : FlutterStandardWriter
@end
@implementation FBFlutterRouterApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FBCommonParams class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FBFlutterRouterApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FBFlutterRouterApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FBFlutterRouterApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FBFlutterRouterApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FBFlutterRouterApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FBFlutterRouterApiCodecReaderWriter *readerWriter = [[FBFlutterRouterApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


@interface FBFlutterRouterApi ()
@property (nonatomic, strong, nullable) FlutterEngine *flutterEngine;
@end

@implementation FBFlutterRouterApi

- (instancetype)initWithFlutterEngine:(FlutterEngine *)flutterEngine {
  self = [super init];
  if (self) {
    _flutterEngine = flutterEngine;
  }
  return self;
}

+ (NSMutableDictionary<NSNumber *, void (^)(void)> *)pendingReplies {
  static NSMutableDictionary<NSNumber *, void (^)(void)> *pendingReplies = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    pendingReplies = [[NSMutableDictionary alloc] init];
  });
  return pendingReplies;
}

+ (int64_t)nextReplyId {
  static int64_t nextReplyId = -1;
  return nextReplyId--;
}

+ (void)handleDartReply:(int64_t)replyId {
  NSNumber *key = @(replyId);
  void (^completion)(void) = [self pendingReplies][key];
  if (!completion) {
    return;
  }
  [[self pendingReplies] removeObjectForKey:key];
  completion();
}

- (void)invokeDartMethod:(int32_t)method message:(nullable id)message replyId:(int64_t)replyId {
  NSData *encoded = [FBFlutterRouterApiGetCodec() encode:message];
  [self.flutterEngine invokeNativeFastMessageToDartWithBridgeName:FBFlutterBoostBridgeName
                                                             kind:FBFlutterBoostFastMessageKindRequest
                                                           method:method
                                                          message:encoded
                                                          replyId:replyId];
}

- (void)invokeDartMethod:(int32_t)method
                 message:(nullable id)message
              completion:(void(^)(void))completion {
  int64_t replyId = [FBFlutterRouterApi nextReplyId];
  if (completion) {
    void (^reply)(void) = [^{
      completion();
    } copy];
    [FBFlutterRouterApi pendingReplies][@(replyId)] = reply;
  }
  [self invokeDartMethod:method message:message replyId:replyId];
}

- (void)pushRouteParam:(FBCommonParams *)arg_param {
  [self invokeDartMethod:FBMethodPushRoute message:@[arg_param ?: [NSNull null]] replyId:0];
}
- (void)popRouteParam:(FBCommonParams *)arg_param completion:(void(^)(void))completion {
  [self invokeDartMethod:FBMethodPopRoute message:@[arg_param ?: [NSNull null]] completion:completion];
}
- (void)removeRouteParam:(FBCommonParams *)arg_param completion:(void(^)(void))completion {
  [self invokeDartMethod:FBMethodRemoveRoute message:@[arg_param ?: [NSNull null]] completion:completion];
}
- (void)onForegroundParam:(FBCommonParams *)arg_param completion:(void(^)(void))completion {
  [self invokeDartMethod:FBMethodOnForeground message:@[arg_param ?: [NSNull null]] completion:completion];
}
- (void)onBackgroundParam:(FBCommonParams *)arg_param completion:(void(^)(void))completion {
  [self invokeDartMethod:FBMethodOnBackground message:@[arg_param ?: [NSNull null]] completion:completion];
}
- (void)onNativeResultParam:(FBCommonParams *)arg_param completion:(void(^)(void))completion {
  [self invokeDartMethod:FBMethodOnNativeResult message:@[arg_param ?: [NSNull null]] completion:completion];
}
- (void)onContainerShowParam:(FBCommonParams *)arg_param completion:(void(^)(void))completion {
  [self invokeDartMethod:FBMethodOnContainerShow message:@[arg_param ?: [NSNull null]] completion:completion];
}
- (void)onContainerHideParam:(FBCommonParams *)arg_param completion:(void(^)(void))completion {
  [self invokeDartMethod:FBMethodOnContainerHide message:@[arg_param ?: [NSNull null]] completion:completion];
}
- (void)sendEventToFlutterParam:(FBCommonParams *)arg_param completion:(void(^)(void))completion {
  [self invokeDartMethod:FBMethodSendEventToFlutter message:@[arg_param ?: [NSNull null]] completion:completion];
}
- (void)onBackPressedWithCompletion:(void(^)(void))completion {
  [self invokeDartMethod:FBMethodOnBackPressed message:nil completion:completion];
}
@end
