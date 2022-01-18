class Logger {
  static void log(String msg) {
    assert(() {
      print('FlutterBoost#$msg');
      return true;
    }());
  }

  static void error(String msg) {
    print('FlutterBoost#$msg');
  }
}
