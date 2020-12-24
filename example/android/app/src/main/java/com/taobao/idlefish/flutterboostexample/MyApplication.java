package com.taobao.idlefish.flutterboostexample;

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
//                if(FlutterBoost.instance().getTopActivity() instanceof BoostFlutterActvity){
//                    return;
//                }

//                Intent intent = new FBFlutterActivity.CachedEngineIntentBuilder(FBFlutterActivity.class, "test")
//                        .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
//                        .destroyEngineWithActivity(false)
//                        .build(FlutterBoost.instance().getTopActivity());


                Intent intent = new FlutterBoostActvity.CachedEngineIntentBuilder(FlutterBoostActvity.class, "test")
                        .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
                        .destroyEngineWithActivity(false)
                        .build(FlutterBoost.instance().getTopActivity());


//                Intent intent=  BoostFlutterActivity.createDefaultIntent(FlutterBoost.instance().getTopActivity().getBaseContext());


                FlutterBoost.instance().getTopActivity().startActivity(intent);
            }

            @Override
            public void popRoute(String pageName, String uniqueId) {
                FlutterBoost.instance().getTopActivity().finish();
                Log.e("xxxx", "popRoute");
            }
        });


    }
//        INativeRouter router =new INativeRouter() {
//            @Override
//            public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
//               String  assembleUrl=Utils.assembleUrl(url,urlParams);
//                PageRouter.openPageByUrl(context,assembleUrl, urlParams);
//            }
//
//        };
//
//        FlutterBoost.BoostLifecycleListener boostLifecycleListener= new FlutterBoost.BoostLifecycleListener(){
//
//            @Override
//            public void beforeCreateEngine() {
//
//            }
//
//            @Override
//            public void onEngineCreated() {
//
//            }
//
//            @Override
//            public void onPluginsRegistered() {
//
//            }
//
//            @Override
//            public void onEngineDestroy() {
//
//            }
//
//        };
//
//        //
//        // AndroidManifest.xml 中必须要添加 flutterEmbedding 版本设置
//        //
//        //   <meta-data android:name="flutterEmbedding"
//        //               android:value="2">
//        //    </meta-data>
//        // GeneratedPluginRegistrant 会自动生成 新的插件方式　
//        //
//        // 插件注册方式请使用
//        // FlutterBoost.instance().engineProvider().getPlugins().add(new FlutterPlugin());
//        // GeneratedPluginRegistrant.registerWith()，是在engine 创建后马上执行，放射形式调用
//        //
//
//        Platform platform= new FlutterBoost
//                .ConfigBuilder(this,router)
//                .isDebug(true)
//                .whenEngineStart(FlutterBoost.ConfigBuilder.IMMEDIATELY)
//                .renderMode(FlutterView.RenderMode.texture)
//                .lifecycleListener(boostLifecycleListener)
//                .build();
//        FlutterBoost.instance().init(platform);
//
//        // whenEngineStart(FlutterBoost.ConfigBuilder.IMMEDIATELY) 时候，engine才初始化好。
//        if(FlutterBoost.instance().engineProvider()!=null){
//            PlatformViewRegistry registry = FlutterBoost.instance().engineProvider().getPlatformViewsController().getRegistry();
//            registry.registerViewFactory("plugins.test/view",
//                    new TextPlatformViewFactory(StandardMessageCodec.INSTANCE));
//        }
//
//    }
}
