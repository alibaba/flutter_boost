// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'boost_operation_queue.dart';
import 'flutter_boost_app.dart';
import 'messages.dart';

/// The MessageChannel counterpart on the Dart side.
class BoostFlutterRouterApi extends FlutterRouterApi {
  factory BoostFlutterRouterApi(FlutterBoostAppState appState) {
    if (_instance == null) {
      _instance = BoostFlutterRouterApi._(appState);
      FlutterRouterApi.setup(_instance);
    }
    return _instance!;
  }

  BoostFlutterRouterApi._(this.appState);

  final FlutterBoostAppState appState;
  static BoostFlutterRouterApi? _instance;

  /// Whether the dart env is ready to receive messages from host.
  bool isEnvReady = false;

  @override
  void pushRoute(CommonParams param) {
    _addInOperationQueueOrExcute(() {
      appState.pushWithInterceptor(
          param.pageName, true /* isFromHost */, true /* isFlutterPage */,
          withContainer: true,
          uniqueId: param.uniqueId,
          arguments: Map<String, dynamic>.from(
              param.arguments ?? <String, dynamic>{}));
    });
  }

  @override
  void popRoute(CommonParams param) {
    _addInOperationQueueOrExcute(() {
      appState.pop(uniqueId: param.uniqueId);
    });
  }

  void popUntilRoute(CommonParams param) {
    _addInOperationQueueOrExcute(() {
      appState.popUntil(route: param.pageName, uniqueId: param.uniqueId);
    });
  }

  @override
  void onForeground(CommonParams param) => appState.onForeground();

  @override
  void onBackground(CommonParams param) => appState.onBackground();

  @override
  void removeRoute(CommonParams param) {
    _addInOperationQueueOrExcute(() {
      appState.remove(param.uniqueId);
    });
  }

  @override
  void onNativeResult(CommonParams param) => appState.onNativeResult(param);

  @override
  void onContainerHide(CommonParams param) {
    _addInOperationQueueOrExcute(() {
      appState.onContainerHide(param);
    });
  }

  @override
  void onContainerShow(CommonParams param) {
    _addInOperationQueueOrExcute(() {
      appState.onContainerShow(param);
    });
  }

  @override
  void onBackPressed() => appState.pop(onBackPressed: true);

  ///When native send msg to flutter,this method will be called
  @override
  void sendEventToFlutter(CommonParams param) {
    _addInOperationQueueOrExcute(() {
      appState.onReceiveEventFromNative(param);
    });
  }

  /// If [isEnvReady] is false, add [operation] into pending queue,
  /// or [operation] will execute immediately.
  void _addInOperationQueueOrExcute(Function operation) {
    if (!isEnvReady) {
      BoostOperationQueue.instance.addPendingOperation(operation);
    } else {
      operation.call();
    }
  }
}
