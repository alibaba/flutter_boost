import 'package:flutter_boost/flutter_boost_app.dart';
import 'package:flutter_boost/messages.dart';

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
  void popRoute(CommonParams arg) {
    appState.pop(uniqueId: arg.uniqueId);
  }

  @override
  void onForeground(CommonParams arg) {
    appState.onForeground();
  }

  @override
  void onBackground(CommonParams arg) {
    appState.onBackground();
  }

  @override
  void onNativeViewShow(CommonParams arg) {
    appState.onNativeViewShow();
  }

  @override
  void onNativeViewHide(CommonParams arg) {
    appState.onNativeViewHide();
  }

  @override
  void removeRoute(CommonParams arg) {
    appState.remove(arg.uniqueId);
  }

  @override
  void onNativeResult(CommonParams arg) {
    appState.onNativeResult(arg);
  }

}
