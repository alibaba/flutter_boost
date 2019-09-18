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
#import <Flutter/Flutter.h>

#import "FLBPlatform.h"
#import "FLBTypes.h"

@interface FlutterBoostPlugin : NSObject<FlutterPlugin>
#pragma mark - Initializer
+ (instancetype)sharedInstance;

/**
 * 初始化FlutterBoost混合栈环境。应在程序使用混合栈之前调用。如在AppDelegate中
 *
 * @param platform 平台层实现FLBPlatform的对象
 * @param callback 启动之后回调
 */
- (void)startFlutterWithPlatform:(id<FLBPlatform>)platform
                         onStart:(void (^)(FlutterEngine *engine))callback;

#pragma mark - Some properties.
- (BOOL)isRunning;

- (FlutterViewController *)currentViewController;

#pragma mark - broadcast event to/from flutter
- (void)sendEvent:(NSString *)eventName
        arguments:(NSDictionary *)arguments;

- (FLBVoidCallback)addEventListener:(FLBEventListener)listner
                            forName:(NSString *)name;

#pragma mark - open/close Page

/**
 * 关闭页面，混合栈推荐使用的用于操作页面的接口
 *
 * @param uniqueId 关闭的页面唯一ID符
 * @param resultData 页面要返回的结果（给上一个页面），会作为页面返回函数的回调参数
 * @param exts 额外参数
 * @param completion 关闭页面的即时回调，页面一旦关闭即回调
 */
+ (void)close:(NSString *)uniqueId
       result:(NSDictionary *)resultData
         exts:(NSDictionary *)exts
   completion:(void (^)(BOOL))completion;

/**
 * 打开新页面（默认以push方式），混合栈推荐使用的用于操作页面的接口；通过urlParams可以设置为以present方式打开页面：urlParams:@{@"present":@(YES)}
 *
 * @param url 打开的页面资源定位符
 * @param urlParams 传人页面的参数; 若有特殊逻辑，可以通过这个参数设置回调的id
 * @param exts 额外参数
 * @param resultCallback 当页面结束返回时执行的回调，通过这个回调可以取得页面的返回数据，如close函数传入的resultData
 * @param completion 打开页面的即时回调，页面一旦打开即回调
 */
+ (void)open:(NSString *)url
   urlParams:(NSDictionary *)urlParams
        exts:(NSDictionary *)exts
       onPageFinished:(void (^)(NSDictionary *))resultCallback
  completion:(void (^)(BOOL))completion;

/**
 * Present方式打开新页面，混合栈推荐使用的用于操作页面的接口
 *
 * @param url 打开的页面资源定位符
 * @param urlParams 传人页面的参数; 若有特殊逻辑，可以通过这个参数设置回调的id
 * @param exts 额外参数
 * @param resultCallback 当页面结束返回时执行的回调，通过这个回调可以取得页面的返回数据，如close函数传入的resultData
 * @param completion 打开页面的即时回调，页面一旦打开即回调
 */
+ (void)present:(NSString *)url
   urlParams:(NSDictionary *)urlParams
        exts:(NSDictionary *)exts
onPageFinished:(void (^)(NSDictionary *))resultCallback
  completion:(void (^)(BOOL))completion;
@end
