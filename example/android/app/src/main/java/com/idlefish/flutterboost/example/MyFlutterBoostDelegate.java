package com.idlefish.flutterboost.example;

import android.content.Intent;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostDelegate;
import com.idlefish.flutterboost.FlutterBoostRouteOptions;
import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import java.util.Map;

import io.flutter.embedding.android.FlutterActivityLaunchConfigs;
import com.idlefish.flutterboost.FlutterBoostDelegate;

public class MyFlutterBoostDelegate implements FlutterBoostDelegate {

    @Override
    public void pushNativeRoute(FlutterBoostRouteOptions options) {
        Intent intent = new Intent(FlutterBoost.instance().currentActivity(), NativePageActivity.class);
        FlutterBoost.instance().currentActivity().startActivityForResult(intent, options.requestCode());
    }

    @Override
    public void pushFlutterRoute(FlutterBoostRouteOptions options) {
        Class<? extends FlutterBoostActivity> activityClass = options.opaque() ? FlutterBoostActivity.class : TransparencyPageActivity.class;
        Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(activityClass)
                    .destroyEngineWithActivity(false)
                    .uniqueId(options.uniqueId())
                    .url(options.pageName())
                    .urlParams(options.arguments())
                    .build(FlutterBoost.instance().currentActivity());
        FlutterBoost.instance().currentActivity().startActivity(intent);
    }
}
