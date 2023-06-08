// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

import 'container_overlay.dart';
import 'flutter_boost_app.dart';
import 'messages.dart';

typedef EventListener = Future<dynamic> Function(String key, Map arguments);

/// The [BoostChannel] is a tool to get [FlutterBoostAppState]
/// to operate the Custom events
///
/// We can get this by calling "BoostChannel.instance"
class BoostChannel {
  BoostChannel._();

  ///The singleton for [BoostChannel]
  static final BoostChannel _instance = BoostChannel._();

  FlutterBoostAppState? _appState;

  static BoostChannel get instance {
    _instance._appState ??= overlayKey.currentContext
        ?.findAncestorStateOfType<FlutterBoostAppState>();
    return _instance;
  }

  /// Add event listener in flutter side, which is to listen
  /// the events from native side
  ///
  /// The [VoldCallBack] is to remove this listener
  VoidCallback addEventListener(String key, EventListener listener) {
    assert(
        _appState != null, 'Please check if the engine has been initialized!');
    return _appState!.addEventListener(key, listener);
  }

  ///Send a custom event to native with [key] and [args]
  ///Calls when flutter(here) wants to send event to native side
  void sendEventToNative(String key, Map<String, Object> args) {
    assert(
        _appState != null, 'Please check if the engine has been initialized!');
    var params = CommonParams()
      ..key = key
      ..arguments = args;
    _appState!.nativeRouterApi.sendEventToNative(params);
  }

  /// enable iOS native pop gesture for container matching [containerId]
  void enablePopGesture({required String containerId}) {
    assert(containerId.isNotEmpty);
    BoostChannel.instance.sendEventToNative(containerId, {
      'event': 'enablePopGesture',
      "args": {'enable': true}
    });
  }

  /// disable iOS native pop gesture for container matching [containerId]
  void disablePopGesture({required String containerId}) {
    assert(containerId.isNotEmpty);
    BoostChannel.instance.sendEventToNative(containerId, {
      'event': 'enablePopGesture',
      "args": {'enable': false}
    });
  }
}
