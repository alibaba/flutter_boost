package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import com.idlefish.flutterboost.containers.FlutterContainerManager;
import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterEngineProvider;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.view.FlutterMain;

public class FlutterBoost {
    public static final String ENGINE_ID = "flutter_boost_default_engine";
    public static final String APP_LIFECYCLE_CHANGED_KEY = "app_lifecycle_changed_key";
    public static final String LIFECYCLE_STATE = "lifecycleState";
    public static final int FLUTTER_APP_STATE_RESUMED = 0;
    public static final int FLUTTER_APP_STATE_PAUSED = 2;

    private Activity topActivity = null;
    private FlutterBoostPlugin plugin;
    private boolean isBackForegroundEventOverridden = false;
    private boolean isAppInBackground = false;


    private FlutterBoost() {
    }

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
     * @param delegate    the FlutterBoostDelegate
     * @param callback    Invoke the callback when the engine was started.
     */
    public void setup(Application application, FlutterBoostDelegate delegate, Callback callback) {
        setup(application, delegate, callback, FlutterBoostSetupOptions.createDefault());
    }

    public void setup(Application application, FlutterBoostDelegate delegate, Callback callback, FlutterBoostSetupOptions options) {
        if (options == null) {
            options = FlutterBoostSetupOptions.createDefault();
        }
        isBackForegroundEventOverridden = options.shouldOverrideBackForegroundEvent();

        // 1. initialize default engine
        FlutterEngine engine = getEngine();
        if (engine == null) {
            // First, get engine from option.flutterEngineProvider
            if (options.flutterEngineProvider() != null) {
                FlutterEngineProvider provider = options.flutterEngineProvider();
                engine = provider.provideFlutterEngine(application);
            }

            if (engine == null) {
                // Second, when the engine from option.flutterEngineProvider is null,
                // we should create a new engine
                engine = new FlutterEngine(application, options.shellArgs());
            }

            // Cache the created FlutterEngine in the FlutterEngineCache.
            FlutterEngineCache.getInstance().put(ENGINE_ID, engine);
        }

        if (!engine.getDartExecutor().isExecutingDart()) {
            // Pre-warm the cached FlutterEngine.
            engine.getNavigationChannel().setInitialRoute(options.initialRoute());
            engine.getDartExecutor().executeDartEntrypoint(new DartExecutor.DartEntrypoint(
                    FlutterMain.findAppBundlePath(), options.dartEntrypoint()));
        }
        if (callback != null) callback.onStart(engine);

        // 2. set delegate
        getPlugin().setDelegate(delegate);

        //3. register ActivityLifecycleCallbacks
        setupActivityLifecycleCallback(application, isBackForegroundEventOverridden);
    }

    /**
     *  Releases the engine resource.
     */
    public void tearDown() {
        FlutterEngine engine = getEngine();
        if (engine != null) {
            engine.destroy();
            FlutterEngineCache.getInstance().remove(ENGINE_ID);
        }
        topActivity = null;
        plugin = null;
        isBackForegroundEventOverridden = false;
        isAppInBackground = false;
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
     * Informs FlutterBoost of the back/foreground state.
     *
     * @param background a boolean indicating if the app goes to background
     *                   or foreground.
     */
    public void dispatchBackForegroundEvent(boolean background) {
        if (!isBackForegroundEventOverridden) {
            throw new RuntimeException("Oops! You should set override enable first by FlutterBoostSetupOptions.");
        }

        if (background) {
            getPlugin().onBackground();
        } else {
            getPlugin().onForeground();
        }
        setAppIsInBackground(background);
    }

    /**
     * Gets the FlutterView container with uniqueId.
     * <p>
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
     * <p>
     * This is a legacy API for backwards compatibility.
     *
     * @return the topmost container
     */
    public FlutterViewContainer getTopContainer() {
        return FlutterContainerManager.instance().getTopContainer();
    }

    /**
     * @param name      The Flutter route name.
     * @param arguments The bussiness arguments.
     * @deprecated use open(FlutterBoostRouteOptions options) instead
     * Open a Flutter page with name and arguments.
     */
    public void open(String name, Map<String, Object> arguments) {
        FlutterBoostRouteOptions options = new FlutterBoostRouteOptions.Builder()
                .pageName(name)
                .arguments(arguments)
                .build();
        this.getPlugin().getDelegate().pushFlutterRoute(options);
    }

    /**
     * Use FlutterBoostRouteOptions to open a new Page
     *
     * @param options FlutterBoostRouteOptions object
     */
    public void open(FlutterBoostRouteOptions options) {
        this.getPlugin().getDelegate().pushFlutterRoute(options);
    }

    /**
     * Close the Flutter page with uniqueId.
     *
     * @param uniqueId The uniqueId of the Flutter page
     */
    public void close(String uniqueId) {
        Messages.CommonParams params = new Messages.CommonParams();
        params.setUniqueId(uniqueId);
        this.getPlugin().popRoute(params,new Messages.Result<Void>(){
            @Override
            public void success(Void result) {

            }
        });
    }

    /**
     * Add a event listener
     *
     * @param listener
     * @return ListenerRemover, you can use this to remove this listener
     */
    public ListenerRemover addEventListener(String key, EventListener listener) {
        return this.plugin.addEventListener(key, listener);
    }

    /**
     * Send the event to flutter
     *
     * @param key  the key of this event
     * @param args the arguments of this event
     */
    public void sendEventToFlutter(String key, Map<Object, Object> args) {
        Messages.CommonParams params = new Messages.CommonParams();
        params.setKey(key);
        params.setArguments(args);
        this.getPlugin().getChannel().sendEventToFlutter(params, reply -> {

        });
    }

    private void setupActivityLifecycleCallback(Application application, boolean isBackForegroundEventOverridden) {
        application.registerActivityLifecycleCallbacks(new BoostActivityLifecycle(isBackForegroundEventOverridden));
    }

    public boolean isAppInBackground() {
        return isAppInBackground;
    }

    /*package*/ void setAppIsInBackground(boolean inBackground) {
        isAppInBackground = inBackground;
    }

    public void changeFlutterAppLifecycle(int state) {
        assert (state == FLUTTER_APP_STATE_PAUSED || state == FLUTTER_APP_STATE_RESUMED);
        Map arguments = new HashMap();
        arguments.put(LIFECYCLE_STATE, state);
        sendEventToFlutter(APP_LIFECYCLE_CHANGED_KEY, arguments);
    }

    private class BoostActivityLifecycle implements Application.ActivityLifecycleCallbacks {
        private int activityReferences = 0;
        private boolean isActivityChangingConfigurations = false;
        private boolean isBackForegroundEventOverridden = false;

        public BoostActivityLifecycle(boolean isBackForegroundEventOverridden) {
            this.isBackForegroundEventOverridden = isBackForegroundEventOverridden;
        }

        private void dispatchForegroundEvent() {
            if (isBackForegroundEventOverridden) {
                return;
            }

            FlutterBoost.instance().setAppIsInBackground(false);
            FlutterBoost.instance().getPlugin().onForeground();
        }

        private void dispatchBackgroundEvent() {
            if (isBackForegroundEventOverridden) {
                return;
            }

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
            if (topActivity == activity) {
                topActivity = null;
            }
        }
    }
}
