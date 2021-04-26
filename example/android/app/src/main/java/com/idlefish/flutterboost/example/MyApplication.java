package com.idlefish.flutterboost.example;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostConfig;

import io.flutter.FlutterInjector;
import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.dart.DartExecutor;

public class MyApplication extends FlutterApplication {


    @Override
    public void onCreate() {
        super.onCreate();

        //1.最常用的默认情况
        FlutterBoost.instance().setup(this, new MyFlutterBoostDelegate(), engine -> {

        });
//
//        /**  2.完全自定义engine的情况  **/
//        FlutterEngine customizedEngine = new FlutterEngine(this);
//        customizedEngine.getNavigationChannel().setInitialRoute("/");
//        customizedEngine.getDartExecutor().executeDartEntrypoint(new DartExecutor.DartEntrypoint(
//                FlutterInjector.instance().flutterLoader().findAppBundlePath(), "main"));
//        FlutterEngineCache.getInstance().put("flutter_boost_default_engine", customizedEngine);
//
//        //设置config中engine
//        FlutterBoostConfig config = FlutterBoostConfig.getDefaultConfig()
//                .engine(customizedEngine);
//        FlutterBoost.instance().setup(this, new MyFlutterBoostDelegate(), config, engine -> {
//
//        });

//
//        /** 3.自定义部分参数的情况,不想完全自定义engine的情况   **/
//        FlutterBoostConfig config2 = FlutterBoostConfig.getDefaultConfig()
//                .initialRoute("/")
//                .entryPoint("main")
//                .flutterShellArgs(new FlutterShellArgs(new String[]{}));
//
//        FlutterBoost.instance().setup(this, new MyFlutterBoostDelegate(), config2, engine -> {
//
//        });
//
//

    }
}

