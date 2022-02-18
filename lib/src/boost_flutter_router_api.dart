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
    return _instance;
  }

  BoostFlutterRouterApi._(this.appState);

  final FlutterBoostAppState appState;
  static BoostFlutterRouterApi _instance;

  /// Whether the dart env is ready to receive messages from host.
  bool isEnvReady = false;

  @override
  void pushRoute(CommonParams arg) {
    _addInOperationQueueOrExcute(() {
      appState.pushWithInterceptor(
          arg.pageName, true /* isFromHost */, true /* isFlutterPage */,
          withContainer: true,
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

  /// If [isEnvReady] is false, add [operation] into pending queue,
  /// or [operation] will execute immediately.
  void _addInOperationQueueOrExcute(Function operation) {
    if (operation == null) {
      return;
    }
    if (!isEnvReady) {
      BoostOperationQueue.instance.addPendingOperation(operation);
    } else {
      operation.call();
    }
  }
}
