import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  TestWidgetsFlutterBinding.ensureInitialized();

  group('flutter_boost', () {
    response = null;

    test('init successfully', () async {
      Function builder = FlutterBoost.init();

      expect(
        builder.runtimeType,
        TransitionBuilder,
      );
    });

    test('open successfully', () async {
      Future<Map<dynamic, dynamic>> result = FlutterBoost.singleton.open("url");

      expect(
        result,
        isInstanceOf<Future<Map<dynamic, dynamic>>>(),
      );
    });


//    test('close successfully', () async {
//      Future<bool> result = FlutterBoost.singleton.close("id");
//
//      expect(
//        result,
//        isInstanceOf<bool>(),
//      );
//    });


  });
}
