package com.taobao.idlefish.flutterboostexample;

import android.app.Application;
import android.content.Context;

import com.idlefish.flutterboost.*;
import com.idlefish.flutterboost.interfaces.IContainerRecord;
import com.idlefish.flutterboost.interfaces.IFlutterEngineProvider;

import java.util.Map;

import com.idlefish.flutterboost.interfaces.INativeRouter;
import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
//
//        FlutterBoost.init(new Platform() {
//
//            @Override
//            public Application getApplication() {
//                return MyApplication.this;
//            }
//
//            @Override
//            public boolean isDebug() {
//                return true;
//            }
//
//            @Override
//            public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
//                PageRouter.openPageByUrl(context, url, urlParams, requestCode);
//            }
//
//            @Override
//            public IFlutterEngineProvider engineProvider() {
//                return new BoostEngineProvider() {
//                    @Override
//                    public BoostFlutterEngine createEngine(Context context) {
//                        return new BoostFlutterEngine(context);
//                    }
//                };
//            }
//
//            @Override
//            public int whenEngineStart() {
//                return ANY_ACTIVITY_CREATED;
//            }
//        });

//        FlutterBoostPlugin.addActionAfterRegistered(new FlutterBoostPlugin.ActionAfterRegistered() {
//            @Override
//            public void onChannelRegistered(FlutterBoostPlugin channel) {
//                //platform view register should use FlutterPluginRegistry instread of BoostPluginRegistry
//                TextPlatformViewPlugin.register(FlutterBoost.singleton().engineProvider().tryGetEngine().getPluginRegistry());
//            }
//        });


        INativeRouter router =new INativeRouter() {
            @Override
            public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
                PageRouter.openPageByUrl(context,url, urlParams);
            }

            @Override
            public void closeContainer(IContainerRecord record, Map<String, Object> result, Map<String, Object> exts) {

            }
        };
        Platform platform= new NewFlutterBoost.ConfigBuilder(this,router).build();
        NewFlutterBoost.instance().init(platform);
    }
}
