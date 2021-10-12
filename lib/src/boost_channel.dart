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

  FlutterBoostAppState _appState;

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
    return _appState.addEventListener(key, listener);
  }

  ///Send a custom event to native with [key] and [args]
  ///Calls when flutter(here) wants to send event to native side
  void sendEventToNative(String key, Map args) {
    assert(key != null);

    args ??= {};

    var params = CommonParams()
      ..key = key
      ..arguments = args;
    _appState.nativeRouterApi.sendEventToNative(params);
  }

  /// enable iOS native pop gesture for container matching [containerId]
  void enablePopGesture({@required String containerId}) {
    assert(containerId != null && containerId.isNotEmpty);
    BoostChannel.instance.sendEventToNative(containerId, {
      'event': 'enablePopGesture',
      "args": {'enable': true}
    });
  }

  /// disable iOS native pop gesture for container matching [containerId]
  void disablePopGesture({@required String containerId}) {
    assert(containerId != null && containerId.isNotEmpty);
    BoostChannel.instance.sendEventToNative(containerId, {
      'event': 'enablePopGesture',
      "args": {'enable': false}
    });
  }
}
