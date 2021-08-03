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
#import "messages.h"
#import "Options.h"
#import <Flutter/Flutter.h>


@protocol  FlutterBoostDelegate <NSObject>

@optional
- (FlutterEngine*) engine;
@required

///如果框架发现您输入的路由表在flutter里面注册的路由表中找不到，那么就会调用此方法来push一个纯原生页面
- (void) pushNativeRoute:(NSString *) pageName arguments:(NSDictionary *) arguments;

///当框架的withContainer为true的时候，会调用此方法来做原生的push
- (void) pushFlutterRoute:(FlutterBoostRouteOptions *)options;

///当pop调用涉及到原生容器的时候，此方法将会被调用
- (void) popRoute:(FlutterBoostRouteOptions *)options;

@end

