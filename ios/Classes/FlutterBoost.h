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
#import "FlutterBoostDelegate.h"
#import "FlutterBoostPlugin.h"
#import "FBFlutterViewContainer.h"
#import "FlutterBoostDelegate.h"
#import "FlutterBoostPlugin.h"
#import "FBFlutterViewContainer.h"
#import "Options.h"
#import "messages.h"


@interface FlutterBoost : NSObject

#pragma mark

- (FlutterEngine*)engine;

- (FlutterBoostPlugin*)plugin;

- (FlutterViewController *)currentViewController;

#pragma mark

/// Boost全局单例
+ (instancetype)instance;

/// 初始化
/// @param application 全局Application实例，如未设置engine参数，则默认从Application做engine的绑定
/// @param delegate FlutterBoostDelegate的实例，用于实现Push和Pop的具体策略（Native侧如何Push，以及需要Push一个新的FlutterViewController时的具体动作），以及Engine的部分初始化策略
/// @param callback 初始化完成以后的回调，
/// TODO 设计需要再review下 callback并不是异步的感觉没有必要。
- (void)setup:(UIApplication*)application delegate:(id<FlutterBoostDelegate>)delegate callback:(void (^)(FlutterEngine *engine))callback;


/// 利用自定义配置进行初始化
/// @param application 全局Application实例，如未设置engine参数，则默认从Application做engine的绑定
/// @param delegate FlutterBoostDelegate的实例，用于实现Push和Pop的具体策略
/// @param callback 初始化完成以后的回调
/// @param options 启动的配置，如果需要自定义请使用此参数
- (void)setup:(UIApplication*)application delegate:(id<FlutterBoostDelegate>)delegate callback:(void (^)(FlutterEngine *engine))callback options:(FlutterBoostSetupOptions*)options;

/// 关闭页面，混合栈推荐使用的用于操作页面的接口
/// @param uniqueId 关闭的页面唯一ID符
- (void)close:(NSString *)uniqueId;

/// （ 已废弃，之后有新参数可能不支持此方法 ！！！ ）
/// 打开新页面（默认以push方式），混合栈推荐使用的用于操作页面的接口
/// 通过arguments可以设置为以present方式打开页面：arguments:@{@"present":@(YES)}
/// @param pageName 打开的页面资源定位符
/// @param arguments 传入页面的参数; 若有特殊逻辑，可以通过这个参数设置回调的id
/// @param completion 页面open操作完成的回调，注意，从原生调用此方法跳转此参数才会生效
- (void)open:(NSString *)pageName arguments:(NSDictionary *)arguments completion:(void(^)(BOOL)) completion;


/// （推荐使用）利用启动参数配置开启新页面
/// @param options 配置参数
- (void)open:(FlutterBoostRouteOptions* )options;


/// 将原生页面的数据回传到flutter侧的页面的的方法
/// @param pageName 这个页面在路由表中的名字，和flutter侧BoostNavigator.push(name)中的name一样
/// @param arguments 你想传的参数
- (void)sendResultToFlutterWithPageName:(NSString*)pageName arguments:(NSDictionary*) arguments;

/// 添加一个事件监听
/// @param listener FBEventListener类型的函数
/// @param key 事件标识符
/// @return 用于移除监听器的一个函数，直接调用此函数可以移除此监听器避免内存泄漏
- (FBVoidCallback)addEventListener:(FBEventListener)listener
                           forName:(NSString *)key;

/// 将自定义事件传递给flutter侧
/// @param key 事件的标识符
/// @param arguments 事件的参数
- (void)sendEventToFlutterWith:(NSString*)key arguments:(NSDictionary*)arguments;

/// 卸载引擎
- (void)unsetFlutterBoost;

@end

