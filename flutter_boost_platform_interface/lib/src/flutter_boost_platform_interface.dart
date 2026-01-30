// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'messages.dart';
import 'method_channel_flutter_boost.dart';

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

  /// Returns a [NativeRouterApi] instance for communicating with native side.
  NativeRouterApi getNativeRouterApi();

  /// Sets up the [FlutterRouterApi] for receiving messages from native side.
  void setupFlutterRouterApi(FlutterRouterApi? api);
}
