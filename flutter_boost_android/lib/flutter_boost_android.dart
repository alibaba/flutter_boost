// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_boost_platform_interface/flutter_boost_platform_interface.dart';

/// The Android implementation of [FlutterBoostPlatform].
///
/// This class implements the `package:flutter_boost_platform_interface` interface
/// and is the default implementation on Android.
class FlutterBoostAndroid extends FlutterBoostPlatform {
  /// Registers this class as the default instance of [FlutterBoostPlatform].
  static void registerWith() {
    FlutterBoostPlatform.instance = FlutterBoostAndroid();
  }

  @override
  Future<void> pushNativeRoute(CommonParams param) {
    return super.pushNativeRoute(param);
  }

  @override
  Future<void> pushFlutterRoute(CommonParams param) {
    return super.pushFlutterRoute(param);
  }

  @override
  Future<void> popRoute(CommonParams param) {
    return super.popRoute(param);
  }

  @override
  Future<StackInfo> getStackFromHost() {
    return super.getStackFromHost();
  }

  @override
  Future<void> saveStackToHost(StackInfo stack) {
    return super.saveStackToHost(stack);
  }

  @override
  Future<void> sendEventToNative(CommonParams params) {
    return super.sendEventToNative(params);
  }
}
