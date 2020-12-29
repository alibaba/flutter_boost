import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_channel.dart';
import 'package:flutter_boost/boost_flutter_router_api.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

typedef FlutterBoostAppBuilder = Widget Function(Widget home);

typedef PageBuilder = Widget Function(
    String pageName, Map params, String uniqueId);

///
///
///
///
class FlutterBoostApp extends StatefulWidget {
  const FlutterBoostApp(Map<String, PageBuilder> routeMap,
      {FlutterBoostAppBuilder appBuilder, String initialRoute})
      : routeMap = routeMap,
        appBuilder = appBuilder ?? _materialAppBuilder,
        initialRoute = initialRoute ?? '/';

  final Map<String, PageBuilder> routeMap;
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

  Map<String, PageBuilder> get routeMap => widget.routeMap;

  // final List<PageInfo> _stack = <PageInfo>[];
  //
  // List<PageInfo> get stack => _stack;
  //
  // void stackAdd(PageInfo pageInfo) {
  //   _stack.add(pageInfo);
  // }
  //
  // void stackRemove(PageInfo pageInfo) {
  //   _stack.add(pageInfo);
  // }

  // bool isNextFlutterPage(PageInfo pageInfo) {
  //   PageInfo pInfo = _stack.singleWhere((element) =>
  //   (element.location == pageInfo.location) && (element.page == pageInfo.page));
  //   for(; ;){
  //     if(pInfo==_stack.last){
  //       break;
  //     }
  //     _stack.removeLast();
  //   }
  //   _stack.removeLast();
  //   return  _stack?.last.location == PageLocation.flutter ;
  // }

  // bool isFlutterPageCurrent() {
  //   PageInfo pInfo = _stack.singleWhere((element) =>
  //   (element.location == pageInfo.location) && (element.page == pageInfo.page));
  //   for(; ;){
  //     if(pInfo==_stack.last){
  //       break;
  //     }
  //     _stack.removeLast();
  //   }
  //   return  _stack?.last.location == PageLocation.flutter ;
  // }
  @override
  void initState() {
    pages.add(_createPage(widget.initialRoute, null));
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
            key: _navigatorKey, pages: List.of(pages), onPopPage: _onPopPage)));
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    return false;
  }
  ///
  /// 创建页面
  Page _createPage(String pageName, Map arguments, {String uniqueId}) {
    if (widget.routeMap.containsKey(pageName)) {
      final PageBuilder builder = widget.routeMap[pageName];
      final String uId = uniqueId ?? _getUniqueId(pageName);
      return BoostPage<dynamic>(
          key: ValueKey(uId),
          name: pageName,
          uniqueId: uId,
          builder: builder,
          arguments: arguments);
    } else {
      return PageNameUnkonw();
    }
  }

  ///
  /// 生成UniqueId
  ///
  String _getUniqueId(String pageName) {
    return '__container_uniqueId_key__${DateTime.now().millisecondsSinceEpoch}-${pageName}';
  }

  void push(String pageName, {String uniqueId, Map arguments}) {
    setState(() {
      final Page page = _createPage(pageName, arguments, uniqueId: uniqueId);
      pages.add(page);
    });
  }
  ///
  /// 展示页面
  ///
  bool show(String uniqueId) {
    if (pages.last?.uniqueId == uniqueId) {
      return true;
    }
    final BoostPage page = pages
        .singleWhere((element) => element.uniqueId == uniqueId, orElse: () {});
    if (page != null) {
      pages.remove(page);
      pages.add(page);
      setState(() {});
      return true;
    } else {
      return false;
    }
  }
  ///
  /// 关闭操作
  ///
  void pop() async {
    final BoostPage page = pages.last;
    final bool r = await page.navKey.currentState.maybePop();
    if (!r) {
      setState(() {
        pages.removeLast();
        _nativeRouterApi.popRoute(null, null);
      });
    }
  }
}
///
/// boost定义的page
///
class BoostPage<T> extends Page<T> {
  BoostPage(
      {LocalKey key, this.name, this.builder, this.uniqueId, this.arguments})
      : super(key: key, name: name, arguments: arguments);

  @override
  final String name;
  final PageBuilder builder;
  final String uniqueId;
  @override
  final Map arguments;

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
            key: keySave(uniqueId, GlobalKey<NavigatorState>()),
            onPopPage: (Route<dynamic> route, dynamic result) {
              return false;
            },
            initialRoute: name,
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute<T>(
                  settings: settings,
                  builder: (BuildContext context) {
                    return builder(name, arguments, uniqueId);
                  });
            },
          );
        });
  }
}

// enum PageLocation {
//   native,
//   flutter,
// }
//
// class PageInfo {
//   PageInfo({this.location, BoostPage this.page});
//
//   final PageLocation location;
//   final BoostPage page;
// }
//

class PageNameUnkonw extends Page<dynamic> {
  const PageNameUnkonw() : super(key: const ValueKey('PageNameUnkonw'));

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
