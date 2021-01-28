import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_boost/messages.dart';
import 'package:flutter_boost/boost_flutter_router_api.dart';
import 'package:flutter_boost/logger.dart';
import 'package:flutter_boost/boost_navigator.dart';
import 'package:flutter_boost/page_lifecycle.dart';

final navigatorKey = GlobalKey<NavigatorState>();

typedef FlutterBoostAppBuilder = Widget Function(Widget home);

typedef FlutterBoostRouteFactory = Route<dynamic> Function(
    RouteSettings settings, String uniqueId);

///
/// 生成UniqueId
///
String getUniqueId(String pageName) {
  return '${DateTime.now().millisecondsSinceEpoch}_$pageName';
}

///
///
///
///
class FlutterBoostApp extends StatefulWidget {
  const FlutterBoostApp(this.routeFactory,
      {FlutterBoostAppBuilder appBuilder, String initialRoute, this.observers})
      : appBuilder = appBuilder ?? _materialAppBuilder,
        initialRoute = initialRoute ?? '/';

  final FlutterBoostRouteFactory routeFactory;
  final FlutterBoostAppBuilder appBuilder;
  final List<NavigatorObserver> observers;
  final String initialRoute;

  static Widget _materialAppBuilder(Widget home) {
    return MaterialApp(home: home);
  }

  @override
  State<StatefulWidget> createState() => FlutterBoostAppState();
}

class FlutterBoostAppState extends State<FlutterBoostApp> {
  final List<BoostPageWithNavigator<dynamic>> pages = [];
  BoostFlutterRouterApi _boostFlutterRouterApi;
  NativeRouterApi _nativeRouterApi;

  NativeRouterApi get nativeRouterApi => _nativeRouterApi;

  BoostFlutterRouterApi get boostFlutterRouterApi => _boostFlutterRouterApi;

  FlutterBoostRouteFactory get routeFactory => widget.routeFactory;

  @override
  void initState() {
    pages.add(_createPage(PageInfo(pageName: widget.initialRoute)));
    _nativeRouterApi = NativeRouterApi();
    _boostFlutterRouterApi = BoostFlutterRouterApi.instance(this);
    super.initState();
  }

  ///     1. onWillPop 先从父层收到事件，再到子层.
  ///     当子层返回 false 时候。父的maybePop 才会true.
  ///     当子层返回 true 时候。父的maybePop 才会false.
  ///
  @override
  Widget build(BuildContext context) {
    return widget.appBuilder(WillPopScope(
        onWillPop: () async {
          BoostPageWithNavigator<dynamic> page = pages.last;
          bool canPop = page.navKey.currentState.canPop();
          if (canPop) {
            page.navKey.currentState.pop();
            return true;
          }
          return false;
        },
        child: Navigator(
            key: navigatorKey, pages: List.of(pages), onPopPage: _onPopPage)));
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    return false;
  }

  ///
  /// 创建页面
  BoostPage _createPage(PageInfo pageInfo) {
    pageInfo.uniqueId ??= getUniqueId(pageInfo.pageName);
    return BoostPageWithNavigator<dynamic>(
        key: ValueKey(pageInfo.uniqueId),
        pageInfo: pageInfo,
        routeFactory: widget.routeFactory,
        observers: widget.observers);
  }

  void push(String pageName,
      {String uniqueId, Map arguments, bool withContainer}) {
    final BoostPageWithNavigator existedPage = _findByUniqueId(uniqueId);
    Logger.log(
        'push page, uniqueId=$uniqueId, existedPage=$existedPage, withContainer=$withContainer, arguments:$arguments, $pages');
    if (existedPage != null) {
      if (pages.last?.pageInfo?.uniqueId != uniqueId) {
        setState(() {
          pages.remove(existedPage);
          pages.add(existedPage);
        });
      }
    } else {
      PageInfo pageInfo = PageInfo(
          pageName: pageName,
          uniqueId: uniqueId ?? getUniqueId(pageName),
          arguments: arguments,
          withContainer: withContainer);
      if (withContainer) {
        setState(() {
          pages.add(_createPage(pageInfo));
        });
      } else {
        setState(() {
          pages.last.pages
              .add(BoostPage.create(pageInfo, pages.last.routeFactory));
        });
      }
    }
  }

  ///
  /// 关闭操作
  ///
  void pop({String uniqueId, Map arguments}) async {
    BoostPageWithNavigator page;
    if (uniqueId != null) {
      page = _findByUniqueId(uniqueId);
      if (page == null) {
        Logger.error('uniqueId=$uniqueId not find');
        return;
      }
    } else {
      page = pages.last;
    }
    final bool handled = await page?.navKey?.currentState?.maybePop();
    if (handled != null && !handled) {
      setState(() {
        pages.remove(page);
        if (page.pageInfo.withContainer) {
          Logger.log('pop container ,  uniqueId=${page.pageInfo.uniqueId}');
          CommonParams params = CommonParams()
            ..pageName = page.pageInfo.pageName
            ..uniqueId = page.pageInfo.uniqueId
            ..arguments = arguments;
          _nativeRouterApi.popRoute(params);
        }
      });
    }
  }

