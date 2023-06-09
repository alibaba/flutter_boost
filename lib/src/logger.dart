// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class Logger {
  static void log(String msg) {
    assert(() {
      debugPrint('FlutterBoost_dart#$msg');
      return true;
    }());
  }

  static void error(String msg) {
    debugPrint('FlutterBoost_dart#$msg');
  }
}
