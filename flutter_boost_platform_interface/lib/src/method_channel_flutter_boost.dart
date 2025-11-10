// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'common_params.dart';
import 'flutter_boost_platform.dart';
import 'stack_info.dart';

/// An implementation of [FlutterBoostPlatform] that uses method channels.
class MethodChannelFlutterBoost extends FlutterBoostPlatform {
  /// The method channel used to interact with the native platform.
  static const MethodChannel methodChannel =
      MethodChannel('flutter_boost');

  @override
  Future<void> pushNativeRoute(CommonParams param) async {
    try {
      await methodChannel.invokeMethod<void>('pushNativeRoute', param.encode());
    } on PlatformException catch (e) {
      throw Exception('Failed to push native route: ${e.message}');
    }
  }

  @override
  Future<void> pushFlutterRoute(CommonParams param) async {
    try {
      await methodChannel.invokeMethod<void>('pushFlutterRoute', param.encode());
    } on PlatformException catch (e) {
      throw Exception('Failed to push Flutter route: ${e.message}');
    }
  }

  @override
  Future<void> popRoute(CommonParams param) async {
    try {
      await methodChannel.invokeMethod<void>('popRoute', param.encode());
    } on PlatformException catch (e) {
      throw Exception('Failed to pop route: ${e.message}');
    }
  }

  @override
  Future<StackInfo> getStackFromHost() async {
    try {
      final Object? result = await methodChannel.invokeMethod<Object?>('getStackFromHost');
      if (result == null) {
        return StackInfo();
      }
      return StackInfo.decode(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to get stack from host: ${e.message}');
    }
  }

  @override
  Future<void> saveStackToHost(StackInfo stack) async {
    try {
      await methodChannel.invokeMethod<void>('saveStackToHost', stack.encode());
    } on PlatformException catch (e) {
      throw Exception('Failed to save stack to host: ${e.message}');
    }
  }

  @override
  Future<void> sendEventToNative(CommonParams params) async {
    try {
      await methodChannel.invokeMethod<void>('sendEventToNative', params.encode());
    } on PlatformException catch (e) {
      throw Exception('Failed to send event to native: ${e.message}');
    }
  }
}
