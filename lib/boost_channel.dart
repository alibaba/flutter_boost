import 'package:flutter/cupertino.dart';

import 'flutter_boost_app.dart';
import 'messages.dart';
import 'overlay_entry.dart';

typedef EventListener = Future<dynamic> Function(String key, Map arguments);

///The [BoostChannel] is a tool to get [FlutterBoostAppState] to operate the Custom events
///We can get this by calling "BoostChannel.instance"
class BoostChannel {
  BoostChannel._();

  static final BoostChannel _instance = BoostChannel._();

  FlutterBoostAppState _appState;

  static BoostChannel get instance {
    _instance._appState ??= overlayKey.currentContext
        ?.findAncestorStateOfType<FlutterBoostAppState>();
    return _instance;
  }

  ///Add event listener in flutter side, which is to listen the events from native side
  ///The [VoldCallBack] is to remove this listener
  VoidCallback addEventListener(String key, EventListener listener) {
    return _appState.addEventListener(key, listener);
  }

  ///Send a custom event to native with [key] and [args]
  ///Calls when flutter(here) wants to send event to native side
  void sendEventToNative(String key, Map args) {
    assert(key != null);

    args ??= {};

    CommonParams params = CommonParams()
      ..key = key
      ..arguments = args;
    _appState.nativeRouterApi.sendEventToNative(params);
  }
}
