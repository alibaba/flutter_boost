package com.taobao.idlefish.flutterboostexample;

import android.app.Application;
import android.content.Context;

import com.idlefish.flutterboost.BoostEngineProvider;
import com.idlefish.flutterboost.BoostFlutterEngine;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.Platform;
import com.idlefish.flutterboost.interfaces.IFlutterEngineProvider;

import java.util.Map;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.view.FlutterMain;

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
            public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
                PageRouter.openPageByUrl(context,url,urlParams,requestCode);
            }

            @Override
            public IFlutterEngineProvider engineProvider() {
                return new BoostEngineProvider(){
                    @Override
                    public BoostFlutterEngine createEngine(Context context) {
                        return new BoostFlutterEngine(context, new DartExecutor.DartEntrypoint(
                                context.getResources().getAssets(),
                                FlutterMain.findAppBundlePath(context),
                                "main"),"/");
                    }
                };
            }

            @Override
            public int whenEngineStart() {
                return ANY_ACTIVITY_CREATED;
            }
        });
    }
}