  void onForeground() {
    PageLifecycleBinding.instance.onForeground(_getCurrentPage());
  }

  void onBackground() {
    PageLifecycleBinding.instance.onBackground(_getCurrentPage());
  }

  String _getCurrentPage() {
    return pages.last?.pages.last?.pageInfo?.uniqueId;
  }

  bool _isCurrentPage(String uniqueId) {
    return pages.last?.pageInfo?.uniqueId == uniqueId;
  }

  BoostPageWithNavigator _findByUniqueId(String uniqueId) {
    return pages.singleWhere(
        (BoostPageWithNavigator element) =>
            element.pageInfo.uniqueId == uniqueId,
        orElse: () {});
  }

  void remove(String uniqueId) {
    if (uniqueId == null) return;
    setState(() {
      pages.forEach((entry) {
        entry.pages.forEach((element) {
          if (element.pageInfo?.uniqueId == uniqueId) {
            entry.pages.remove(element);
            if (entry.pages.isEmpty) {
              pages.remove(entry);
            }
            return;
          }
        });
      });
    });
  }

  PageInfo getTopPageInfo() {
    BoostPageWithNavigator topOfOuterNavigator = pages.last;
    return topOfOuterNavigator?.pages.last?.pageInfo;
  }

  int pageSize() {
    int count = 0;
    pages.forEach((entry) {
      count += entry.pages.length;
    });
    return count;
  }
}

///
/// boost定义的page
///
class BoostPage<T> extends Page<T> {
  BoostPage({LocalKey key, this.routeFactory, this.pageInfo})
      : super(key: key, name: pageInfo.pageName, arguments: pageInfo.arguments);

  final FlutterBoostRouteFactory routeFactory;
  final PageInfo pageInfo;

  static BoostPage create(
      PageInfo pageInfo, FlutterBoostRouteFactory routeFactory) {
    return BoostPage<dynamic>(
        key: UniqueKey(), pageInfo: pageInfo, routeFactory: routeFactory);
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'BoostPage')}(name:$name, uniqueId:${pageInfo.uniqueId}, arguments:$arguments)';

  @override
  Route<T> createRoute(BuildContext context) {
    return routeFactory(this, pageInfo.uniqueId);
  }
}

class _BoostNavigatorObserver extends NavigatorObserver {
  final List<NavigatorObserver> observers;
  _BoostNavigatorObserver(this.observers);

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    observers?.forEach((element) {
      element.didPush(route, previousRoute);
    });
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    observers?.forEach((element) {
      element.didPop(route, previousRoute);
    });
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    observers?.forEach((element) {
      element.didRemove(route, previousRoute);
    });
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    observers?.forEach((element) {
      element.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    });
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
    observers?.forEach((element) {
      element.didStartUserGesture(route, previousRoute);
    });
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    observers?.forEach((element) {
      element.didStopUserGesture();
    });
    super.didStopUserGesture();
  }
}

class BoostPageWithNavigator<T> extends BoostPage<T> {
  BoostPageWithNavigator(
      {LocalKey key,
      FlutterBoostRouteFactory routeFactory,
      PageInfo pageInfo,
      this.observers})
      : super(key: key, routeFactory: routeFactory, pageInfo: pageInfo) {
    pages.add(BoostPage.create(pageInfo, routeFactory));
  }

  final List<BoostPage<dynamic>> pages = <BoostPage<dynamic>>[];
  final List<NavigatorObserver> observers;
  GlobalKey<NavigatorState> navKey;

  GlobalKey<NavigatorState> keySave(
      String uniqueId, GlobalKey<NavigatorState> key) {
    navKey ??= key;
    return navKey;
  }

  void _updatePagesList() {
    pages.removeLast();
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'BoostPageWithNavigator')}(name:$name, uniqueId:${pageInfo.uniqueId}, arguments:$arguments)';

  @override
  Route<T> createRoute(BuildContext context) {
    return MaterialPageRoute<T>(
        settings: this,
        builder: (BuildContext context) {
          return Navigator(
            key: keySave(pageInfo.uniqueId, GlobalKey<NavigatorState>()),
            pages: List.of(pages),
            onPopPage: (route, result) {
              if (route.didPop(result)) {
                _updatePagesList();
                return true;
              }
              return false;
            },
            observers: [
              _BoostNavigatorObserver(observers),
            ],
          );
        });
  }
}
