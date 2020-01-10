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

        FlutterBoost.BoostLifecycleListener boostLifecycleListener= new FlutterBoost.BoostLifecycleListener(){

            @Override
            public void onEngineCreated() {

            }

            @Override
            public void onPluginsRegistered() {

            }

            @Override
            public void onEngineDestroy() {

            }

        };

        //
        // AndroidManifest.xml 中必须要添加 flutterEmbedding 版本设置
        //
        //   <meta-data android:name="flutterEmbedding"
        //               android:value="2">
        //    </meta-data>
        // GeneratedPluginRegistrant 会自动生成 新的插件方式　
        //
        //
        Platform platform= new FlutterBoost
                .ConfigBuilder(this,router)
                .isDebug(true)
                .whenEngineStart(FlutterBoost.ConfigBuilder.ANY_ACTIVITY_CREATED)
                .renderMode(FlutterView.RenderMode.texture)
                .lifecycleListener(boostLifecycleListener)
                .build();

        FlutterBoost.instance().init(platform);



    }
}
