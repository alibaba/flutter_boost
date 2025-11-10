// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'common_params.dart';
import 'method_channel_flutter_boost.dart';
import 'stack_info.dart';

/// The interface that implementations of flutter_boost must implement.
///
/// Platform implementations should extend this class rather than implement it as `flutter_boost`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [FlutterBoostPlatform] methods.
abstract class FlutterBoostPlatform extends PlatformInterface {
  /// Constructs a FlutterBoostPlatform.
  FlutterBoostPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBoostPlatform _instance = MethodChannelFlutterBoost();

  /// The default instance of [FlutterBoostPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBoost].
  static FlutterBoostPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBoostPlatform] when
  /// they register themselves.
  static set instance(FlutterBoostPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Push a native route.
  Future<void> pushNativeRoute(CommonParams param) {
    throw UnimplementedError('pushNativeRoute() has not been implemented.');
  }

  /// Push a Flutter route.
  Future<void> pushFlutterRoute(CommonParams param) {
    throw UnimplementedError('pushFlutterRoute() has not been implemented.');
  }

  /// Pop the current route.
  Future<void> popRoute(CommonParams param) async {
    throw UnimplementedError('popRoute() has not been implemented.');
  }

  /// Get the navigation stack from the host platform.
  Future<StackInfo> getStackFromHost() {
    throw UnimplementedError('getStackFromHost() has not been implemented.');
  }

  /// Save the navigation stack to the host platform.
  Future<void> saveStackToHost(StackInfo stack) {
    throw UnimplementedError('saveStackToHost() has not been implemented.');
  }

  /// Send a custom event to native.
  Future<void> sendEventToNative(CommonParams params) {
    throw UnimplementedError('sendEventToNative() has not been implemented.');
  }
}
