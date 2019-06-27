package com.idlefish.flutterboost;

import com.idlefish.flutterboost.interfaces.IContainerRecord;
import com.idlefish.flutterboost.interfaces.IFlutterEngineProvider;
import com.idlefish.flutterboost.interfaces.IPlatform;

import java.lang.reflect.Method;
import java.util.Map;

import io.flutter.plugin.common.PluginRegistry;

public abstract class Platform implements IPlatform {

    @Override
    public boolean isDebug() {
        return false;
    }

    @Override
    public void closeContainer(IContainerRecord record, Map<String, Object> result, Map<String, Object> exts) {
        if(record == null) return;

        record.getContainer().finishContainer(result);
    }

    @Override
    public IFlutterEngineProvider engineProvider() {
        return new BoostEngineProvider();
    }

    @Override
    public void registerPlugins(PluginRegistry registry) {
        try {
            Class clz = Class.forName("io.flutter.plugins.GeneratedPluginRegistrant");
            Method method = clz.getDeclaredMethod("registerWith",PluginRegistry.class);
            method.invoke(null,registry);
        }catch (Throwable t){
            throw new RuntimeException(t);
        }
    }

    @Override
    public int whenEngineStart() {
        return ANY_ACTIVITY_CREATED;
    }
}
