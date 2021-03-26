package com.idlefish.flutterboost;

import java.util.UUID;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class FlutterBoostUtils {
    /**
     * Gets the FlutterBoostPlugin.
     *
     * @return the FlutterBoostPlugin.
     */
    public static FlutterBoostPlugin getFlutterBoostPlugin(FlutterEngine engine) {
        if (engine != null) {
            try {
                Class<? extends FlutterPlugin> pluginClass =
                        (Class<? extends FlutterPlugin>) Class.forName("com.idlefish.flutterboost.FlutterBoostPlugin");
                return (FlutterBoostPlugin) engine.getPlugins().get(pluginClass);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public static String createUniqueId() {
        return UUID.randomUUID().toString();
    }
}