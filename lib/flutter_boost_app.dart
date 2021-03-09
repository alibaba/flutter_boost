import 'dart:async';
import 'package:flutter_boost/boost_container.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  final Map<String, Completer<Object>> _pendingResult =
      <String, Completer<Object>>{};

  List<BoostContainer<dynamic>> get containers => _containers;
  final List<BoostContainer<dynamic>> _containers = <BoostContainer<dynamic>>[];

  BoostContainer<dynamic> get topContainer => containers.last;

  NativeRouterApi get nativeRouterApi => _nativeRouterApi;
  NativeRouterApi _nativeRouterApi;

  BoostFlutterRouterApi get boostFlutterRouterApi => _boostFlutterRouterApi;
  BoostFlutterRouterApi _boostFlutterRouterApi;

  FlutterBoostRouteFactory get routeFactory => widget.routeFactory;

  @override
  void initState() {
    _containers.add(_createContainer(PageInfo(pageName: widget.initialRoute)));
    _nativeRouterApi = NativeRouterApi();
    _boostFlutterRouterApi = BoostFlutterRouterApi(this);
    super.initState();
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
        child: Overlay(
          key: overlayKey,
          initialEntries: const <OverlayEntry>[],
        )));
  }

  void refresh() {
    refreshOverlayEntries(containers);
  }

  String _createUniqueId(String pageName) {
    if (kReleaseMode) {
      return Uuid().v4();
    } else {
      return Uuid().v4() + '#$pageName';
    }
  }

  BoostContainer<dynamic> _createContainer(PageInfo pageInfo) {
    pageInfo.uniqueId ??= _createUniqueId(pageInfo.pageName);
    return BoostContainer<dynamic>(
        key: ValueKey<String>(pageInfo.uniqueId),
        pageInfo: pageInfo,
        routeFactory: widget.routeFactory,
        observers: widget.observers);
  }

  Future<T> pushWithResult<T extends Object>(String pageName,
      {String uniqueId, Map<dynamic, dynamic> arguments, bool withContainer}) {
    final Completer<T> completer = Completer<T>();
    assert(uniqueId == null);
    uniqueId = _createUniqueId(pageName);
    if (withContainer) {
      final CommonParams params = CommonParams()
        ..pageName = pageName
        ..uniqueId = uniqueId
        ..arguments = arguments;
      nativeRouterApi.pushFlutterRoute(params);
    } else {
      push(pageName,
          uniqueId: uniqueId, arguments: arguments, withContainer: false);
    }
    _pendingResult[uniqueId] = completer;
    return completer.future;
  }

  void push(String pageName,
      {String uniqueId, Map<dynamic, dynamic> arguments, bool withContainer}) {
    final BoostContainer<dynamic> existed = _findContainerByUniqueId(uniqueId);
    if (existed != null) {
      if (topContainer?.pageInfo?.uniqueId != uniqueId) {
        containers.remove(existed);
        containers.add(existed);
        refresh();
        PageVisibilityBinding.instance
            .dispatchPageShowEvent(_getCurrentPageRoute());
        if (_getPreviousPageRoute() != null) {
          PageVisibilityBinding.instance
              .dispatchPageHideEvent(_getPreviousPageRoute());
        }
      } else {
        PageVisibilityBinding.instance
            .dispatchPageShowEvent(_getCurrentPageRoute());
      }
    } else {
      final PageInfo pageInfo = PageInfo(
          pageName: pageName,
          uniqueId: uniqueId ?? _createUniqueId(pageName),
          arguments: arguments,
          withContainer: withContainer);
      if (withContainer) {
        containers.add(_createContainer(pageInfo));
        refresh();
        // The observer can't receive the 'pageshow' message indeed，
        // because the observer is not yet registed at the moment.
        //
        // See PageVisibilityBinding#addObserver for the solution.
        PageVisibilityBinding.instance
            .dispatchPageShowEvent(_getCurrentPageRoute());
        if (_getPreviousPageRoute() != null) {
          PageVisibilityBinding.instance
              .dispatchPageHideEvent(_getPreviousPageRoute());
        }
      } else {
        topContainer.pages
            .add(BoostPage.create(pageInfo, topContainer.routeFactory));
        refresh();
      }
    }
    Logger.log(
        'push page, uniqueId=$uniqueId, existed=$existed, withContainer=$withContainer, arguments:$arguments, $containers');
  }

  void popWithResult<T extends Object>([T result]) {
    final String uniqueId = topContainer?.topPage?.pageInfo?.uniqueId;
    if (_pendingResult.containsKey(uniqueId)) {
      _pendingResult[uniqueId].complete(result);
    }
    pop();
  }

  Future<void> pop({String uniqueId, Map<dynamic, dynamic> arguments}) async {
    BoostContainer<dynamic> container;
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
        ..arguments = arguments;
      _nativeRouterApi.popRoute(params);
    }
    _pendingResult.remove(uniqueId);

    Logger.log(
        'pop container, uniqueId=$uniqueId, arguments:$arguments, $container');
  }

  void _removeContainer(BoostContainer<dynamic> page) {
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
    PageVisibilityBinding.instance
        .dispatchForegroundEvent(_getCurrentPageRoute());
  }

  void onBackground() {
    PageVisibilityBinding.instance
        .dispatchBackgroundEvent(_getCurrentPageRoute());
  }

  void onNativeViewShow() {
    PageVisibilityBinding.instance
        .dispatchPageHideEvent(_getCurrentPageRoute());
  }

  void onNativeViewHide() {
    PageVisibilityBinding.instance
        .dispatchPageShowEvent(_getCurrentPageRoute());
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

  BoostContainer<dynamic> _findContainerByUniqueId(String uniqueId) {
    return containers.singleWhere(
        (BoostContainer<dynamic> element) =>
            element.pageInfo.uniqueId == uniqueId,
        orElse: () => null);
  }

  void remove(String uniqueId) {
    if (uniqueId == null) {
      return;
    }

    final BoostContainer<dynamic> container =
        _findContainerByUniqueId(uniqueId);
    Route<dynamic> _route;
    if (container != null) {
      // Gets the first internal route of the current container
      _route = container.pages.first.route;
      containers.removeWhere((BoostContainer<dynamic> entry) =>
          entry.pageInfo?.uniqueId == uniqueId);
      refresh();
    } else {
      for (BoostContainer<dynamic> container in containers) {
        final BoostPage<dynamic> _target = container.pages.firstWhere(
            (BoostPage<dynamic> entry) => entry.pageInfo?.uniqueId == uniqueId,
            orElse: () => null);
        _route = _target?.route;
        container.pages.removeWhere(
            (BoostPage<dynamic> entry) => entry.pageInfo?.uniqueId == uniqueId);
      }
      refresh();
    }
    PageVisibilityBinding.instance.dispatchPageDestoryEvent(_route);
    Logger.log('remove,  uniqueId=$uniqueId, $containers');
  }

  PageInfo getTopPageInfo() {
    return topContainer?.topPage?.pageInfo;
  }

  int pageSize() {
    int count = 0;
    for (BoostContainer<dynamic> container in containers) {
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
    return BoostPage<dynamic>(
        key: UniqueKey(), pageInfo: pageInfo, routeFactory: routeFactory);
  }

  Route<T> _route;
  Route<T> get route => _route;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'BoostPage')}(name:$name, uniqueId:${pageInfo.uniqueId}, arguments:$arguments)';

  @override
  Route<T> createRoute(BuildContext context) {
    _route = routeFactory(this, pageInfo.uniqueId);
    Logger.log('page_visibility, #createRoute, ${pageInfo.uniqueId}, $route');
    return _route;
  }
}

class BoostNavigatorObserver extends NavigatorObserver {
  BoostNavigatorObserver(this.observers);

  final List<NavigatorObserver> observers;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    for (NavigatorObserver observer in observers) {
      observer.didPush(route, previousRoute);
    }

    //handle internal route
    if (previousRoute != null) {
      PageVisibilityBinding.instance.dispatchPageShowEvent(route);
      PageVisibilityBinding.instance.dispatchPageHideEvent(previousRoute);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    for (NavigatorObserver observer in observers) {
      observer.didPop(route, previousRoute);
    }

    if (previousRoute != null) {
      PageVisibilityBinding.instance.dispatchPageHideEvent(route);
      PageVisibilityBinding.instance.dispatchPageShowEvent(previousRoute);
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    for (NavigatorObserver observer in observers) {
      observer.didRemove(route, previousRoute);
    }
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    for (NavigatorObserver observer in observers) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
    for (NavigatorObserver observer in observers) {
      observer.didStartUserGesture(route, previousRoute);
    }
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    for (NavigatorObserver observer in observers) {
      observer.didStopUserGesture();
    }
    super.didStopUserGesture();
  }
}
