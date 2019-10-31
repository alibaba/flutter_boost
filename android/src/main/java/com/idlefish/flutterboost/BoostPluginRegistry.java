package com.idlefish.flutterboost;


import io.flutter.Log;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

import java.util.*;


public class BoostPluginRegistry implements PluginRegistry {
    private static final String TAG = "ShimPluginRegistry";
    private final FlutterEngine flutterEngine;
    private final Map<String, Object> pluginMap = new HashMap();
    private final BoostRegistrarAggregate shimRegistrarAggregate;


    public BoostRegistrarAggregate getRegistrarAggregate() {
        return shimRegistrarAggregate;
    }


    public BoostPluginRegistry(FlutterEngine flutterEngine) {
        this.flutterEngine = flutterEngine;
        this.shimRegistrarAggregate = new BoostRegistrarAggregate();
        this.flutterEngine.getPlugins().add(this.shimRegistrarAggregate);
    }

    public Registrar registrarFor(String pluginKey) {
        Log.v("ShimPluginRegistry", "Creating plugin Registrar for '" + pluginKey + "'");
        if (this.pluginMap.containsKey(pluginKey)) {
            throw new IllegalStateException("Plugin key " + pluginKey + " is already in use");
        } else {
            this.pluginMap.put(pluginKey, (Object) null);
            BoostRegistrar registrar = new BoostRegistrar(pluginKey, this.pluginMap);
            this.shimRegistrarAggregate.addPlugin(registrar);
            return registrar;
        }
    }

    public boolean hasPlugin(String pluginKey) {
        return this.pluginMap.containsKey(pluginKey);
    }

    public Object valuePublishedByPlugin(String pluginKey) {
        return this.pluginMap.get(pluginKey);
    }

    public static class BoostRegistrarAggregate implements FlutterPlugin, ActivityAware {
        private final Set<BoostRegistrar> shimRegistrars;
        private FlutterPluginBinding flutterPluginBinding;
        private ActivityPluginBinding activityPluginBinding;

        public ActivityPluginBinding getActivityPluginBinding() {
            return activityPluginBinding;
        }

        private BoostRegistrarAggregate() {
            this.shimRegistrars = new HashSet();
        }

        public void addPlugin(BoostRegistrar shimRegistrar) {
            this.shimRegistrars.add(shimRegistrar);
            if (this.flutterPluginBinding != null) {
                shimRegistrar.onAttachedToEngine(this.flutterPluginBinding);
            }

            if (this.activityPluginBinding != null) {
                shimRegistrar.onAttachedToActivity(this.activityPluginBinding);
            }

        }

        public void onAttachedToEngine(FlutterPluginBinding binding) {
            this.flutterPluginBinding = binding;
            Iterator var2 = this.shimRegistrars.iterator();

            while (var2.hasNext()) {
                BoostRegistrar shimRegistrar = (BoostRegistrar) var2.next();
                shimRegistrar.onAttachedToEngine(binding);
            }

        }

        public void onDetachedFromEngine(FlutterPluginBinding binding) {
            Iterator var2 = this.shimRegistrars.iterator();

            while (var2.hasNext()) {
                BoostRegistrar shimRegistrar = (BoostRegistrar) var2.next();
                shimRegistrar.onDetachedFromEngine(binding);
            }

            this.flutterPluginBinding = null;
        }

        public void onAttachedToActivity(ActivityPluginBinding binding) {
            this.activityPluginBinding = binding;
            Iterator var2 = this.shimRegistrars.iterator();

            while (var2.hasNext()) {
                BoostRegistrar shimRegistrar = (BoostRegistrar) var2.next();
                shimRegistrar.onAttachedToActivity(binding);
            }

        }

        public void onDetachedFromActivityForConfigChanges() {
            Iterator var1 = this.shimRegistrars.iterator();

            while (var1.hasNext()) {
                BoostRegistrar shimRegistrar = (BoostRegistrar) var1.next();
                shimRegistrar.onDetachedFromActivity();
            }

            this.activityPluginBinding = null;
        }

        public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
            Iterator var2 = this.shimRegistrars.iterator();

            while (var2.hasNext()) {
                BoostRegistrar shimRegistrar = (BoostRegistrar) var2.next();
                shimRegistrar.onReattachedToActivityForConfigChanges(binding);
            }

        }

        public void onDetachedFromActivity() {
            Iterator var1 = this.shimRegistrars.iterator();

            while (var1.hasNext()) {
                BoostRegistrar shimRegistrar = (BoostRegistrar) var1.next();
                shimRegistrar.onDetachedFromActivity();
            }

        }
    }
}

