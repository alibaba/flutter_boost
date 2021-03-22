package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.view.FlutterMain;

public class FlutterBoost {
    public static final String ENGINE_ID = "flutter_boost_default_engine";
    private static final String defaultInitialRoute = "/";
    private static final String defaultDartEntrypointFunctionName = "main";
    private static FlutterBoost sInstance = null;
    private Activity topActivity = null;
    private FlutterBoostPlugin plugin;

    public static FlutterBoost instance() {
        if (sInstance == null) {
            sInstance = new FlutterBoost();
        }
        return sInstance;
    }

    public interface Callback {
        void onStart(FlutterEngine engine);
    }

    /**
     * Initializes engine and plugin.
     * 
     * @param application the application
     * @param delegate the FlutterBoostDelegate
     * @param callback Invoke the callback when the engine was started.
     */
    public void setup(Application application, FlutterBoostDelegate delegate, Callback callback) {
        // 1. initialize default engine
        FlutterEngine engine = FlutterEngineCache.getInstance().get(ENGINE_ID);
        if (engine == null) {
            engine = new FlutterEngine(application);
            engine.getNavigationChannel().setInitialRoute(defaultInitialRoute);
            engine.getDartExecutor().executeDartEntrypoint(new DartExecutor.DartEntrypoint(
                    FlutterMain.findAppBundlePath(), defaultDartEntrypointFunctionName));
            if(callback != null) callback.onStart(engine);
            FlutterEngineCache.getInstance().put(ENGINE_ID, engine);
        }

        // 2. set delegate
        getPlugin().setDelegate(delegate);

        //3. register ActivityLifecycleCallbacks
        setupActivityLifecycleCallback(application);
    }

    /**
     * Gets the FlutterBoostPlugin.
     *
     * @return the FlutterBoostPlugin.
     */
    public FlutterBoostPlugin getPlugin() {
        if (plugin == null) {
            FlutterEngine engine = FlutterEngineCache.getInstance().get(ENGINE_ID);
            if (engine == null) {
                throw new RuntimeException("FlutterBoost might *not* have been initialized yet!!!");
            }
            plugin = getFlutterBoostPlugin(engine);
        }
        return plugin;
    }
    
    /**
     * Gets the FlutterEngine in use.
     *
     * @return the FlutterEngine
     */
    public FlutterEngine getEngine() {
        return FlutterEngineCache.getInstance().get(ENGINE_ID);
    }

    /**
     * Gets the current activity.
     *
     * @return the current activity
     */
    public Activity currentActivity() {
        return topActivity;
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
        return getPlugin().findContainerById(uniqueId);
    }

    /**
     * Gets the topmost container
     * 
     * This is a legacy API for backwards compatibility.
     * 
     * @return the topmost container
     */
    public FlutterViewContainer getTopContainer() {
        return getPlugin().getTopContainer();
    }

    /**
     * Open a Flutter page with name and arguments.
     * 
     * @param name The Flutter route name.
     * @param arguments The bussiness arguments.
     */
    public void open(String name, Map<String, Object> arguments) {
        this.getPlugin().getDelegate().pushFlutterRoute(name, null, arguments);
    }

    /**
     * Close the Flutter page with uniqueId.
     * 
     * @param uniqueId The uniqueId of the Flutter page
     */
    public void close(String uniqueId) {
        Messages.CommonParams params= new Messages.CommonParams();
        params.setUniqueId(uniqueId);
        this.getPlugin().popRoute(params);
    }

    private FlutterBoostPlugin getFlutterBoostPlugin(FlutterEngine engine) {
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

    private void setupActivityLifecycleCallback(Application application) {
        application.registerActivityLifecycleCallbacks(new BoostActivityLifecycle());
    }

    private class BoostActivityLifecycle implements Application.ActivityLifecycleCallbacks {
        private Activity currentActiveActivity;
        private boolean alreadyCreated = false;
    
        private void dispatchForegroundEvent() {
            FlutterBoost.instance().getPlugin().onForeground();
        }
    
        private void dispatchBackgroundEvent() {
            FlutterBoost.instance().getPlugin().onBackground();
        }
    
        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            topActivity = activity;

            // fix bug : The LauncherActivity will be launch by clicking app icon when app
            // enter background in HuaWei Rom, cause missing foreground event
            if (alreadyCreated && currentActiveActivity == null) {
                Intent intent = activity.getIntent();
                if (!activity.isTaskRoot()
                        && intent != null
                        && intent.hasCategory(Intent.CATEGORY_LAUNCHER)
                        && intent.getAction() != null
                        && intent.getAction().equals(Intent.ACTION_MAIN)) {
                    return;
                }
            }
            alreadyCreated = true;
            currentActiveActivity = activity;
        }
    
        @Override
        public void onActivityStarted(Activity activity) {
            if (!alreadyCreated) {
                return;
            }
            if (currentActiveActivity == null) {
                dispatchForegroundEvent();
            }
            currentActiveActivity = activity;
        }
    
        @Override
        public void onActivityResumed(Activity activity) {
            topActivity = activity;

            if (!alreadyCreated) {
                return;
            }
            currentActiveActivity = activity;
        }
    
        @Override
        public void onActivityPaused(Activity activity) {
        }
    
        @Override
        public void onActivityStopped(Activity activity) {
            if (!alreadyCreated) {
                return;
            }
            if (currentActiveActivity == activity) {
                dispatchBackgroundEvent();
                currentActiveActivity = null;
            }
        }
    
        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        }
    
        @Override
        public void onActivityDestroyed(Activity activity) {
            if (!alreadyCreated) {
                return;
            }
            if (currentActiveActivity == activity) {
                dispatchBackgroundEvent();
                currentActiveActivity = null;
            }
        }
    }
}
