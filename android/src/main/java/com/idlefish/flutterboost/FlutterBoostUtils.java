package com.idlefish.flutterboost;

import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Helper methods to deal with common tasks.
 */
public class FlutterBoostUtils {
    public static String createUniqueId(String name) {
        return UUID.randomUUID().toString() + "_" + name;
    }

    public static FlutterBoostPlugin getPlugin(FlutterEngine engine) {
        if (engine != null) {
            try {
                Class<? extends FlutterPlugin> pluginClass =
                        (Class<? extends FlutterPlugin>) Class.forName("com.idlefish.flutterboost.FlutterBoostPlugin");
                return (FlutterBoostPlugin) engine.getPlugins().get(pluginClass);
            } catch (Throwable t) {
              t.printStackTrace();
            }
        }
        return null;
    }

    public static Map<Object, Object> bundleToMap(Bundle bundle) {
        Map<Object, Object> map = new HashMap<>();
        if(bundle == null || bundle.keySet().isEmpty()) {
            return map;
        }
        Set<String> keys = bundle.keySet();
        for (String key : keys) {
            Object value = bundle.get(key);
            if(value instanceof Bundle) {
                map.put(key, bundleToMap(bundle.getBundle(key)));
            } else if (value != null){
                map.put(key, value);
            }
        }
        return map;
    }

    public static FlutterView findFlutterView(View view) {
        if (view instanceof FlutterView) {
            return (FlutterView) view;
        }
        if (view instanceof ViewGroup) {
            ViewGroup vp = (ViewGroup) view;
            for (int i = 0; i < vp.getChildCount(); i++) {
                View child = vp.getChildAt(i);
                FlutterView fv = findFlutterView(child);
                if (fv != null) {
                    return fv;
                }
            }
        }
        return null;
    }
}