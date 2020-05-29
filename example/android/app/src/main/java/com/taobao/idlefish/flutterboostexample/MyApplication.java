package com.taobao.idlefish.flutterboostexample;

import android.app.Application;
import android.content.Context;

import android.os.Build;
import android.util.Log;
import com.idlefish.flutterboost.*;

import java.util.HashMap;
import java.util.Map;

import com.idlefish.flutterboost.interfaces.INativeRouter;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMessageCodec;

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
            public void beforeCreateEngine() {

            }

            @Override
            public void onEngineCreated() {

                // 注册MethodChannel，监听flutter侧的getPlatformVersion调用
                MethodChannel methodChannel = new MethodChannel(FlutterBoost.instance().engineProvider().getDartExecutor(), "flutter_native_channel");
                methodChannel.setMethodCallHandler((call, result) -> {

                    if (call.method.equals("getPlatformVersion")) {
                        result.success(Build.VERSION.RELEASE);
                    } else {
                        result.notImplemented();
                    }

                });

                // 注册PlatformView viewTypeId要和flutter中的viewType对应
                FlutterBoost
                        .instance()
                        .engineProvider()
                        .getPlatformViewsController()
                        .getRegistry()
                        .registerViewFactory("plugins.test/view", new TextPlatformViewFactory(StandardMessageCodec.INSTANCE));

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
        // 插件注册方式请使用
        // FlutterBoost.instance().engineProvider().getPlugins().add(new FlutterPlugin());
        // GeneratedPluginRegistrant.registerWith()，是在engine 创建后马上执行，放射形式调用
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
