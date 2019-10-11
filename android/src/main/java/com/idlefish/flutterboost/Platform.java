package com.idlefish.flutterboost;

import android.app.Application;
import android.content.Context;
import com.idlefish.flutterboost.interfaces.IContainerRecord;

import java.lang.reflect.Method;
import java.util.Map;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterMain;

public abstract class Platform {


    public FlutterEngine mEngine ;

    public abstract  Application getApplication();

    public abstract void openContainer(Context context, String url, Map<String,Object> urlParams, int requestCode, Map<String,Object> exts);

    public  abstract int whenEngineStart() ;

    public abstract  FlutterView.RenderMode  renderMode();

    public abstract boolean isDebug() ;

    public  abstract String initialRoute();


    public void closeContainer(IContainerRecord record, Map<String, Object> result, Map<String, Object> exts) {
        if(record == null) return;

        record.getContainer().finishContainer(result);
    }

    public FlutterEngine engineProvider() {
        if (mEngine == null) {
            FlutterShellArgs flutterShellArgs = new FlutterShellArgs(new String[0]);
            FlutterMain.ensureInitializationComplete(
                    getApplication().getApplicationContext(), flutterShellArgs.toArray());

            mEngine = new FlutterEngine( getApplication().getApplicationContext());

        }
        return mEngine;

    }

    public void registerPlugins(PluginRegistry registry) {
        try {
            Class clz = Class.forName("io.flutter.plugins.GeneratedPluginRegistrant");
            Method method = clz.getDeclaredMethod("registerWith",PluginRegistry.class);
            method.invoke(null,registry);
        }catch (Throwable t){
            throw new RuntimeException(t);
        }
    }


}
