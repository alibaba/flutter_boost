import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost_app.dart';
import 'package:flutter_boost/messages.dart';
import 'package:flutter_boost/overlay_entry.dart';
import 'boost_container.dart';
import 'boost_interceptor.dart';

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
    final BoostInterceptorOption option =
        await _getInterceptorResponse(name, arguments);

    if (option.isBlocked) {
      return Future<T>.value();
    }

    if (isFlutterPage(option.name)) {
      return appState.pushWithResult(option.name,
          arguments: option.arguments, withContainer: withContainer);
    } else {
      final CommonParams params = CommonParams()
        ..pageName = option.name
        ..arguments = option.arguments ?? <String, dynamic>{};
      appState.nativeRouterApi.pushNativeRoute(params);
      return appState.pendNativeResult(option.name);
    }
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

  /// Private API:
  /// Get [BoostInterceptorOption] using all of [BoostInterceptor]
  /// [name] the page's name that user wants to push
  /// [arguments] the args will pass in target page
  Future<BoostInterceptorOption> _getInterceptorResponse(
      String name, Map<String, dynamic> arguments) async {
    // Get all interceptors from FlutterBoostAppState
    final List<BoostInterceptor> interceptors = appState.interceptors;

    // Deep copy argments map,because we don't want to change original data...
    final Map<String, dynamic> resultArguments = arguments != null
        ? Map<String, dynamic>.from(arguments)
        : <String, dynamic>{};

    // Initialize the result option object
    final BoostInterceptorOption resultOption = BoostInterceptorOption(
        isBlocked: false, name: name, arguments: resultArguments);

    // Traverse every interceptor,let everyone of them precess the data in option object
    for (final BoostInterceptor interceptor in interceptors) {
      // Get the response object after calling interceptor.onPush
      await interceptor.onPush(resultOption);

      // Whenever the resultResponse's "isBlocked" == true,we will not continue the loop.
      if (resultOption.isBlocked) {
        return resultOption;
      }
    }

    return resultOption;
  }
}

class PageInfo {
  PageInfo({this.pageName, this.uniqueId, this.arguments, this.withContainer});

  bool withContainer;
  String pageName;
  String uniqueId;
  Map<String, dynamic> arguments;
}
