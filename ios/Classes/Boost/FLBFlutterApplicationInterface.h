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
#import <Flutter/Flutter.h>
#import "FLBPlatform.h"
#import "FlutterBoost.h"
#import "FLBFlutterProvider.h"
#import "FLBFlutterContainer.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FLBFlutterApplicationInterface <NSObject>
@property (nonatomic,strong) id<FLBPlatform> platform;

- (id<FLBFlutterProvider>)flutterProvider;

- (void)startFlutterWithPlatform:(id<FLBPlatform>)platform
                      withEngine:(FlutterEngine* _Nullable)engine
                        withPluginRegisterred:(BOOL)registerPlugin
                         onStart:(void (^)(FlutterEngine *engine))callback;

- (FlutterViewController *)flutterViewController;

#pragma mark - Container Management
- (BOOL)contains:(id<FLBFlutterContainer>)vc;
- (void)addUniqueViewController:(id<FLBFlutterContainer>)vc;
- (void)removeViewController:(id<FLBFlutterContainer>)vc;
- (BOOL)isTop:(NSString *)pageId;
- (NSInteger)pageCount;

#pragma mark - App Control
- (void)pause;
- (void)resume;
- (void)inactive;
- (BOOL)isRunning;

#pragma mark - handle messages
- (void)close:(NSString *)uid
       result:(NSDictionary *)resultData
         exts:(NSDictionary *)exts
   completion:(void (^)(BOOL))completion;

- (void)open:(NSString *)uri
   urlParams:(NSDictionary *)urlParams
        exts:(NSDictionary *)exts
       onPageFinished:(void (^)(NSDictionary *))resultCallback
  completion:(void (^)(BOOL))completion;

- (void)attachToPreviousContainer;

- (void)didInitPageContainer:(NSString *)url
                      params:(NSDictionary *)urlParams
                    uniqueId:(NSString *)uniqueId;

- (void)willDeallocPageContainer:(NSString *)url
                          params:(NSDictionary *)params
                        uniqueId:(NSString *)uniqueId;

- (void)onShownContainerChanged:(NSString *)uniqueId
                         params:(NSDictionary *)params;

@end
NS_ASSUME_NONNULL_END


