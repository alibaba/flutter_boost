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

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

typedef Widget PageBuilder(String pageName, Map params, String uniqueId);

class BoostPageRoute<T> extends MaterialPageRoute<T> {
  final String pageName;
  final String uniqueId;
  final Map params;
  final bool animated;
  final WidgetBuilder builder;
  final RouteSettings settings;

  final Set<VoidCallback> backPressedListeners = Set<VoidCallback>();

  BoostPageRoute(
      {this.pageName,
      this.params,
      this.uniqueId,
      this.animated,
      this.builder,
      this.settings})
      : super(builder: builder, settings: settings);

  static BoostPageRoute<T> of<T>(BuildContext context) {
    final Route<T> route = ModalRoute.of(context);
    if (route != null && route is BoostPageRoute<T>) {
      return route;
    } else {
      throw Exception('not in a BoostPageRoute');
    }
  }

  static BoostPageRoute<T> tryOf<T>(BuildContext context) {
    final Route<T> route = ModalRoute.of(context);
    if (route != null && route is BoostPageRoute<T>) {
      return route;
    } else {
      return null;
    }
  }
}
