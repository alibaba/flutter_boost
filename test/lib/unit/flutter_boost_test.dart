
import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('test iOS edge swipe then drop back at starting point works',
      (WidgetTester tester) async {
    //push app
  });



  test('test onMethodCall', () async {

    FlutterBoost.singleton.registerDefaultPageBuilder((pageName, params, _) => Container());
    try {
      FlutterBoost.singleton.open("url");
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }
    try {
      FlutterBoost.singleton.close("url");
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }
    try {
      FlutterBoost.singleton.close("closeCurrent");
    } catch (e) {
      expect(e, isNoSuchMethodError);
    }



  });




}
