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
    appState.push(arg.pageName,
        uniqueId: arg.uniqueId,
        arguments:
            Map<String, dynamic>.from(arg.arguments ?? <String, dynamic>{}),
        withContainer: true);
  }

  @override
  void popRoute(CommonParams arg) => appState.pop(uniqueId: arg.uniqueId);

  @override
  void onForeground(CommonParams arg) => appState.onForeground();

  @override
  void onBackground(CommonParams arg) => appState.onBackground();

  @override
  void removeRoute(CommonParams arg) => appState.remove(arg.uniqueId);

  @override
  void onNativeResult(CommonParams arg) => appState.onNativeResult(arg);

  @override
  void onContainerHide(CommonParams arg) => appState.onContainerHide(arg);

  @override
  void onContainerShow(CommonParams arg) => appState.onContainerShow(arg);

  ///When native send msg to flutter,this method will be called
  @override
  void sendEventToFlutter(CommonParams arg) =>
      appState.onReceiveEventFromNative(arg);
}
