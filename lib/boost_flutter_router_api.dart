// import 'package:flutter_boost/boost_channel.dart';
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
    BoostNavigator.of(null, appState: appState)
        .push(arg.pageName, arguments: arg.arguments);
  }

  ///
  ///关闭页面
  ///
  @override
  void popRoute() {
    BoostNavigator.of(null, appState: appState).pop();
  }

  ///
  /// push 一个 指定uniqueId的页面，并展示在栈最顶
  ///
  ///
  @override
  void pushOrShowRoute(CommonParams arg) {
    BoostNavigator.of(null, appState: appState).pushOrShowRoute(
        arg.pageName, arg.uniqueId,
        arguments: arg.arguments, openContainer: arg.openContainer);
  }

  @override
  void showTabRoute(CommonParams arg) {
    final bool isShow = appState.show(arg.uniqueId);
    if (!isShow) {
      appState.push(arg.pageName,
          uniqueId: arg.uniqueId,
          arguments: arg.arguments,
          openContainer: true,
          groupName: arg.groupName);
    }
  }
}
