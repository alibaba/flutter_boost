package com.taobao.idlefish.flutterboostexample;

import android.app.Application;
import android.content.Context;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.Platform;

import java.util.Map;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MyApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();

        FlutterBoost.init(new Platform() {

            @Override
            public Application getApplication() {
                return MyApplication.this;
            }

            @Override
            public boolean isDebug() {
                return true;
            }

            @Override
            public void registerPlugins(PluginRegistry registry) {
                GeneratedPluginRegistrant.registerWith(registry);
            }

            @Override
            public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
                PageRouter.openPageByUrl(context,url,urlParams,requestCode);
            }

            @Override
            public int whenEngineStart() {
                return LAZY;
            }
        });
    }
}
