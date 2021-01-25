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
  const FlutterBoostApp(FlutterBoostRouteFactory routeFactory,
      {FlutterBoostAppBuilder appBuilder, String initialRoute})
      : routeFactory = routeFactory,
        appBuilder = appBuilder ?? _materialAppBuilder,
        initialRoute = initialRoute ?? '/';

  final FlutterBoostRouteFactory routeFactory;
  final FlutterBoostAppBuilder appBuilder;
  final String initialRoute;

  static Widget _materialAppBuilder(Widget home) {
    return MaterialApp(home: home);
  }

  @override
  State<StatefulWidget> createState() => FlutterBoostAppState();
}

class FlutterBoostAppState extends State<FlutterBoostApp> {
  final List<BoostPage<dynamic>> pages = <BoostPage<dynamic>>[];
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
          BoostPage<dynamic> page = pages.last;
          bool r = page.navKey.currentState.canPop();
          if (r) {
            page.navKey.currentState.pop();
            return true;
          } else {
            return false;
          }
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
    return BoostPage<dynamic>(
        key: ValueKey(pageInfo.uniqueId),
        pageInfo: pageInfo,
        routeFactory: widget.routeFactory);
  }

  void push(String pageName, String uniqueId,
      {Map arguments, bool openContainer}) {
    final BoostPage existedPage = _findByUniqueId(uniqueId);
    Logger.log(
        'push page, uniqueId=$uniqueId, existedPage=$existedPage, openContainer=$openContainer, arguments:$arguments, $pages');
    if (existedPage != null) {
      if (!_isCurrentPage(uniqueId)) {
        setState(() {
          pages.remove(existedPage);
          pages.add(existedPage);
        });
      }
    } else {
      if (openContainer) {
        PageInfo pageInfo = PageInfo(
            pageName: pageName,
            uniqueId: uniqueId,
            arguments: arguments,
            openContainer: openContainer);
        final BoostPage page = _createPage(pageInfo);
        setState(() {
          pages.add(page);
        });
      } else {
        pages.last.navKey.currentState
            .pushNamed(pageName, arguments: arguments);
      }
    }
  }

  ///
  /// 展示页面
  ///
  bool show(String uniqueId) {
    if (_isCurrentPage(uniqueId)) {
      Logger.log(
          'show page, uniqueId=${uniqueId} ,pageName= ${pages.last?.pageInfo.pageName}');
      return true;
    }
    final BoostPage page = _findByUniqueId(uniqueId);
    if (page != null) {
      setState(() {
        pages.remove(page);
        pages.add(page);
        Logger.log(
            'show page, uniqueId=${uniqueId} ,pageName= ${page.pageInfo.pageName}');
      });
      return true;
    } else {
      return false;
    }
  }

  ///
  /// 关闭操作
  ///
  void pop({String uniqueId, Map arguments}) async {
    BoostPage page;
    if (uniqueId != null) {
      page = _findByUniqueId(uniqueId);
      if (page == null) {
        Logger.error('uniqueId=$uniqueId not find');
        return;
      }
    } else {
      page = pages.last;
    }
    final bool r = await page?.navKey?.currentState?.maybePop();
    if (!r) {
      setState(() {
        pages.remove(page);
        if (page.pageInfo.openContainer) {
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
    // Todo(rulong.crl): consider internal route
    PageLifecycleBinding.instance.onForeground(
        pages.last?.pageInfo.uniqueId, pages.last?.pageInfo.pageName);
  }

  void onBackground() {
    // Todo(rulong.crl): consider internal route
    PageLifecycleBinding.instance.onBackground(
        pages.last?.pageInfo.uniqueId, pages.last?.pageInfo.pageName);
  }

  void onAppear(CommonParams arg) {
    // Todo(rulong.crl): consider internal route
    PageLifecycleBinding.instance.onAppear(pages.last?.pageInfo.uniqueId,
        pages.last?.pageInfo.pageName, ChangeReason.values[arg.hint]);
  }

  void onDisappear(CommonParams arg) {
    // Todo(rulong.crl): consider internal route
    PageLifecycleBinding.instance.onDisappear(pages.last?.pageInfo.uniqueId,
        pages.last?.pageInfo.pageName, ChangeReason.values[arg.hint]);
  }

  bool _isCurrentPage(String uniqueId) {
    return pages.last?.pageInfo?.uniqueId == uniqueId;
  }

  BoostPage _findByUniqueId(String uniqueId) {
    return pages?.singleWhere(
        (BoostPage element) => element.pageInfo.uniqueId == uniqueId,
        orElse: () {});
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

  GlobalKey<NavigatorState> navKey;

  GlobalKey<NavigatorState> keySave(
      String uniqueId, GlobalKey<NavigatorState> key) {
    navKey ??= key;
    return navKey;
  }

  @override
  Route<T> createRoute(BuildContext context) {
    return MaterialPageRoute<T>(
        settings: this,
        builder: (BuildContext context) {
          return Navigator(
            key: keySave(pageInfo.uniqueId, GlobalKey<NavigatorState>()),
            onPopPage: (Route<dynamic> route, dynamic result) {
              return false;
            },
            initialRoute: pageInfo.pageName,
            onGenerateInitialRoutes:
                (NavigatorState navigator, String initialRoute) {
              final List<Route<dynamic>> result = <Route<dynamic>>[];
              RouteSettings settings = RouteSettings(
                  name: pageInfo.pageName, arguments: pageInfo.arguments);
              result.add(routeFactory(settings, pageInfo.uniqueId));
              return result;
            },
            onGenerateRoute: (RouteSettings settings) {
              return routeFactory(settings, getUniqueId(settings.name));
            },
          );
        });
  }
}
