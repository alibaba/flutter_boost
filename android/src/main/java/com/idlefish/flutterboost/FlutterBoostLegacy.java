package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.view.FlutterMain;

public class FlutterBoostLegacy {
    private FlutterEngine engine = null;

    private FlutterBoostLegacy(FlutterEngine engine) {
        this.engine = engine;
    }

    public static FlutterBoostLegacy withEngineId(String engineId) {
        FlutterEngine engine = FlutterEngineCache.getInstance().get(engineId);
        if (engine != null) {
            return new FlutterBoostLegacy(engine);
        }
        return null;
    }

    public static FlutterBoostLegacy withEngine(FlutterEngine engine) {
        if (engine != null) {
            return new FlutterBoostLegacy(engine);
        }
        return null;
    }

    /**
     * Gets the FlutterView container with uniqueId.
     *
     * This is a legacy API for backwards compatibility.
     * 
     * @param uniqueId The uniqueId of the container
     * @return a FlutterView container
     */
    public FlutterViewContainer findFlutterViewContainerById(String uniqueId) {
        FlutterBoostPlugin plugin = FlutterBoostUtils.getFlutterBoostPlugin(engine);
        if (plugin != null) {
            return plugin.findContainerById(uniqueId);
        }
        return null;
    }

    /**
     * Gets the topmost container
     * 
     * This is a legacy API for backwards compatibility.
     * 
     * @return the topmost container
     */
    public FlutterViewContainer getTopContainer() {
        FlutterBoostPlugin plugin = FlutterBoostUtils.getFlutterBoostPlugin(engine);
        if (plugin != null) {
            return plugin.getTopContainer();
        }
        return null;
    }

    /**
     * Open a Flutter page with name and arguments.
     * 
     * @param name The Flutter route name.
     * @param arguments The bussiness arguments.
     */
    public void open(String name, Map<String, Object> arguments) {
        FlutterBoostPlugin plugin = FlutterBoostUtils.getFlutterBoostPlugin(engine);
        if (plugin != null) {
            plugin.getDelegate().pushFlutterRoute(name, null, arguments);
        }
    }

    /**
     * Close the Flutter page with uniqueId.
     * 
     * @param uniqueId The uniqueId of the Flutter page
     */
    public void close(String uniqueId) {
        Messages.CommonParams params= new Messages.CommonParams();
        params.setUniqueId(uniqueId);
        FlutterBoostPlugin plugin = FlutterBoostUtils.getFlutterBoostPlugin(engine);
        if (plugin != null) {
            plugin.popRoute(params);
        }
    }
}
