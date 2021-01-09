package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.view.FlutterMain;

public class FlutterBoost {

    public final static String ENGINE_ID = "flutter_boost_default_engine";

    private static FlutterBoost sInstance = null;

    private Activity topActivity = null;

    private ContainerManager containerManager;

    private FlutterBoostPlugin plugin;

    FlutterBoost(){
        containerManager=new ContainerManager();
    }

    public ContainerManager getContainerManager() {
        return containerManager;
    }

    public static FlutterBoost instance() {
        if (sInstance == null) {
            sInstance = new FlutterBoost();
        }
        return sInstance;
    }


    public static DefaultEngineConfig withDefaultEngine() {
        return new DefaultEngineConfig();
    }

    public static class DefaultEngineConfig {
        private String initialRoute = "/";
        private String dartEntrypointFunctionName = "main";

        public DefaultEngineConfig() {
        }

        @NonNull
        public DefaultEngineConfig initialRoute(@NonNull String initialRoute) {
            this.initialRoute = initialRoute;
            return this;
        }

        @NonNull
        public DefaultEngineConfig entrypoint(@NonNull String dartEntrypointFunctionName) {
            this.dartEntrypointFunctionName = dartEntrypointFunctionName;
            return this;
        }

        public void init(Application application, NativeRouterApi api) {
            // 1. initialize default engine
            FlutterEngine engine = FlutterEngineCache.getInstance().get(ENGINE_ID);
            if (engine == null) {
                engine = new FlutterEngine(application);
                engine.getNavigationChannel().setInitialRoute(this.initialRoute);
                engine.getDartExecutor().executeDartEntrypoint(new DartExecutor.DartEntrypoint(
                        FlutterMain.findAppBundlePath(), this.dartEntrypointFunctionName));
                FlutterEngineCache.getInstance().put(ENGINE_ID, engine);
            }

            // 2. set delegate
            FlutterBoost.instance().getPlugin().setDelegate(api);

            //3. register ActivityLifecycleCallbacks
            FlutterBoost.instance().setupActivityLifecycleCallback(application);

        }
    }

    public FlutterBoostPlugin getPlugin() {
        if (plugin == null) {
            FlutterEngine engine = FlutterEngineCache.getInstance().get(ENGINE_ID);
            if (engine == null) {
                throw new RuntimeException("FlutterBoost might not have been initialized yet!!!");
            }

            try {
                Class<? extends FlutterPlugin> pluginClass =
                        (Class<? extends FlutterPlugin>) Class.forName("com.idlefish.flutterboost.FlutterBoostPlugin");
                plugin = (FlutterBoostPlugin) engine.getPlugins().get(pluginClass);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }
        return plugin;
    }

    public void setupActivityLifecycleCallback(Application application) {
        application.registerActivityLifecycleCallbacks(new BoostActivityLifecycle());
    }

    public Activity getTopActivity() {
        return topActivity;
    }

    class BoostActivityLifecycle implements Application.ActivityLifecycleCallbacks {

        @Override
        public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
            topActivity = activity;

        }

        @Override
        public void onActivityStarted(@NonNull Activity activity) {

        }

        @Override
        public void onActivityResumed(@NonNull Activity activity) {
            topActivity = activity;

        }

        @Override
        public void onActivityPaused(@NonNull Activity activity) {

        }

        @Override
        public void onActivityStopped(@NonNull Activity activity) {

        }

        @Override
        public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

        }

        @Override
        public void onActivityDestroyed(@NonNull Activity activity) {
        }
    }
}
