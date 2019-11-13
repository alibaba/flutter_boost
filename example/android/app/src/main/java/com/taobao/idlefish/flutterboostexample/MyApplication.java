package com.taobao.idlefish.flutterboostexample;

import android.app.Application;
import android.content.Context;

import android.util.Log;
import com.idlefish.flutterboost.*;

import java.util.Map;

import com.idlefish.flutterboost.interfaces.INativeRouter;
import io.flutter.embedding.android.FlutterView;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

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

        FlutterBoost.BoostPluginsRegister pluginsRegister= new FlutterBoost.BoostPluginsRegister(){

            @Override
            public void registerPlugins(PluginRegistry mRegistry) {
                GeneratedPluginRegistrant.registerWith(mRegistry);
                TextPlatformViewPlugin.register(mRegistry.registrarFor("TextPlatformViewPlugin"));
            }
        };

        Platform platform= new FlutterBoost
                .ConfigBuilder(this,router)
                .isDebug(true)
                .whenEngineStart(FlutterBoost.ConfigBuilder.ANY_ACTIVITY_CREATED)
                .renderMode(FlutterView.RenderMode.texture)
                .pluginsRegister(pluginsRegister)
                .build();

        FlutterBoost.instance().init(platform);



    }
}
