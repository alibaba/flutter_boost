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
  /// 判断是否是一个flutter 页面
  ///
  bool isFlutterPage(String pageName) {
    RouteSettings settings = RouteSettings(name: pageName);
    return appState.routeFactory(settings, null) != null;
  }

  ///
  /// push 一个page，并展示在栈顶
  /// openContainer=true 是指打开对用的native的容器。如android 的activity。
  /// 在当前页面是flutter页面时候，不打开容器，能提升用户体验
  ///
  void push(String pageName, {Map arguments, bool openContainer = false}) {
    if (isFlutterPage(pageName)) {
      if (openContainer) {
        CommonParams params = CommonParams()
          ..pageName = pageName
          ..arguments = arguments;
        appState.nativeRouterApi.pushFlutterRoute(params);
      } else {
        appState.push(pageName, null,
            arguments: arguments, openContainer: openContainer);
      }
    } else {
      CommonParams params = CommonParams()
        ..pageName = pageName
        ..arguments = arguments;
      appState.nativeRouterApi.pushNativeRoute(params);
    }
  }

  ///
  /// 根据uniqueId查找page ,移动到栈顶展示
  ///
  void show(String uniqueId) {
    final bool isShow = appState.show(uniqueId);
    if (!isShow) {}
  }

  ///
  /// 关闭一个页面
  /// 1.如果uniqueId 指定，关闭uniqueId对应的 page 和容器
  /// 2.如果未指定uniqueId，关闭栈顶页面，和页面对应的容器
  /// 注意：
  /// 1.每个page，都包含了一个自己的navigator，执行关闭时候先执行，
  /// 页面里面的navigator.pop ，让子路由pop.
  ///
  /// 2.执行关闭时候，页面内的子路由 maybePop=false ，才会关闭整个页面，
  /// 如果page有对应的容native 容器， 则会关闭容器
  /// page是否有容器，是打开时候的openContainer属性定的。
  ///
  void pop({String uniqueId}) {
    appState.pop(uniqueId: uniqueId);
  }

  ///
  ///获取当前栈顶页面的页面信息，包括uniqueId，pagename
  ///
  PageInfo getTopPageInfo() {
    return appState.pages.last?.pageInfo;
  }

  ///
  /// 获取页面总个数
  ///
  ///
  int pageSize() {
    return appState.pages.length;
  }
}

class PageInfo {
  PageInfo({this.pageName, this.uniqueId, this.arguments, this.openContainer});

  String pageName;
  String uniqueId;
  Map arguments;
  bool openContainer;
}
