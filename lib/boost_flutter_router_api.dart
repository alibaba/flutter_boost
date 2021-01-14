import 'package:flutter_boost/boost_navigator.dart';
import 'package:flutter_boost/flutter_boost_app.dart';
import 'package:flutter_boost/messages.dart';

///
///
/// native测调用 flutter的接口实现
///
///
class BoostFlutterRouterApi extends FlutterRouterApi {
  BoostFlutterRouterApi(this.appState);

  final FlutterBoostAppState appState;
  static BoostFlutterRouterApi _instance;

  static BoostFlutterRouterApi instance(FlutterBoostAppState appState) {
    if (_instance == null) {
      _instance = BoostFlutterRouterApi(appState);
      FlutterRouterApi.setup(_instance);
    }

    return _instance;
  }

  ///
  /// push 一个页面
  ///
  @override
  void pushRoute(CommonParams arg) {
    appState.push(arg.pageName, arg.uniqueId,
        arguments: arg.arguments, openContainer: true);
  }

  ///
  ///关闭页面
  ///
  @override
  void popRoute(CommonParams arg) {
    BoostNavigator.of().pop(uniqueId: arg.uniqueId);
  }
}
