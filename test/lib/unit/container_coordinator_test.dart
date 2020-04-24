import 'dart:ui';

import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_boost/channel/boost_channel.dart';
import 'package:flutter_boost/container/container_coordinator.dart';

class MockBoostChannel extends BoostChannel implements Mock {
  MethodHandler get testHandler => _testHandler;

  EventListener get testEventListener => _testEventListener;
  MethodHandler _testHandler;
  EventListener _testEventListener;

  @override
  VoidCallback addEventListener(String name, EventListener listener) {
    _testEventListener = listener;

    return super.addEventListener(name, listener);
  }

  @override
  VoidCallback addMethodHandler(MethodHandler handler) {
    _testHandler = handler;
    return super.addMethodHandler(handler);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
//  const MessageCodec<dynamic> jsonMessage = JSONMessageCodec();

  test('test onMethodCall', () async {
    // Initialize all bindings because defaultBinaryMessenger.send() needs a window.
    TestWidgetsFlutterBinding.ensureInitialized();
    final MockBoostChannel boostChannel = MockBoostChannel();
    ContainerCoordinator(boostChannel);

    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments['pageName'] = 'pageName';
    arguments['params'] = <dynamic, dynamic>{};
    arguments['uniqueId'] = 'xxxxx';

    final MethodCall call = MethodCall('didInitPageContainer', arguments);
    try {
      boostChannel.testHandler(call);
    } catch (e) {
      expect(e, isAssertionError);
    }
    final MethodCall call2 = MethodCall('willShowPageContainer', arguments);

    try {
      boostChannel.testHandler(call2);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }

    final MethodCall call3 = MethodCall('didShowPageContainer', arguments);

    try {
      boostChannel.testHandler(call3);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }

    final MethodCall call4 =
        MethodCall('willDisappearPageContainer', arguments);

    try {
      boostChannel.testHandler(call4);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }

    final MethodCall call5 = MethodCall('onNativePageResult', arguments);

    try {
      boostChannel.testHandler(call5);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }

    final MethodCall call6 = MethodCall('didDisappearPageContainer', arguments);

    try {
      boostChannel.testHandler(call6);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }
    final MethodCall call7 = MethodCall('willDeallocPageContainer', arguments);

    try {
      boostChannel.testHandler(call7);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }

    final Map<String, dynamic> arg = <String, dynamic>{
      'type': 'backPressedCallback'
    };
    try {
      boostChannel.testEventListener('lifecycle', arg);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }

    final Map<String, dynamic> arg2 = <String, dynamic>{'type': 'foreground'};
    try {
      boostChannel.testEventListener('lifecycle', arg2);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }

    final Map<String, dynamic> arg3 = <String, dynamic>{'type': 'background'};
    try {
      boostChannel.testEventListener('lifecycle', arg3);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }

    final Map<String, dynamic> arg4 = <String, dynamic>{
      'type': 'scheduleFrame'
    };
    try {
      boostChannel.testEventListener('lifecycle', arg4);
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }
  });
}
