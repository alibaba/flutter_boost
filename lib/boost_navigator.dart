import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost_app.dart';
import 'package:flutter_boost/messages.dart';
import 'package:flutter_boost/overlay_entry.dart';
import 'boost_container.dart';

typedef FlutterBoostRouteFactory = Route<dynamic> Function(
    RouteSettings settings, String uniqueId);

FlutterBoostRouteFactory routeFactoryWrapper(
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

/// A object that manages a set of pages with a hybrid stack.
///
class BoostNavigator {

  BoostNavigator._();

  static final BoostNavigator _instance = BoostNavigator._();

  FlutterBoostAppState appState;

  FlutterBoostRouteFactory _routeFactory;

  set routeFactory(FlutterBoostRouteFactory routeFactory) => _routeFactory = routeFactoryWrapper(routeFactory);

  FlutterBoostRouteFactory get routeFactory => _routeFactory;

  @Deprecated('Use `instance` instead.')
  /// Use BoostNavigator.instance instead
  static BoostNavigator of() {
    return instance;
  }

  static BoostNavigator get instance {
    if (_instance.appState == null) {
      final FlutterBoostAppState _appState = overlayKey.currentContext?.findAncestorStateOfType<FlutterBoostAppState>();
      _instance.appState = _appState;
    }
    return _instance;
  }

  /// Whether this page with the given [name] is a flutter page
  ///
  /// If the name of route can be found in route table then return true,
  /// otherwise return false.
  bool isFlutterPage(String name) {
    return routeFactory(RouteSettings(name: name), null) != null;
  }

  /// Push the page with the given [name] onto the hybrid stack.
  Future<T> push<T extends Object>(String name,
      {Map<String, dynamic> arguments, bool withContainer = false}) {
    if (isFlutterPage(name)) {
      return appState.pushWithResult(name,
          arguments: arguments, withContainer: withContainer);
    } else {
      final CommonParams params = CommonParams()
        ..pageName = name
        ..arguments = arguments ?? <String, dynamic>{};
      appState.nativeRouterApi.pushNativeRoute(params);
      return appState.pendResult(name);
    }
  }

  /// Pop the top-most page off the hybrid stack.
  void pop<T extends Object>([T result]) {
    appState.popWithResult(result);
  }

  /// Remove the page with the given [uniqueId] from hybrid stack.
  ///
  /// This API is for backwards compatibility.
  void remove(String uniqueId) {
    appState.pop(uniqueId: uniqueId);
  }

  /// Retrieves the infomation of the top-most flutter page
  /// on the hybrid stack, such as uniqueId, pagename, etc;
  ///
  /// This is a legacy API for backwards compatibility.
  PageInfo getTopPageInfo() {
    return appState.getTopPageInfo();
  }

  PageInfo getTopByContext(BuildContext context) {
    return BoostContainer.of(context).pageInfo;
  }

  /// Return the number of flutter pages
  ///
  /// This is a legacy API for backwards compatibility.
  int pageSize() {
    return appState.pageSize();
  }
}

class PageInfo {
  PageInfo({this.pageName, this.uniqueId, this.arguments, this.withContainer});

  bool withContainer;
  String pageName;
  String uniqueId;
  Map<String, dynamic> arguments;
}
