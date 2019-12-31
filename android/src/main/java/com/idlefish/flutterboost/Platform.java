package com.idlefish.flutterboost;

import android.app.Application;
import android.content.Context;
import android.util.Log;
import com.idlefish.flutterboost.interfaces.IContainerRecord;

import java.lang.reflect.Method;
import java.util.Map;

import io.flutter.embedding.android.FlutterView;
import io.flutter.plugin.common.PluginRegistry;

public abstract class Platform {

    public abstract Application getApplication();

    public abstract void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts);

    public abstract int whenEngineStart();


    public abstract FlutterView.RenderMode renderMode();

    public abstract boolean isDebug();

    public abstract String initialRoute();

    public FlutterBoost.BoostLifecycleListener lifecycleListener;

    public FlutterBoost.BoostPluginsRegister pluginsRegister;

    public void closeContainer(IContainerRecord record, Map<String, Object> result, Map<String, Object> exts) {
        if (record == null) return;

        record.getContainer().finishContainer(result);
    }


    public void registerPlugins(PluginRegistry mRegistry) {

        if(pluginsRegister!=null){
            pluginsRegister.registerPlugins(mRegistry);
        }else{
            try {
                Class clz = Class.forName("io.flutter.plugins.GeneratedPluginRegistrant");
                Method method = clz.getDeclaredMethod("registerWith", PluginRegistry.class);
                method.invoke(null, mRegistry);
            } catch (Throwable t) {
                Log.i("flutterboost.platform",t.toString());
            }
        }

        if (lifecycleListener!= null) {
            lifecycleListener.onPluginsRegistered();
        }
    }
}
