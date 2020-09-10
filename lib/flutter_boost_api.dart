import 'package:flutter/widgets.dart';

import 'container/container_coordinator.dart';
import 'flutter_boost.dart';
import 'flutter_boost.dart';
import 'flutter_boost.dart';

typedef Route FlutterBoostRouteBuilder(Widget widget);



typedef BoostRouteSettings BoostRouteSettingsBuilder(String url,
    {Map<String, dynamic> urlParams, Map<String, dynamic> exts});

class FlutterBoostAPI {

  static final FlutterBoostAPI _instance = FlutterBoostAPI();

  static FlutterBoostAPI get singleton => _instance;

  BoostRouteSettingsBuilder routeSettingsBuilder;

  Future<Map<dynamic, dynamic>> open(String url,
      {Map<String, dynamic> urlParams,
      Map<String, dynamic> exts,
      bool noNeedNativeContainer,
      FlutterBoostRouteBuilder routeBuilder}) {
    if (noNeedNativeContainer) {
      final BoostRouteSettings routeSettings =
          routeSettingsBuilder(url, urlParams: urlParams, exts: exts);

      final Widget page = ContainerCoordinator.singleton.createPage(
          routeSettings.name, routeSettings.params, routeSettings.uniqueId);

      final Route<Map<dynamic, dynamic>> route = routeBuilder != null
          ? routeBuilder(page)
          : PageRouteBuilder<Map<dynamic, dynamic>>(
              pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                  page);
      if (route != null) {
        return FlutterBoost.containerManager?.onstageContainer?.push(route);
      }
      return Future<Map<dynamic, dynamic>>.value(<dynamic, dynamic>{});
    }

    return FlutterBoost.singleton.open(url, urlParams: urlParams, exts: exts);
  }

  bool close<T extends Object>([T result]) {
    return FlutterBoost.containerManager?.onstageContainer?.pop(result);
  }
}
