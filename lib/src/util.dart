// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'flutter_boost_app.dart';

class BoostUtil {
  ///
  /// try to get route info.
  /// If routeSetting is BoostPage, will be return.
  /// Else return null.
  static BoostPage<dynamic>? tryGetRouteInfo(Route<dynamic> route) {
    final RouteSettings routeSettings = route.settings;
    if (routeSettings is BoostPage<dynamic>) {
      return routeSettings;
    }
    return null;
  }
}
