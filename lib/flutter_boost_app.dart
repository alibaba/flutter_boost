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

typedef WidgetBuild = Widget Function(
    String pageName, Map params, String uniqueId);

///
///
///
///
class FlutterBoostApp extends StatefulWidget {
  const FlutterBoostApp(Map<String, BoostPageRouteBuilder> routeMap,
      {FlutterBoostAppBuilder appBuilder, String initialRoute})
      : routeMap = routeMap,
        appBuilder = appBuilder ?? _materialAppBuilder,
        initialRoute = initialRoute ?? '/';

  final Map<String, BoostPageRouteBuilder> routeMap;
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

  Map<String, BoostPageRouteBuilder> get routeMap => widget.routeMap;

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
    if (widget.routeMap.containsKey(pageInfo.pageName)) {
      final BoostPageRouteBuilder builder = widget.routeMap[pageInfo.pageName];
      pageInfo.uniqueId ??= getUniqueId(pageInfo.pageName);
      return BoostPage<dynamic>(
          key: ValueKey(pageInfo.uniqueId),
          pageInfo: pageInfo,
          builder: builder);
    } else {
      return PageNameUnkonw();
    }
  }

  ///
  /// 生成UniqueId
  ///
  String getUniqueId(String pageName) {
    return '${DateTime.now().millisecondsSinceEpoch}_$pageName';
  }

  void push(String pageName, String uniqueId,
      {Map arguments, bool openContainer}) {
    final BoostPage existedPage = _findByUniqueId(uniqueId);
    Logger.log(
        'push page, uniqueId=$uniqueId, existedPage=$existedPage, openContainer=$openContainer, $pages');
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
        pages.last.navKey.currentState.pushNamed(pageName);
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
  BoostPage({LocalKey key, this.builder, this.pageInfo}) : super(key: key);

  final BoostPageRouteBuilder builder;
  final PageInfo pageInfo;

  GlobalKey<NavigatorState> navKey;

  GlobalKey<NavigatorState> keySave(
      String uniqueId, GlobalKey<NavigatorState> key) {
    navKey ??= key;
    return navKey;
  }

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder(
        settings: this,
        transitionDuration: builder.transitionDuration,
        reverseTransitionDuration: builder.reverseTransitionDuration,
        opaque: builder.opaque,
        barrierDismissible: builder.barrierDismissible,
        barrierColor: builder.barrierColor,
        barrierLabel: builder.barrierLabel,
        maintainState: builder.maintainState,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Navigator(
            key: keySave(pageInfo.uniqueId, GlobalKey<NavigatorState>()),
            onPopPage: (Route<dynamic> route, dynamic result) {
              return false;
            },
            initialRoute: pageInfo.pageName,
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute<T>(
                  settings: settings,
                  builder: (BuildContext context) {
                    return builder.widgetBuild(pageInfo.pageName,
                        pageInfo.arguments, pageInfo.uniqueId);
                  });
            },
          );
        },
        transitionsBuilder: builder.transitionsBuilder);

    // return MaterialPageRoute<T>(
    //     settings: this,
    //     builder: (BuildContext context) {
    //       return Navigator(
    //         key: keySave(pageInfo.uniqueId, GlobalKey<NavigatorState>()),
    //         onPopPage: (Route<dynamic> route, dynamic result) {
    //           return false;
    //         },
    //         initialRoute: pageInfo.pageName,
    //         onGenerateRoute: (RouteSettings settings) {
    //           return MaterialPageRoute<T>(
    //               settings: settings,
    //               builder: (BuildContext context) {
    //                 return builder.widgetBuild(pageInfo.pageName, pageInfo.arguments,
    //                     pageInfo.uniqueId);
    //               });
    //         },
    //       );
    //     });
  }
}

class BoostPageRouteBuilder {
  BoostPageRouteBuilder(
      {this.widgetBuild,
      this.transitionsBuilder = _defaultTransitionsBuilder,
      this.transitionDuration = const Duration(milliseconds: 300),
      this.reverseTransitionDuration = const Duration(milliseconds: 300),
      this.opaque = true,
      this.barrierDismissible = false,
      this.barrierColor,
      this.barrierLabel,
      this.maintainState = true});

  final WidgetBuild widgetBuild;

  final RouteTransitionsBuilder transitionsBuilder;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool opaque;

  @override
  final bool barrierDismissible;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  final bool maintainState;
}

Widget _defaultTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return child;
}

class PageNameUnkonw extends BoostPage<dynamic> {
  PageNameUnkonw() : super(key: const ValueKey('PageNameUnkonw'));

  @override
  Route<dynamic> createRoute(BuildContext context) {
    return MaterialPageRoute<dynamic>(
      settings: this,
      builder: (BuildContext context) {
        return Container(
          child: const Text('PageNameUnkonw'),
        );
      },
    );
  }
}
