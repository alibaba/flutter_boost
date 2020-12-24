import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_channel.dart';
import 'package:flutter_boost/boost_flutter_router_api.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

typedef FlutterBoostAppBuilder = Widget Function(Widget home);

typedef PageBuilder = Widget Function(
    String pageName, Map params, String uniqueId);


class FlutterBoostApp extends StatefulWidget {
  final FlutterBoostAppBuilder appBuilder;
  final Map<String, PageBuilder> routeMap;
  final String initialRoute;

  FlutterBoostApp(Map<String, PageBuilder> routeMap,
      {FlutterBoostAppBuilder appBuilder, String initialRoute})
      : routeMap = routeMap,
        appBuilder = appBuilder ?? _materialAppBuilder,
        initialRoute = initialRoute ?? '/';

  static Widget _materialAppBuilder(Widget home) {
    return MaterialApp(home: home);
  }

  @override
  State<StatefulWidget> createState() => FlutterBoostAppState();
}

class FlutterBoostAppState extends State<FlutterBoostApp> {
  final List<Page<dynamic>> pages = <Page<dynamic>>[];
  BoostFlutterRouterApi _boostFlutterRouterApi;
  NativeRouterApi _nativeRouterApi;

  NativeRouterApi get nativeRouterApi => _nativeRouterApi;

  BoostFlutterRouterApi get boostFlutterRouterApi => _boostFlutterRouterApi;

  Map<String, PageBuilder> get routeMap => widget.routeMap;
  final List<PageInfo>  _stack = <PageInfo>[];
  List<PageInfo>  get stack=>_stack;

  void stackAdd(PageInfo pageInfo) {
    _stack.add(pageInfo);
  }
  void stackRemove(PageInfo pageInfo) {
    _stack.add(pageInfo);
  }
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
    return widget.appBuilder(

        WillPopScope(
            onWillPop: () async {
              ///1.当page 的navigator 还能pop 时候 ,ispop=false
              // bool ispop=await _navigatorKey.currentState.maybePop();
              // if(!ispop){
              //   return true;
              // }
              // if(ispop){
              //   return false;
              // }

              BoostPage page = pages.last as BoostPage;
              bool r = page.navKey.currentState.canPop();
              if (r) {
                page.navKey.currentState.pop();
                return true;
              } else {
                return false;
              }
              // return !await _navigatorKey.currentState.maybePop();
            },
            child: Navigator(
                key: _navigatorKey,
                pages: List.of(pages),
                onPopPage: _onPopPage
            )
        )

    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    // setState(() => pages.remove(route.settings));
    // return route.didPop(result);
    return false;
  }

  Page _createPage(String pageName, Map arguments) {
    if (widget.routeMap.containsKey(pageName)) {
      PageBuilder builder = widget.routeMap[pageName];
      String uniqueId = _getUniqueId(pageName);
      return BoostPage(key: ValueKey(uniqueId),
          name: pageName,
          uniqueId: uniqueId,
          builder: builder,
          arguments: arguments);
    } else {
      return PageNameUnkonw();
    }
  }

  String _getUniqueId(String pageName) {
    return '__container_uniqueId_key__${DateTime
        .now()
        .millisecondsSinceEpoch}-${pageName}';
  }

  void _push(String pageName, {Map arguments}) {
    setState(() {
      Page page = _createPage(pageName, arguments);
      pages.add(page);
      // stackAdd(PageInfo(location:PageLocation.flutter, page: page));
    });
  }

  void pop() async {
    BoostPage page = pages.last as BoostPage;
    bool r = await page.navKey.currentState.maybePop();
    if (!r) {
      setState(() {
        Page page = pages.removeLast();

        _nativeRouterApi.popRoute(null, null);

      });
    }
  }
}

class BoostNavigator {
  final FlutterBoostAppState appState;
  final BuildContext context;

  BoostNavigator(this.appState, this.context);

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

  bool isFlutterPage(String pageName) {
    return appState.routeMap.containsKey(pageName);
  }

  void push(String pageName, {Map arguments, bool openContainer = true}) {
    if (isFlutterPage(pageName)) {

      appState.nativeRouterApi.pushFlutterRoute(pageName, null, arguments);
      appState._push(pageName, arguments: arguments);
    } else {
      appState.nativeRouterApi.pushNativeRoute(pageName, null, arguments);
      // appState.stackAdd(PageInfo(location: PageLocation.native,page: null));
    }
  }

  void pop() {
    appState.pop();
  }
}

class BoostPage extends Page<dynamic> {
  final PageBuilder builder;
  final String name;
  final Map arguments;
  final String uniqueId;

  BoostPage({
    @required LocalKey key,
    @required String this.name,
    @required this.builder,
    @required String this.uniqueId,
    Map this.arguments
  }) : super(key: key, name: name);

  Future<bool> _onBackPressed(BuildContext context) {
    return new Future(() {
      BoostNavigator.of(context).pop();
      return false;
    });
  }

  GlobalKey<NavigatorState> navKey;

  GlobalKey<NavigatorState> keySave(String uniqueId,
      GlobalKey<NavigatorState> key) {
    if (navKey == null) {
      navKey = key;
    }
    return navKey;
  }

  Route createRoute(BuildContext context) {
    return MaterialPageRoute <dynamic>(
        settings: this,
        builder: (BuildContext context) {
          // return WillPopScope(
          //   onWillPop: ()async {
          //   return  await navKey.currentState.maybePop();
          //   // //   await navKey.currentState.maybePop();
          //   //   return true;
          //   },
          //   child: Navigator(
          //     key: keySave(this.uniqueId,GlobalKey<NavigatorState>()),
          //     onPopPage: (Route<dynamic> route, dynamic result) {
          //       print('xxxxx');
          //       return false;
          //     },
          //     initialRoute: name,
          //     onGenerateRoute: (RouteSettings settings) {
          //       return MaterialPageRoute<dynamic>(
          //           settings: settings,
          //           builder: (BuildContext context) {
          //             return builder(name, arguments, uniqueId);
          //           }
          //
          //       );
          //     },
          //   ),
          // );

          return Navigator(
            key: keySave(this.uniqueId, GlobalKey<NavigatorState>()),
            onPopPage: (Route<dynamic> route, dynamic result) {
              return false;
            },
            initialRoute: name,
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute<dynamic>(
                  settings: settings,
                  builder: (BuildContext context) {
                    return builder(name, arguments, uniqueId);
                  }

              );
            },
          );

          // return builder(name, arguments, uniqueId);
        });
  }
}

enum PageLocation {
  native,
  flutter,
}

class PageInfo {
  final PageLocation location;
  final BoostPage page;
  PageInfo({this.location, BoostPage this.page });
}


class PageNameUnkonw extends Page<dynamic> {
  PageNameUnkonw() : super(key: ValueKey("PageNameUnkonw"));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute<dynamic>(
      settings: this,
      builder: (BuildContext context) {
        return Container(
          child: const Text("PageNameUnkonw"),
        );
      },
    );
  }
}
