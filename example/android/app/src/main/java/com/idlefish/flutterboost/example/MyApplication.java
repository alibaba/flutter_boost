package com.idlefish.flutterboost.example;

import android.content.Intent;

import com.idlefish.flutterboost.NativeRouterApi;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.containers.CopyFlutterActvity;
import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import java.util.Map;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;


public class MyApplication extends FlutterApplication {


    @Override
    public void onCreate() {
        super.onCreate();

        FlutterBoost.withDefaultEngine().init(this, new NativeRouterApi() {

            @Override
            public void pushNativeRoute(String pageName, Map arguments) {
                Intent intent = new Intent(FlutterBoost.instance().getTopActivity(), NativePageActivity.class);
                FlutterBoost.instance().getTopActivity().startActivity(intent);
            }

            @Override
            public void pushFlutterRoute(String pageName, String uniqueId, Map arguments) {

                Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(FlutterBoostActivity.class, "test")
                        .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
                        .destroyEngineWithActivity(false)
                        .pageName(pageName)
                        .uniqueId(uniqueId)
                        .build(FlutterBoost.instance().getTopActivity());


                FlutterBoost.instance().getTopActivity().startActivity(intent);
            }

        });


    }
}
