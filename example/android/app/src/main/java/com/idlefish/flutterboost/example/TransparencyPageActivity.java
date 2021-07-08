package com.idlefish.flutterboost.example;

import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;

public class TransparencyPageActivity  extends FlutterBoostActivity {
    @Override
    protected BackgroundMode getBackgroundMode() {
         return BackgroundMode.transparent;
    }
}
