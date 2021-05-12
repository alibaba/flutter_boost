package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;

import com.idlefish.flutterboost.containers.FlutterContainerManager;
import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.view.FlutterMain;

public class FlutterBoost {
    public static final String ENGINE_ID = "flutter_boost_default_engine";

    private Activity topActivity = null;
    private FlutterBoostPlugin plugin;
    private boolean isAppInBackground = false;

    private FlutterBoost() {}
    private static class LazyHolder {
        static final FlutterBoost INSTANCE = new FlutterBoost();
    }

    public static FlutterBoost instance() {
        return LazyHolder.INSTANCE;
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
        setup(application, delegate, callback, FlutterBoostOptions.createDefault());
    }

    public void setup(Application application, FlutterBoostDelegate delegate, Callback callback, FlutterBoostOptions options) {
        // 1. initialize default engine
        FlutterEngine engine = getEngine();
        if (engine == null) {
            if (options == null) options = FlutterBoostOptions.createDefault();
            engine = new FlutterEngine(application, options.shellArgs());
            engine.getNavigationChannel().setInitialRoute(options.initialRoute());
            engine.getDartExecutor().executeDartEntrypoint(new DartExecutor.DartEntrypoint(
                    FlutterMain.findAppBundlePath(), options.dartEntrypoint()));
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
            FlutterEngine engine = getEngine();
            if (engine == null) {
                throw new RuntimeException("FlutterBoost might *not* have been initialized yet!!!");
            }
            plugin = FlutterBoostUtils.getPlugin(engine);
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
        return FlutterContainerManager.instance().findContainerById(uniqueId);
    }

    /**
     * Gets the topmost container
     * 
     * This is a legacy API for backwards compatibility.
     * 
     * @return the topmost container
     */
    public FlutterViewContainer getTopContainer() {
        return FlutterContainerManager.instance().getTopContainer();
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

    private void setupActivityLifecycleCallback(Application application) {
        application.registerActivityLifecycleCallbacks(new BoostActivityLifecycle());
    }

    public boolean isAppInBackground() {
        return isAppInBackground;
    }

    /*package*/ void setAppIsInBackground(boolean inBackground) {
        isAppInBackground = inBackground;
    }

    private class BoostActivityLifecycle implements Application.ActivityLifecycleCallbacks {
        private int activityReferences = 0;
        private boolean isActivityChangingConfigurations = false;
    
        private void dispatchForegroundEvent() {
            FlutterBoost.instance().setAppIsInBackground(false);
            FlutterBoost.instance().getPlugin().onForeground();
        }
    
        private void dispatchBackgroundEvent() {
            FlutterBoost.instance().setAppIsInBackground(true);
            FlutterBoost.instance().getPlugin().onBackground();
        }
    
        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            topActivity = activity;
        }
    
        @Override
        public void onActivityStarted(Activity activity) {
            if (++activityReferences == 1 && !isActivityChangingConfigurations) {
                // App enters foreground
                dispatchForegroundEvent();                
            }
        }
    
        @Override
        public void onActivityResumed(Activity activity) {
            topActivity = activity;
        }
    
        @Override
        public void onActivityPaused(Activity activity) {
        }
    
        @Override
        public void onActivityStopped(Activity activity) {
            isActivityChangingConfigurations = activity.isChangingConfigurations();
            if (--activityReferences == 0 && !isActivityChangingConfigurations) {
                // App enters background
                dispatchBackgroundEvent();
            }

        }
    
        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        }
    
        @Override
        public void onActivityDestroyed(Activity activity) {
        }
    }
}
