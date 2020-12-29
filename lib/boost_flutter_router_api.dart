
import 'package:flutter_boost/boost_channel.dart';
import 'package:flutter_boost/boost_navigator.dart';
import 'package:flutter_boost/flutter_boost_app.dart';
///
///
/// native测调用 flutter的接口实现
///
///
class BoostFlutterRouterApi extends FlutterRouterApi {
  BoostFlutterRouterApi(this.appState);
  final FlutterBoostAppState appState;
  static BoostFlutterRouterApi _instance;

  static BoostFlutterRouterApi  instance(FlutterBoostAppState appState) {
    if (_instance == null) {
      _instance = BoostFlutterRouterApi(appState);
      FlutterRouterApi.setup(_instance);
    }
    return _instance;
  }
  ///
  /// push 一个页面
  ///
  void pushRoute(String pageName, String uniqueId, Map arguments) {
      BoostNavigator.of(null,appState:appState).push(pageName,arguments:arguments);
  }
  ///
  ///关闭页面
  ///
  void popRoute() {
    BoostNavigator.of(null,appState:appState).pop();
  }
  ///
  /// push 一个 指定uniqueId的页面，并展示在栈最顶
  ///
  ///
  void pushOrShowRoute(String pageName,String uniqueId, Map arguments, bool openContainer) {
    BoostNavigator.of(null,appState:appState).pushOrShowRoute(pageName,uniqueId,arguments,openContainer);
  }

}

