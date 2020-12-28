
import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_channel.dart';
import 'package:flutter_boost/flutter_boost_app.dart';

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

  void pushRoute(String pageName, String uniqueId, Map arguments) {
      BoostNavigator.of(null,appState:appState).push(pageName,arguments:arguments);
  }

  void popRoute() {
    BoostNavigator.of(null,appState:appState).pop();
  }
  void pushOrShowRoute(String pageName,String uniqueId, Map arguments, bool openContainer) {
    BoostNavigator.of(null,appState:appState).pushOrShowRoute(pageName,uniqueId,arguments,openContainer);
  }

}

