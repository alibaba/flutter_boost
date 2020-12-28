package com.idlefish.flutterboost.containers;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;

/**
 * 在官方FlutterActivityAndFragmentDelegate 的基础上进行补充修复
 *
 * 1. 去除flutterEngine.getLifecycleChannel().appIsDetached
 *
 * 2. flutterEngine.getLifecycleChannel().appIsPaused()
 *
 */
class DelegatePatch {



}
