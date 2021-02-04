package com.idlefish.flutterboost.example;

import android.content.Intent;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostDelegate;
import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import java.util.HashMap;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs;

public class MyApplication extends FlutterApplication {


    @Override
    public void onCreate() {
        super.onCreate();

        FlutterBoost.instance().setup(this, new FlutterBoostDelegate() {

            @Override
            public void pushNativeRoute(String pageName, HashMap<String, String> arguments) {
                Intent intent = new Intent(FlutterBoost.instance().currentActivity(), NativePageActivity.class);
                FlutterBoost.instance().currentActivity().startActivity(intent);
            }

            @Override
            public void pushFlutterRoute(String pageName, HashMap<String, String> arguments) {
                Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(FlutterBoostActivity.class, FlutterBoost.ENGINE_ID)
                        .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
                        .destroyEngineWithActivity(false)
                        .url(pageName)
                        .urlParams(arguments)
                        .build(FlutterBoost.instance().currentActivity());
                FlutterBoost.instance().currentActivity().startActivity(intent);
            }

        },engine->{
            engine.getPlugins();
        } );


    }
}
