import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost_app.dart';
///
///
/// boost 页面栈的操作和管理
///
///
class BoostNavigator {
  const BoostNavigator(this.appState, this.context);

  final FlutterBoostAppState appState;
  final BuildContext context;
  ///
  /// 获取 BoostNavigator
  ///
  static BoostNavigator of(BuildContext context,
      {FlutterBoostAppState appState}) {
    FlutterBoostAppState _appState;
    if (appState == null) {
      _appState = context.findAncestorStateOfType<FlutterBoostAppState>();
    } else {
      _appState = appState;
    }
    return BoostNavigator(_appState, context);
  }
  ///
  /// 判断是否是一个flutter 页面
  ///
  bool isFlutterPage(String pageName) {
    return appState.routeMap.containsKey(pageName);
  }
  ///
  /// push 一个page，并展示在栈顶
  ///
  void push(String pageName,
      {String uniqueId, Map arguments, bool openContainer = true}) {
    if (isFlutterPage(pageName)) {
      if (openContainer) {
        appState.nativeRouterApi.pushFlutterRoute(pageName, null, arguments);
      }
      appState.push(pageName, uniqueId: uniqueId, arguments: arguments,openContainer:openContainer);
    } else {
      appState.nativeRouterApi.pushNativeRoute(pageName, null, arguments);
    }
  }
  ///
  /// 1.根据uniqueId查找page ,如果已经存在，把对应的page移动到栈顶 。
  /// 如果不存在，新建page。并展示在栈顶
  /// 2.openContainer =false 时候。不再打开容器。
  ///
  void pushOrShowRoute(
      String pageName, String uniqueId, Map arguments, bool openContainer) {
    final bool isShow = appState.show(uniqueId);
    if (!isShow) {
      push(pageName,
          uniqueId: uniqueId, arguments: arguments, openContainer: false);
    }
  }
  ///
  /// 关闭一个页面
  /// 1.先执行该页面的navigator.pop
  /// 2.如果该页面的navigator.maybePop=false ，才会关闭整个页面，且关闭容器.
  ///
  void pop() {
    appState.pop();
  }
}
