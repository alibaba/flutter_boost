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

//此文件用用于配置FlutterBoost各种配置文件

///启动参数配置
@interface FlutterBoostSetupOptions : NSObject

///初始路由
@property (nonatomic, strong) NSString* initalRoute;

///dart 入口
@property (nonatomic, strong) NSString* dartEntryPoint;

///FlutterDartProject数据
@property (nonatomic, strong) FlutterDartProject* dartObject;

///是否提前预热引擎，如果提前预热引擎，可以减少第一次打开flutter页面的短暂白屏，以及字体大小跳动的现象
///默认值为YES
@property (nonatomic, assign) BOOL warmUpEngine;

///创建一个默认的Options对象
+ (FlutterBoostSetupOptions*)createDefault;

@end


///路由参数配置
@interface FlutterBoostRouteOptions : NSObject

///页面在路由表中的名字
@property(nonatomic, strong) NSString* pageName;

///参数
@property(nonatomic, strong) NSDictionary* arguments;

///参数回传的回调闭包，仅在原生->flutter页面的时候有用
@property(nonatomic, strong) void(^onPageFinished)(NSDictionary*);

///open方法完成后的回调，仅在原生->flutter页面的时候有用
@property(nonatomic, strong) void(^completion)(BOOL);

///代理内部会使用，原生往flutter open的时候此参数设为nil即可
@property(nonatomic, strong) NSString* uniqueId;

///这个页面是否透明 注意:default value = YES
@property(nonatomic,assign) BOOL opaque;
@end
