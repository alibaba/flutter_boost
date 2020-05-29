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

typedef EventListener = Future<dynamic> Function(
    String name, Map<String, dynamic> arguments);

typedef MethodHandler = Future<dynamic> Function(MethodCall call);

class BoostChannel {
  BoostChannel() {
    _methodChannel.setMethodCallHandler((MethodCall call) {
      if (call.method == '__event__') {
        final String name = call.arguments['name'] as String;
        final Map<String, dynamic> arg =
            (call.arguments['arguments'] as Map<dynamic, dynamic>)
                ?.cast<String, dynamic>();
        final List<EventListener> list = _eventListeners[name];
        if (list != null) {
          for (final EventListener l in list) {
            l(name, arg);
          }
        }
      } else {
        for (final MethodHandler handler in _methodHandlers) {
          handler(call);
        }
      }

      return Future<dynamic>.value();
    });
  }

  final MethodChannel _methodChannel = const MethodChannel('flutter_boost');

  final Map<String, List<EventListener>> _eventListeners =
      <String, List<EventListener>>{};
  final Set<MethodHandler> _methodHandlers = <MethodHandler>{};

  void sendEvent(String name, Map<String, dynamic> arguments) {
    if (name == null) {
      return;
    }

    arguments ??= <String, dynamic>{};

    final Map<String, dynamic> msg = <String, dynamic>{};
    msg['name'] = name;
    msg['arguments'] = arguments;
    _methodChannel.invokeMethod<dynamic>('__event__', msg);
  }

  Future<T> invokeMethod<T>(String method, [dynamic arguments]) async {
    assert(method != '__event__');

    return _methodChannel.invokeMethod<T>(method, arguments);
  }

  Future<List<T>> invokeListMethod<T>(String method,
      [dynamic arguments]) async {
    assert(method != '__event__');

    return _methodChannel.invokeListMethod<T>(method, arguments);
  }

  Future<Map<K, V>> invokeMapMethod<K, V>(String method,
      [dynamic arguments]) async {
    assert(method != '__event__');

    return _methodChannel.invokeMapMethod<K, V>(method, arguments);
  }

  VoidCallback addEventListener(String name, EventListener listener) {
    assert(name != null && listener != null);

    List<EventListener> list;
    list = _eventListeners[name];

    if (list == null) {
      list = <EventListener>[];
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
