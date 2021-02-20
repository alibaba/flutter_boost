import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost_app.dart';
import 'package:flutter_boost/messages.dart';

///
///
/// boost 页面栈的操作和管理
///
///
class BoostNavigator {
  const BoostNavigator(this.appState);

  final FlutterBoostAppState appState;

  ///
  /// 获取BoostNavigator实例
  ///
  static BoostNavigator of() {
    FlutterBoostAppState _appState;
    _appState = navigatorKey.currentContext
        .findAncestorStateOfType<FlutterBoostAppState>();
    return BoostNavigator(_appState);
  }

  ///
  /// 判断是否是一个flutter页面
  ///
  /// 如果路由表中有注册[pageName]，那么返回true；否则，返回false。
  ///
  bool isFlutterPage(String pageName) {
    return appState.routeFactory(RouteSettings(name: pageName), null) != null;
  }

  ///
  /// push 一个page，并展示在栈顶
  ///
  /// [withContainer]参数用来控制是否创建新的native容器（例如，android的Activity），
  /// 1. 如果[withContainer]参数的值为true，那么会创建一个Native容器，同时Dart侧会
  /// 为该页面创建一个嵌套的Navigator（[pageName]作为该嵌套Navigator的栈底），用于
  /// 维护复用该容器的所有页面。
  /// 2. 如果[withContainer]参数的值为false（当前正在显示的是一个Flutter页面），那么
  /// 会复用当前容器，[pageName]被压人嵌套Navigator中。
  ///

  Future<T> push<T extends Object>(String pageName,
      {Map arguments, bool withContainer = false}) {
    if (isFlutterPage(pageName)) {
      return appState.pushWithResult(pageName,
          arguments: arguments, withContainer: withContainer);
    } else {
      CommonParams params = CommonParams()
        ..pageName = pageName
        ..arguments = arguments;
      appState.nativeRouterApi.pushNativeRoute(params);
      return new Future(null);
    }
  }

  ///
  /// 关闭栈顶页面
  ///
  /// 注意：
  /// 1.每个带容器的页面，都包含了一个自己的navigator，用于维护复用该容器的所有页面。
  /// 执行关闭时，先执行页面里面的navigator.pop ，让子路由pop。
  ///
  /// 2.执行关闭时候，页面内的子路由 maybePop=false ，才会关闭整个页面，
  /// 如果page有对应的native容器， 则会一并关闭容器。page是否有容器，由push的
  /// withContainer参数决定。
  ///
  void pop<T extends Object>([T result]) {
    appState.popWithResult(result);
  }

  ///
  /// 从栈中删除指定的页面
  ///
  void remove(String uniqueId) {
    appState.remove(uniqueId);
  }

  ///
  ///获取当前栈顶页面的页面信息，包括uniqueId，pagename
  ///
  PageInfo getTopPageInfo() {
    return appState.getTopPageInfo();
  }

  ///
  /// 获取页面总个数
  ///
  /// 注意：通过原生Navigator.push打开的页面未被计入
  ///
  int pageSize() {
    return appState.pageSize();
  }
}

class PageInfo {
  PageInfo({this.pageName, this.uniqueId, this.arguments, this.withContainer});

  String pageName;
  String uniqueId;
  Map arguments;
  bool withContainer;
}
