import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'flutter_boost_app.dart';

class BoostRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(routeInformation.location);
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}

class BoostRouteDelegate extends RouterDelegate<String>
    with PopNavigatorRouterDelegateMixin<String>, ChangeNotifier {
  final _stack = <String>[];
  List<Page> _pageStack = <Page<dynamic>>[];

  static BoostRouteDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    return delegate as BoostRouteDelegate;
  }

  final Map<String, PageBuilder> routeMap;

  BoostRouteDelegate(this.routeMap);

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // @override
  // String get currentConfiguration => _pageStack.isNotEmpty ? _pageStack.last : null;

  List<String> get stack => List.unmodifiable(_stack);


  void push(String routeName, {Object arguments}) {
    _stack.add(routeName);
    PageBuilder _builder = routeMap[routeName];

    String uniqueId =
        "__container_uniqueId_key__${DateTime.now().millisecondsSinceEpoch}-${routeName}";

    Page page = BoostPage(routeName, uniqueId, arguments, _builder);

    _pageStack.add(page);

    notifyListeners();
  }

  void remove(String routeName) {
    _stack.remove(routeName);
    notifyListeners();
  }

  @override
  Future<void> setInitialRoutePath(String configuration) {
    PageBuilder _builder = routeMap[configuration];

    String uniqueId =
        "__container_uniqueId_key__${DateTime.now().millisecondsSinceEpoch}-${configuration}";
    Page page = BoostPage(configuration, uniqueId, null, _builder);
    _pageStack.add(page);

    return setNewRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(String configuration) {
    _stack
      ..clear()
      ..add(configuration);

    return SynchronousFuture<void>(null);
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    // if (pageStack.isNotEmpty) {
    //   if (pageStack.last.name == route.settings.name) {
    //     pageStack.removeLast();
    //     notifyListeners();
    //   }
    // }
    return route.didPop(result);
  }

  @override
  Widget build(BuildContext context) {
    // return Navigator(
    //   key: navigatorKey,
    //   onPopPage: _onPopPage,
    //   pages:List.of(pageStack),
    // );
  }
}

class BoostPage extends Page<String> {
  final PageBuilder builder;
  final String name;
  final Map arguments;

  final String uniqueId;

  BoostPage(this.name, this.uniqueId, this.arguments, this.builder)
      : super(key: ValueKey(uniqueId));

  @override
  Route<String> createRoute(BuildContext context) {
    return MaterialPageRoute<String>(
      settings: this,
      builder: (BuildContext context) {
        return builder(name, arguments, uniqueId);
      },
    );
  }
}
