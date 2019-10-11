package com.taobao.idlefish.flutterboostexample;

import android.app.Application;
import android.content.Context;

import com.idlefish.flutterboost.*;
import com.idlefish.flutterboost.interfaces.IContainerRecord;

import java.util.Map;

import com.idlefish.flutterboost.interfaces.INativeRouter;
import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {
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

        Platform platform= new NewFlutterBoost
                .ConfigBuilder(this,router)
                .isDebug(true)
                .whenEngineStart(NewFlutterBoost.ConfigBuilder.ANY_ACTIVITY_CREATED)
                .build();

        NewFlutterBoost.instance().init(platform);
    }
}
