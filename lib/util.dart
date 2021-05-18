import 'package:flutter/widgets.dart';

import 'flutter_boost_app.dart';

class BoostUtil {
  ///
  /// try to get route uniqueId.
  /// If routeSetting is BoostPage, uniqueId will be return.
  /// Else return null.
  static String tryGetRouteUniqueId(Route<dynamic> route) {
    final RouteSettings routeSettings = route.settings;
    if (routeSettings is BoostPage<dynamic>){
      return routeSettings.pageInfo.uniqueId;
    }
    return null;
  }
}
