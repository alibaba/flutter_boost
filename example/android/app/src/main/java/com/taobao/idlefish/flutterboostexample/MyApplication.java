package com.taobao.idlefish.flutterboostexample;

import android.app.Application;
import android.content.Context;

import com.taobao.idlefish.flutterboost.BoostFlutterEngine;
import com.taobao.idlefish.flutterboost.BoostFlutterView;
import com.taobao.idlefish.flutterboost.Debuger;
import com.taobao.idlefish.flutterboost.FlutterBoostPlugin;
import com.taobao.idlefish.flutterboost.StateListener;
import com.taobao.idlefish.flutterboost.interfaces.IPlatform;
import com.taobao.idlefish.flutterboost.interfaces.IStateListener;

import java.util.Map;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MyApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();

        FlutterBoostPlugin.init(new IPlatform() {
            @Override
            public Application getApplication() {
                return MyApplication.this;
            }

            @Override
            public void onRegisterPlugins(PluginRegistry registry) {
                GeneratedPluginRegistrant.registerWith(registry);
            }

            @Override
            public boolean isDebug() {
                return true;
            }

            /**
             * 如果flutter想打开一个本地页面，将会回调这个方法，页面参数将会拼接在url中
             *
             * 例如：sample://nativePage?aaa=bbb
             *
             * 参数就是类似 aaa=bbb 这样的键值对
             *
             * @param context
             * @param url
             * @param requestCode
             * @return
             */
            @Override
            public boolean startActivity(Context context, String url, Map params, int requestCode) {
                Debuger.log("startActivity url="+url);

                return PageRouter.openPageByUrl(context,url,params,requestCode);
            }

            @Override
            public int whenEngineStart() {
                return IMMEDIATELY;
            }
        });
    }
}
