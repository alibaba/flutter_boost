import 'dart:async';

import 'package:flutter/widgets.dart';

import 'boost_container.dart';
import 'boost_interceptor.dart';
import 'container_overlay.dart';
import 'flutter_boost_app.dart';
import 'messages.dart';

typedef FlutterBoostRouteFactory = Route<dynamic> Function(
    RouteSettings settings, String uniqueId);

FlutterBoostRouteFactory routeFactoryWrapper(
    FlutterBoostRouteFactory routeFactory) {
  return (settings, uniqueId) {
    var route = routeFactory(settings, uniqueId);
    if (route == null && settings.name == '/') {
      route = PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => Container());
    }
    return route;
  };
}

/// A object that manages a set of pages with a hybrid stack.
///
class BoostNavigator {
  BoostNavigator._();

  /// The singleton for [BoostNavigator]
  static final BoostNavigator _instance = BoostNavigator._();

  /// The boost data center
  FlutterBoostAppState appState;

  /// The route table in flutter_boost
  FlutterBoostRouteFactory _routeFactory;

  set routeFactory(FlutterBoostRouteFactory routeFactory) =>
      _routeFactory = routeFactoryWrapper(routeFactory);

  FlutterBoostRouteFactory get routeFactory => _routeFactory;

  @Deprecated('Use `instance` instead.')

  /// Use BoostNavigator.instance instead
  static BoostNavigator of() => instance;

  static BoostNavigator get instance {
    _instance.appState ??= overlayKey.currentContext
        ?.findAncestorStateOfType<FlutterBoostAppState>();
    return _instance;
  }

  /// Whether this page with the given [name] is a flutter page
  ///
  /// If the name of route can be found in route table then return true,
  /// otherwise return false.
  bool isFlutterPage(String name) =>
      routeFactory(RouteSettings(name: name), null) != null;

  /// Push the page with the given [name] onto the hybrid stack.
  /// [arguments] is the param you want to pass in next page
  /// if [withContainer] is true,next route will be with a native container
  /// (Android Activity / iOS UIViewController)
  /// if [opaque] is true,the page is opaque (not transparent)
  ///
  /// And it will return the result popped by page as a Future<T>
  Future<T> push<T extends Object>(String name,
      {Map<String, dynamic> arguments,
      bool withContainer = false,
      bool opaque = true}) async {
    var pushOption = BoostInterceptorOption(name,
        arguments: arguments ?? <String, dynamic>{});
    var future = Future<dynamic>(
        () => InterceptorState<BoostInterceptorOption>(pushOption));
    for (var interceptor in appState.interceptors) {
      future = future.then<dynamic>((dynamic _state) {
        final state = _state as InterceptorState<dynamic>;
        if (state.type == InterceptorResultType.next) {
          final pushHandler = PushInterceptorHandler();
          interceptor.onPush(state.data, pushHandler);
          return pushHandler.future;
        } else {
          return state;
        }
      });
    }

    return future.then((dynamic _state) {
      final state = _state as InterceptorState<dynamic>;
      if (state.data is BoostInterceptorOption) {
        assert(state.type == InterceptorResultType.next);
        pushOption = state.data;
        if (isFlutterPage(pushOption.name)) {
          return appState.pushWithResult(pushOption.name,
              uniqueId: pushOption.uniqueId,
              arguments: pushOption.arguments,
              withContainer: withContainer,
              opaque: opaque);
        } else {
          final params = CommonParams()
            ..pageName = pushOption.name
            ..arguments = pushOption.arguments;
          appState.nativeRouterApi.pushNativeRoute(params);
          return appState.pendNativeResult(pushOption.name);
        }
      } else {
        assert(state.type == InterceptorResultType.resolve);
        return Future<T>.value(state.data as T);
      }
    });
  }

  /// This api do two things
  /// 1.Push a new page onto pageStack
  /// 2.remove(pop) previous page
  Future<T> pushReplacement<T extends Object>(String name,
      {Map<String, dynamic> arguments, bool withContainer = false}) async {
    final id = getTopPageInfo().uniqueId;

    final result =
        push(name, arguments: arguments, withContainer: withContainer);

    Future.delayed(const Duration(milliseconds: 100), () {
      remove(id);
    });
    return result;
  }

  /// Pop the top-most page off the hybrid stack.
  Future<bool> pop<T extends Object>([T result]) async =>
      await appState.popWithResult(result);

  /// PopUntil page off the hybrid stack.
  Future<void> popUntil({String route, String uniqueId}) async =>
      await appState.popUntil(route: route, uniqueId: uniqueId);

  /// Remove the page with the given [uniqueId] from hybrid stack.
  ///
  /// This API is for backwards compatibility.
  /// Please use [BoostNavigator.pop] instead.
  void remove(String uniqueId, {Map<String, dynamic> arguments}) =>
      appState.removeWithResult(uniqueId, arguments);

  /// Retrieves the infomation of the top-most flutter page
  /// on the hybrid stack, such as uniqueId, pagename, etc;
  ///
  /// This is a legacy API for backwards compatibility.
  PageInfo getTopPageInfo() => appState.getTopPageInfo();

  /// Get the top page 's [PageInfo] with [BuildContext]
  PageInfo getTopByContext(BuildContext context) =>
      BoostContainer.of(context).pageInfo;

  /// Return the number of flutter pages
  ///
  /// This is a legacy API for backwards compatibility.
  int pageSize() => appState.pageSize();
}

/// The PageInfo use in FlutterBoost ,it is not a public api
class PageInfo {
  PageInfo({this.pageName, this.uniqueId, this.arguments, this.withContainer});

  bool withContainer;
  String pageName;
  String uniqueId;
  Map<String, dynamic> arguments;
}
