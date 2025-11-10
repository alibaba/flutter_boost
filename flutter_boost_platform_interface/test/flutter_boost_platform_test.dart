// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boost_platform_interface/flutter_boost_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBoostPlatform extends FlutterBoostPlatform {
  @override
  Future<void> pushNativeRoute(CommonParams param) async {
    // Mock implementation
  }

  @override
  Future<void> pushFlutterRoute(CommonParams param) async {
    // Mock implementation
  }

  @override
  Future<void> popRoute(CommonParams param) async {
    // Mock implementation
  }

  @override
  Future<StackInfo> getStackFromHost() async {
    return StackInfo();
  }

  @override
  Future<void> saveStackToHost(StackInfo stack) async {
    // Mock implementation
  }

  @override
  Future<void> sendEventToNative(CommonParams params) async {
    // Mock implementation
  }
}

void main() {
  group('FlutterBoostPlatform', () {
    test('default instance is MethodChannelFlutterBoost', () {
      expect(FlutterBoostPlatform.instance, isA<MethodChannelFlutterBoost>());
    });

    test('can set custom instance', () {
      final MockFlutterBoostPlatform mockPlatform = MockFlutterBoostPlatform();
      FlutterBoostPlatform.instance = mockPlatform;
      expect(FlutterBoostPlatform.instance, mockPlatform);
    });
  });

  group('CommonParams', () {
    test('encode and decode', () {
      final params = CommonParams(
        opaque: true,
        key: 'test_key',
        pageName: 'test_page',
        uniqueId: 'unique_123',
        arguments: {'arg1': 'value1'},
      );

      final encoded = params.encode();
      final decoded = CommonParams.decode(encoded);

      expect(decoded.opaque, params.opaque);
      expect(decoded.key, params.key);
      expect(decoded.pageName, params.pageName);
      expect(decoded.uniqueId, params.uniqueId);
      expect(decoded.arguments, params.arguments);
    });
  });

  group('FlutterPage', () {
    test('encode and decode', () {
      final page = FlutterPage(
        withContainer: true,
        pageName: 'test_page',
        uniqueId: 'unique_123',
        arguments: {'arg1': 'value1'},
      );

      final encoded = page.encode();
      final decoded = FlutterPage.decode(encoded);

      expect(decoded.withContainer, page.withContainer);
      expect(decoded.pageName, page.pageName);
      expect(decoded.uniqueId, page.uniqueId);
      expect(decoded.arguments, page.arguments);
    });
  });

  group('FlutterContainer', () {
    test('encode and decode', () {
      final container = FlutterContainer(
        pages: [
          FlutterPage(
            pageName: 'page1',
            uniqueId: 'id1',
          ),
          FlutterPage(
            pageName: 'page2',
            uniqueId: 'id2',
          ),
        ],
      );

      final encoded = container.encode();
      final decoded = FlutterContainer.decode(encoded);

      expect(decoded.pages?.length, container.pages?.length);
      expect(decoded.pages?[0]?.pageName, 'page1');
      expect(decoded.pages?[1]?.pageName, 'page2');
    });
  });

  group('StackInfo', () {
    test('encode and decode', () {
      final stackInfo = StackInfo(
        ids: ['id1', 'id2'],
        containers: {
          'id1': FlutterContainer(pages: [FlutterPage(pageName: 'page1')]),
          'id2': FlutterContainer(pages: [FlutterPage(pageName: 'page2')]),
        },
      );

      final encoded = stackInfo.encode();
      final decoded = StackInfo.decode(encoded);

      expect(decoded.ids, stackInfo.ids);
      expect(decoded.containers?.keys.length, 2);
    });
  });
}
