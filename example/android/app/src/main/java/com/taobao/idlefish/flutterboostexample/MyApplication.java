package com.taobao.idlefish.flutterboostexample;

import android.app.Application;
import android.content.Context;

import android.util.Log;
import com.idlefish.flutterboost.*;
import com.idlefish.flutterboost.interfaces.IContainerRecord;

import java.util.Map;

import com.idlefish.flutterboost.interfaces.INativeRouter;
import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.MethodChannel;

public class MyApplication extends Application {


    @Override
    public void onCreate() {
        super.onCreate();
        INativeRouter router =new INativeRouter() {
            @Override
            public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
               String  assembleUrl=Utils.assembleUrl(url,urlParams);
                PageRouter.openPageByUrl(context,assembleUrl, urlParams);
            }

        };

        NewFlutterBoost.BoostLifecycleListener lifecycleListener= new NewFlutterBoost.BoostLifecycleListener() {
            @Override
            public void onEngineCreated() {

            }

            @Override
            public void onPluginsRegistered() {
                MethodChannel mMethodChannel = new MethodChannel( NewFlutterBoost.instance().engineProvider().getDartExecutor(), "boosttest");
                Log.e("MyApplication","MethodChannel create");
            }

            @Override
            public void onEngineDestroy() {

            }
        };
        Platform platform= new NewFlutterBoost
                .ConfigBuilder(this,router)
                .isDebug(true)
                .whenEngineStart(NewFlutterBoost.ConfigBuilder.ANY_ACTIVITY_CREATED)
                .lifecycleListener(lifecycleListener)
                .build();

        NewFlutterBoost.instance().init(platform);




    }
}
