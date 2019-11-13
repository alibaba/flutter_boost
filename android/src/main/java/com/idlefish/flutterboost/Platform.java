package com.idlefish.flutterboost;

import android.app.Application;
import android.content.Context;
import com.idlefish.flutterboost.interfaces.IContainerRecord;

import java.lang.reflect.Method;
import java.util.Map;

import io.flutter.embedding.android.FlutterView;
import io.flutter.plugin.common.PluginRegistry;

public abstract class Platform {

    public abstract Application getApplication();

    public abstract void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts);

    public abstract int whenEngineStart();
    public abstract int whenEngineDestroy();

    public abstract FlutterView.RenderMode renderMode();

    public abstract boolean isDebug();

    public abstract String initialRoute();

    public NewFlutterBoost.BoostLifecycleListener lifecycleListener;

    public void closeContainer(IContainerRecord record, Map<String, Object> result, Map<String, Object> exts) {
        if (record == null) return;

        record.getContainer().finishContainer(result);
    }





}
