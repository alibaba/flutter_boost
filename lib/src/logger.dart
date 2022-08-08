import 'package:flutter/material.dart';

class Logger {
  static void log(String msg) {
    assert(() {
      debugPrint('FlutterBoost#$msg');
      return true;
    }());
  }

  static void error(String msg) {
    debugPrint('FlutterBoost#$msg');
  }
}
