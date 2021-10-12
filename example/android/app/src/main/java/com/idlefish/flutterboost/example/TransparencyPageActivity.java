package com.idlefish.flutterboost.example;

import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;

public class TransparencyPageActivity  extends FlutterBoostActivity {
    @Override
    protected BackgroundMode getBackgroundMode() {
        if (super.getBackgroundMode() != BackgroundMode.transparent) {
            throw new AssertionError("You *MUST* set FlutterActivity#backgroundMode correctly.");
        }
        return super.getBackgroundMode();
    }
}
