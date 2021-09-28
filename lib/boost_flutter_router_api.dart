import 'package:flutter_boost/container_overlay.dart';
import 'package:flutter_boost/boost_operation_queue.dart';

import 'flutter_boost_app.dart';
import 'messages.dart';

/// The MessageChannel counterpart on the Dart side.
class BoostFlutterRouterApi extends FlutterRouterApi {
  factory BoostFlutterRouterApi(FlutterBoostAppState appState) {
    if (_instance == null) {
      _instance = BoostFlutterRouterApi._(appState);
      FlutterRouterApi.setup(_instance);
    }
    return _instance;
  }

  BoostFlutterRouterApi._(this.appState);

  final FlutterBoostAppState appState;
  static BoostFlutterRouterApi _instance;

  @override
  void pushRoute(CommonParams arg) {
    _addInOperationQueueOrExcute(() {
      appState.pushContainer(arg.pageName,
          uniqueId: arg.uniqueId,
          arguments:
              Map<String, dynamic>.from(arg.arguments ?? <String, dynamic>{}));
    });
  }

  @override
  void popRoute(CommonParams arg) {
    _addInOperationQueueOrExcute(() {
      appState.pop(uniqueId: arg.uniqueId);
    });
  }

  @override
  void popUntilRoute(CommonParams arg) {
    _addInOperationQueueOrExcute(() {
      appState.popUntil(route: arg.pageName, uniqueId: arg.uniqueId);
    });
  }

  @override
  void onForeground(CommonParams arg) => appState.onForeground();

  @override
  void onBackground(CommonParams arg) => appState.onBackground();

  @override
  void removeRoute(CommonParams arg) {
    _addInOperationQueueOrExcute(() {
      appState.remove(arg.uniqueId);
    });
  }

  @override
  void onNativeResult(CommonParams arg) => appState.onNativeResult(arg);

  @override
  void onContainerHide(CommonParams arg) {
    _addInOperationQueueOrExcute(() {
      appState.onContainerHide(arg);
    });
  }

  @override
  void onContainerShow(CommonParams arg) {
    _addInOperationQueueOrExcute(() {
      appState.onContainerShow(arg);
    });
  }

  @override
  void onBackPressed() => appState.pop(onBackPressed: true);

  ///When native send msg to flutter,this method will be called
  @override
  void sendEventToFlutter(CommonParams arg) {
    _addInOperationQueueOrExcute(() {
      appState.onReceiveEventFromNative(arg);
    });
  }

  /// Add an [operation] in [BoostOperationQueue] if the [overlayKey.currentState] == null
  /// [operation] will execute if the [overlayKey.currentState] != null
  /// return the [operation] is added in queue or not
  void _addInOperationQueueOrExcute(Function operation) {
    if (operation == null) {
      return;
    }
    if (overlayKey.currentState == null) {
      BoostOperationQueue.instance.addPendingOperation(operation);
    } else {
      operation.call();
    }
  }
}
