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

import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

typedef Future<dynamic> EventListener(String name, Map arguments);
typedef Future<dynamic> MethodHandler(MethodCall call);

class BoostChannel {
  final MethodChannel _methodChannel = MethodChannel("flutter_boost");

  final Map<String, List<EventListener>> _eventListeners = Map();
  final Set<MethodHandler> _methodHandlers = Set();

  BoostChannel() {
    _methodChannel.setMethodCallHandler((MethodCall call) {
      if (call.method == "__event__") {
        String name = call.arguments["name"];
        Map arg = call.arguments["arguments"];
        List<EventListener> list = _eventListeners[name];
        if (list != null) {
          for (EventListener l in list) {
            l(name, arg);
          }
        }
      } else {
        for (MethodHandler handler in _methodHandlers) {
          handler(call);
        }
      }

      return Future<dynamic>.value();
    });
  }

  void sendEvent(String name, Map arguments) {
    if (name == null) {
      return;
    }

    if (arguments == null) {
      arguments = Map<dynamic, dynamic>();
    }

    Map msg = Map<dynamic, dynamic>();
    msg["name"] = name;
    msg["arguments"] = arguments;
    _methodChannel.invokeMethod<dynamic>("__event__", msg);
  }

  Future<T> invokeMethod<T>(String method, [dynamic arguments]) async {
    assert(method != "__event__");

    return _methodChannel.invokeMethod<T>(method, arguments);
  }

  Future<List<T>> invokeListMethod<T>(String method,
      [dynamic arguments]) async {
    assert(method != "__event__");

    return _methodChannel.invokeListMethod<T>(method, arguments);
  }

  Future<Map<K, V>> invokeMapMethod<K, V>(String method,
      [dynamic arguments]) async {
    assert(method != "__event__");

    return _methodChannel.invokeMapMethod<K, V>(method, arguments);
  }

  VoidCallback addEventListener(String name, EventListener listener) {
    assert(name != null && listener != null);

    List<EventListener> list = _eventListeners[name];
    if (list == null) {
      list = List();
      _eventListeners[name] = list;
    }

    list.add(listener);

    return () {
      list.remove(listener);
    };
  }

  VoidCallback addMethodHandler(MethodHandler handler) {
    assert(handler != null);

    _methodHandlers.add(handler);

    return () {
      _methodHandlers.remove(handler);
    };
  }
}
