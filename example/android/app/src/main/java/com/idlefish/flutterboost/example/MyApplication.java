package com.idlefish.flutterboost.example;

import android.content.Intent;
import android.util.Log;

import com.idlefish.flutterboost.NativeRouterApi;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.containers.FlutterBoostActvity;

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

        FlutterEngine flutterEngine =
                new FlutterEngine(
                        this,
                        null,
                        true, false);
        flutterEngine.getNavigationChannel().setInitialRoute("/");
        flutterEngine.getDartExecutor().executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault());
        FlutterEngineCache.getInstance().put("test", flutterEngine);
        FlutterBoost.instance().init(this, new NativeRouterApi() {

            @Override
            public void pushNativeRoute(String pageName, String uniqueId, Map arguments) {
                Intent intent = new Intent(FlutterBoost.instance().getTopActivity(), NativePageActivity.class);
                FlutterBoost.instance().getTopActivity().startActivity(intent);
            }

            @Override
            public void pushFlutterRoute(String pageName, String uniqueId, Map arguments) {
//                Intent intent = new FBFlutterActivity.CachedEngineIntentBuilder(FBFlutterActivity.class, "test")
//                        .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
//                        .destroyEngineWithActivity(false)
//                        .build(FlutterBoost.instance().getTopActivity());

//                Intent intent=  BoostFlutterActivity.createDefaultIntent(FlutterBoost.instance().getTopActivity().getBaseContext());

                Intent intent = new FlutterBoostActvity.CachedEngineIntentBuilder(FlutterBoostActvity.class, "test")
                        .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
                        .destroyEngineWithActivity(false)
                        .build(FlutterBoost.instance().getTopActivity());


                FlutterBoost.instance().getTopActivity().startActivity(intent);
            }

            @Override
            public void popRoute(String pageName, String uniqueId) {
                FlutterBoost.instance().getTopActivity().finish();
            }
        });


    }
}
