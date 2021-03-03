class Logger {
  static void log(String msg) {
    assert(() {
      print('FlutterBoost#$msg');
      return true;
    }());
    //print('FlutterBoost=>$msg');
  }

  static void error(String msg) {
    print('FlutterBoost#$msg');
  }
}
