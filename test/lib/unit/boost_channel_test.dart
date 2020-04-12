import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/channel/boost_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('flutter_boost');
  final List<MethodCall> log = <MethodCall>[];
  dynamic response;

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    print(methodCall);
    log.add(methodCall);
    return response;
  });

  tearDown(() {
    log.clear();
  });

  group('boost_channel', () {
    response = null;

    test('sendEvent successfully', () async {
      final Map<String, dynamic> msg1 = <String, dynamic>{};
      BoostChannel().sendEvent('name', msg1);

      final Map<String, dynamic> msg = <String, dynamic>{};
      msg['name'] = 'name';
      msg['arguments'] = msg1;

      expect(
        log,
        <Matcher>[isMethodCall('__event__', arguments: msg)],
      );
    });

    test('invokeMethod successfully', () async {
      final Map<String, dynamic> msg = <String, dynamic>{};
      msg['test'] = 'test';
      BoostChannel().invokeMethod<dynamic>('__event__1', msg);

      expect(
        log,
        <Matcher>[isMethodCall('__event__1', arguments: msg)],
      );
    });

    test('invokeListMethod successfully', () async {
      final Map<String, dynamic> msg = <String, dynamic>{};
      msg['test'] = 'test';
      await BoostChannel().invokeListMethod<dynamic>('__event__1', msg);

      expect(
        log,
        <Matcher>[isMethodCall('__event__1', arguments: msg)],
      );
    });

    test('invokeMapMethod successfully', () async {
      final Map<String, dynamic> msg = <String, dynamic>{};
      msg['test'] = 'test';
      BoostChannel().invokeMapMethod<dynamic, dynamic>('__event__1', msg);

      expect(
        log,
        <Matcher>[isMethodCall('__event__1', arguments: msg)],
      );
    });

    test('invokeMapMethod successfully', () async {
      final Map<String, dynamic> msg = <String, dynamic>{};
      msg['test'] = 'test';
      BoostChannel().invokeMapMethod<dynamic, dynamic>('__event__1', msg);

      expect(
        log,
        <Matcher>[isMethodCall('__event__1', arguments: msg)],
      );
    });

    test('addEventListener successfully', () async {
      final VoidCallback test = BoostChannel().addEventListener(
        'addEventListener',
        (String name, Map<String, dynamic> arguments) async => 'test',
      );
      print('xxx' + test.toString());
      expect(
        test.toString(),
        'Closure: () => Null',
      );
    });

    test('addMethodHandler successfully', () async {
      final VoidCallback test = BoostChannel().addMethodHandler(
        (MethodCall call) async => 'test',
      );
      expect(
        test.toString(),
        'Closure: () => Null',
      );
    });
  });
}
