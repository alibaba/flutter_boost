import 'dart:async';
import 'package:flutter_boost/boost_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_lifecycle_binding.dart';
import 'package:flutter_boost/messages.dart';
import 'package:flutter_boost/boost_flutter_router_api.dart';
import 'package:flutter_boost/logger.dart';
import 'package:flutter_boost/boost_navigator.dart';
import 'package:flutter_boost/page_visibility.dart';
import 'package:flutter_boost/overlay_entry.dart';

typedef FlutterBoostAppBuilder = Widget Function(Widget home);
typedef FlutterBoostRouteFactory = Route<dynamic> Function(
    RouteSettings settings, String uniqueId);

class FlutterBoostApp extends StatefulWidget {
  FlutterBoostApp(FlutterBoostRouteFactory routeFactory,
      {FlutterBoostAppBuilder appBuilder, String initialRoute})
      : routeFactory = routeFactoryWrapper(routeFactory),
        appBuilder = appBuilder ?? _materialAppBuilder,
        initialRoute = initialRoute ?? '/';

  final FlutterBoostRouteFactory routeFactory;
  final FlutterBoostAppBuilder appBuilder;
  final String initialRoute;

  static Widget _materialAppBuilder(Widget home) {
    return MaterialApp(home: home);
  }

  static FlutterBoostRouteFactory routeFactoryWrapper(
      FlutterBoostRouteFactory routeFactory) {
    return (RouteSettings settings, String uniqueId) {
      Route<dynamic> route = routeFactory(settings, uniqueId);
      if (route == null && settings.name == '/') {
        route = PageRouteBuilder<dynamic>(
            settings: settings, pageBuilder: (_, __, ___) => Container());
      }
      return route;
    };
  }

  @override
  State<StatefulWidget> createState() => FlutterBoostAppState();
}

class FlutterBoostAppState extends State<FlutterBoostApp> {
  final Map<String, Completer<Object>> _pendingResult =
      <String, Completer<Object>>{};

  List<BoostContainer> get containers => _containers;
  final List<BoostContainer> _containers = <BoostContainer>[];

  BoostContainer get topContainer => containers.last;

  NativeRouterApi get nativeRouterApi => _nativeRouterApi;
  NativeRouterApi _nativeRouterApi;

  BoostFlutterRouterApi get boostFlutterRouterApi => _boostFlutterRouterApi;
  BoostFlutterRouterApi _boostFlutterRouterApi;

  FlutterBoostRouteFactory get routeFactory => widget.routeFactory;
  final Set<int> _activePointers = <int>{};

