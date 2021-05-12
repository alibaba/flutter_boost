package com.idlefish.flutterboost;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Helper methods to deal with common tasks.
 */
public class FlutterBoostUtils {
  public static String createUniqueId(String name) {
    return System.currentTimeMillis() + "_" + name;
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
}