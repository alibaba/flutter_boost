package com.idlefish.flutterboost.example;

import android.app.Activity;
import android.content.Intent;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostDelegate;
import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import java.util.Map;

import io.flutter.embedding.android.FlutterActivityLaunchConfigs;

public class MyFlutterBoostDelegate implements FlutterBoostDelegate {

    @Override
    public void pushNativeRoute(String pageName, Map<String, Object> arguments) {
        Activity currentActivity = FlutterBoost.getInstance().currentActivity();
        Intent intent = new Intent(currentActivity, NativePageActivity.class);
        currentActivity.startActivity(intent);
    }

    @Override
    public void pushFlutterRoute(String pageName, String uniqueId, Map<String, Object> arguments) {
        Activity currentActivity = FlutterBoost.getInstance().currentActivity();
        Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(FlutterBoostActivity.class, FlutterBoost.getDefaultEngineId())
                .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
                .destroyEngineWithActivity(false)
                .uniqueId(uniqueId)
                .url(pageName)
                .urlParams(arguments)
                .build(currentActivity);
        currentActivity.startActivity(intent);
    }
}