  @override
  void initState() {
    _containers.add(_createContainer(PageInfo(pageName: widget.initialRoute)));
    _nativeRouterApi = NativeRouterApi();
    _boostFlutterRouterApi = BoostFlutterRouterApi(this);
    super.initState();


    //Refresh the containers data to overlayKey to show the page matching initialRoute
    //Use addPostFrameCallback is because to wait overlayKey.currentState to load complete....
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });


    // try to restore routes from host when hot restart.
    assert(() {
      _restoreStackForHotRestart();
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    return widget.appBuilder(WillPopScope(
        onWillPop: () async {
          final bool canPop = topContainer.navigator.canPop();
          if (canPop) {
            topContainer.navigator.pop();
            return true;
          }
          return false;
        },
        child: Listener(
            onPointerDown: _handlePointerDown,
            onPointerUp: _handlePointerUpOrCancel,
            onPointerCancel: _handlePointerUpOrCancel,
            child: Overlay(
              key: overlayKey,
              initialEntries: const <OverlayEntry>[],
            ))));
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers.add(event.pointer);
  }

  void _handlePointerUpOrCancel(PointerEvent event) {
    _activePointers.remove(event.pointer);
  }

  void _cancelActivePointers() {
    _activePointers.toList().forEach(WidgetsBinding.instance.cancelPointer);
  }

  void refresh() {
    refreshOverlayEntries(containers);

    // try to save routes to host.
    assert(() {
      _saveStackForHotRestart();
      return true;
    }());
  }

  String _createUniqueId(String pageName) {
    return '${DateTime.now().millisecondsSinceEpoch}_$pageName';
  }

  BoostContainer _createContainer(PageInfo pageInfo) {
    pageInfo.uniqueId ??= _createUniqueId(pageInfo.pageName);
    return BoostContainer(
        key: ValueKey<String>(pageInfo.uniqueId),
        pageInfo: pageInfo,
        routeFactory: widget.routeFactory);
  }

  Future<void> _saveStackForHotRestart() async {
    final StackInfo stack = StackInfo();
    stack.containers = <String>[];
    for (BoostContainer container in containers) {
      stack.containers.add(container.pageInfo.uniqueId);
      stack.routes = <String, List<Map<String, Object>>>{};
      final List<Map<String, Object>> params = <Map<String, Object>>[];
      for (BoostPage<dynamic> page in container.pages) {
        final Map<String, Object> param = <String, Object>{};
        param['pageName'] = page.pageInfo.pageName;
        param['uniqueId'] = page.pageInfo.uniqueId;
        param['arguments'] = page.pageInfo.arguments;
        params.add(param);
      }
      stack.routes[container.pageInfo.uniqueId] = params;
    }
    await nativeRouterApi.saveStackToHost(stack);
    Logger.log(
        '_saveStackForHotRestart, ${stack?.containers}, ${stack?.routes}');
  }

  Future<void> _restoreStackForHotRestart() async {
    final StackInfo stack = await nativeRouterApi.getStackFromHost();
    if (stack != null && stack.containers != null) {
      for (String uniqueId in stack.containers) {
        bool withContainer = true;
        final List<Object> routeList = stack.routes[uniqueId];
        if (routeList != null) {
          for (Map<Object, Object> route in routeList) {
            push(route['pageName'] as String,
                uniqueId: route['uniqueId'] as String,
                arguments: Map<String, dynamic>.from(
                    route['arguments'] ?? <String, dynamic>{}),
                withContainer: withContainer);
            withContainer = false;
          }
        }
      }
    }
    Logger.log(
        '_restoreStackForHotRestart, ${stack?.containers}, ${stack?.routes}');
  }

  Future<T> pendResult<T extends Object>(String pageName){
    final Completer<T> completer = Completer<T>();
    _pendingResult[pageName] = completer;
    return completer.future;
  }

  Future<T> pushWithResult<T extends Object>(String pageName,
      {String uniqueId, Map<String, dynamic> arguments, bool withContainer}) {
    final Completer<T> completer = Completer<T>();
    assert(uniqueId == null);
    uniqueId = _createUniqueId(pageName);
    if (withContainer) {
      final CommonParams params = CommonParams()
        ..pageName = pageName
        ..uniqueId = uniqueId
        ..arguments = arguments ?? <String, dynamic>{};
      nativeRouterApi.pushFlutterRoute(params);
    } else {
      push(pageName,
          uniqueId: uniqueId, arguments: arguments, withContainer: false);
    }
    _pendingResult[uniqueId] = completer;
    return completer.future;
  }

  void push(String pageName,
      {String uniqueId, Map<String, dynamic> arguments, bool withContainer}) {
    _cancelActivePointers();
    final BoostContainer existed = _findContainerByUniqueId(uniqueId);
    if (existed != null) {
      if (topContainer?.pageInfo?.uniqueId != uniqueId) {
        final BoostContainer container = existed;
        final BoostContainer previousContainer = topContainer;
        containers.remove(existed);
        containers.add(existed);
        refresh();
        BoostLifecycleBinding.instance.containerDidMoveToTop(container, previousContainer);
      }
      // else {
      //   PageVisibilityBinding.instance
      //       .dispatchPageShowEvent(_getCurrentPageRoute());
      // }
    } else {
      final PageInfo pageInfo = PageInfo(
          pageName: pageName,
          uniqueId: uniqueId ?? _createUniqueId(pageName),
          arguments: arguments,
          withContainer: withContainer);
      if (withContainer) {
        final BoostContainer container = _createContainer(pageInfo);
        final BoostContainer previousContainer = topContainer;
        containers.add(container);
        // The observer can't receive the 'pageshow' message indeed，
        // because the observer is not yet registed at the moment.
        //
        // See PageVisibilityBinding#addObserver for the solution.
        BoostLifecycleBinding.instance.containerDidPush(container, previousContainer);
      } else {
        topContainer.pages
            .add(BoostPage.create(pageInfo, topContainer.routeFactory));
      }
      refresh();
    }
    Logger.log(
        'push page, uniqueId=$uniqueId, existed=$existed, withContainer=$withContainer, arguments:$arguments, $containers');
  }

  void popWithResult<T extends Object>([T result]) {
    final String uniqueId = topContainer?.topPage?.pageInfo?.uniqueId;
    if (_pendingResult.containsKey(uniqueId)) {
      _pendingResult[uniqueId].complete(result);

      ///Need to remove this completer after calling completer.complete(result)
      /// reason: https://github.com/alibaba/flutter_boost/issues/1020
      _pendingResult.remove(uniqueId);
    }

    result is Map<String, dynamic> ? pop(arguments: result) : pop();
  }

  Future<void> pop({String uniqueId, Map<String, dynamic> arguments}) async {
    BoostContainer container;
    if (uniqueId != null) {
      container = _findContainerByUniqueId(uniqueId);
      if (container == null) {
        Logger.error('uniqueId=$uniqueId not find');
        return;
      }
      if (container != topContainer) {
        _removeContainer(container);
        return;
      }
    } else {
      container = topContainer;
    }

    final bool handled = await container?.navigator?.maybePop();
    if (handled != null && !handled) {
      assert(container.pageInfo.withContainer);
      final CommonParams params = CommonParams()
        ..pageName = container.pageInfo.pageName
        ..uniqueId = container.pageInfo.uniqueId
        ..arguments = arguments ?? <String, dynamic>{};
      _nativeRouterApi.popRoute(params);
    }


    Logger.log(
        'pop container, uniqueId=$uniqueId, arguments:$arguments, $container');
  }

  void _removeContainer(BoostContainer page) {
    containers.remove(page);
    if (page.pageInfo.withContainer) {
      Logger.log('_removeContainer ,  uniqueId=${page.pageInfo.uniqueId}');
      final CommonParams params = CommonParams()
        ..pageName = page.pageInfo.pageName
        ..uniqueId = page.pageInfo.uniqueId
        ..arguments = page.pageInfo.arguments;
      _nativeRouterApi.popRoute(params);
    }
  }

  void onForeground() {
    BoostLifecycleBinding.instance
        .appDidEnterForeground(topContainer);
  }

  void onBackground() {
    BoostLifecycleBinding.instance
        .appDidEnterBackground(topContainer);
  }

  void onNativeViewShow() {
    BoostLifecycleBinding.instance.nativeViewDidHide(topContainer);
  }

  void onNativeViewHide() {
    BoostLifecycleBinding.instance.nativeViewDidShow(topContainer);
  }

  Route<dynamic> _getCurrentPageRoute() {
    return topContainer?.topPage?.route;
  }

  Route<dynamic> _getPreviousPageRoute() {
    if (topContainer != null) {
      assert(topContainer.pages != null);
      final int pageCount = topContainer.pages.length;
      if (pageCount > 1) {
        return topContainer.pages[pageCount - 2].route;
      } else {
        final int containerCount = containers.length;
        if (containerCount > 1) {
          return containers[containerCount - 2].pages.last.route;
        }
      }
    }
    return null;
  }

  BoostContainer _findContainerByUniqueId(String uniqueId) {
    return containers.singleWhere(
        (BoostContainer element) => element.pageInfo.uniqueId == uniqueId,
        orElse: () => null);
  }

  void remove(String uniqueId) {
    if (uniqueId == null) {
      return;
    }

    final BoostContainer container = _findContainerByUniqueId(uniqueId);
    Route<dynamic> _route;
    if (container != null) {
      // Gets the first internal route of the current container
      _route = container.pages.first.route;
      containers.removeWhere(
          (BoostContainer entry) => entry.pageInfo?.uniqueId == uniqueId);
    } else {
      for (BoostContainer container in containers) {
        final BoostPage<dynamic> _target = container.pages.firstWhere(
            (BoostPage<dynamic> entry) => entry.pageInfo?.uniqueId == uniqueId,
            orElse: () => null);
        _route = _target?.route;
        container.pages.removeWhere(
            (BoostPage<dynamic> entry) => entry.pageInfo?.uniqueId == uniqueId);
      }
    }
    refresh();
    PageVisibilityBinding.instance.dispatchPageDestoryEvent(_route);
    Logger.log('remove,  uniqueId=$uniqueId, $containers');
  }

  void onNativeResult(CommonParams params){
    if (_pendingResult.containsKey(params.pageName)) {
      _pendingResult[params.pageName].complete(params.arguments);
      _pendingResult.remove(params.pageName);
    }
    Logger.log('onNativeResult, name:${params.pageName}, result: ${params.arguments}');
  }

  PageInfo getTopPageInfo() {
    return topContainer?.topPage?.pageInfo;
  }

  int pageSize() {
    int count = 0;
    for (BoostContainer container in containers) {
      count += container.size;
    }
    return count;
  }
}

