import 'dart:async';

import 'package:flutter/widgets.dart';

import 'boost_container.dart';
import 'boost_interceptor.dart';
import 'flutter_boost_app.dart';
import 'messages.dart';
import 'overlay_entry.dart';

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

  static final BoostNavigator _instance = BoostNavigator._();

  FlutterBoostAppState appState;

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
  Future<T> push<T extends Object>(String name,
      {Map<String, dynamic> arguments, bool withContainer = false}) async {
    var pushOption =
        BoostInterceptorOption(name, arguments ?? <String, dynamic>{});
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
              arguments: pushOption.arguments, withContainer: withContainer);
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

  /// Pop the top-most page off the hybrid stack.
  void pop<T extends Object>([T result]) => appState.popWithResult(result);

  /// Remove the page with the given [uniqueId] from hybrid stack.
  ///
  /// This API is for backwards compatibility.
  void remove(String uniqueId) => appState.pop(uniqueId: uniqueId);

  /// Retrieves the infomation of the top-most flutter page
  /// on the hybrid stack, such as uniqueId, pagename, etc;
  ///
  /// This is a legacy API for backwards compatibility.
  PageInfo getTopPageInfo() => appState.getTopPageInfo();

  PageInfo getTopByContext(BuildContext context) =>
      BoostContainer.of(context).pageInfo;

  /// Return the number of flutter pages
  ///
  /// This is a legacy API for backwards compatibility.
  int pageSize() => appState.pageSize();
}

class PageInfo {
  PageInfo({this.pageName, this.uniqueId, this.arguments, this.withContainer});

  bool withContainer;
  String pageName;
  String uniqueId;
  Map<String, dynamic> arguments;
}
