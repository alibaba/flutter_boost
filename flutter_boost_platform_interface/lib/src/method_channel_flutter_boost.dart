// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'messages.dart';
import 'flutter_boost_platform_interface.dart';

/// An implementation of [FlutterBoostPlatform] that uses method channels.
class MethodChannelFlutterBoost extends FlutterBoostPlatform {
  NativeRouterApi? _nativeRouterApi;

  @override
  NativeRouterApi getNativeRouterApi() {
    _nativeRouterApi ??= NativeRouterApi();
    return _nativeRouterApi!;
  }

  @override
  void setupFlutterRouterApi(FlutterRouterApi? api) {
    FlutterRouterApi.setup(api);
  }
}