class BoostPage<T> extends Page<T> {
  BoostPage({LocalKey key, this.routeFactory, this.pageInfo})
      : super(key: key, name: pageInfo.pageName, arguments: pageInfo.arguments);

  final FlutterBoostRouteFactory routeFactory;
  final PageInfo pageInfo;

  static BoostPage<dynamic> create(
      PageInfo pageInfo, FlutterBoostRouteFactory routeFactory) {
    final BoostPage<dynamic> page = BoostPage<dynamic>(
        key: UniqueKey(), pageInfo: pageInfo, routeFactory: routeFactory);
    page._route = routeFactory(page, pageInfo.uniqueId);
    return page;
  }

  Route<T> _route;

  Route<T> get route => _route;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'BoostPage')}(name:$name, uniqueId:${pageInfo.uniqueId}, arguments:$arguments)';

  @override
  Route<T> createRoute(BuildContext context) {
    return _route;
  }
}

class BoostNavigatorObserver extends NavigatorObserver {
  BoostNavigatorObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    //handle internal route
    if (previousRoute != null) {
      BoostLifecycleBinding.instance.routeDidPush(route, previousRoute);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute != null) {
      BoostLifecycleBinding.instance.routeDidPop(route, previousRoute);
    }
    super.didPop(route, previousRoute);
  }
}
