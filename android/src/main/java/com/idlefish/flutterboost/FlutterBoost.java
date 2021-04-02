package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.view.FlutterMain;

public class FlutterBoost {
    private interface Constants {
        String ENGINE_ID = "flutter_boost_default_engine";
    }

    private Activity topActivity = null;

    private FlutterBoost() {}
    private static class LazyHolder {
        static final FlutterBoost INSTANCE = new FlutterBoost();
    }

    public static FlutterBoost getInstance() {
        return LazyHolder.INSTANCE;
    }

    /**
     * Gets the current activity.
     *
     * @return the current activity
     */
    public Activity currentActivity() {
        return topActivity;
    }

    public static String getDefaultEngineId() {
        return Constants.ENGINE_ID;
    }

    public interface Callback {
        void onStart(FlutterEngine engine);
    }

    public static DefaultEngineConfigs withDefaultEngine() {
        return new DefaultEngineConfigs();
    }

    public static class DefaultEngineConfigs {
        private String initialRoute = "/";
        private String dartEntrypointFunctionName = "main";

        public DefaultEngineConfigs() {
        }

        public DefaultEngineConfigs initialRoute(String initialRoute) {
            this.initialRoute = initialRoute;
            return this;
        }

        public DefaultEngineConfigs entrypoint(String dartEntrypointFunctionName) {
            this.dartEntrypointFunctionName = dartEntrypointFunctionName;
            return this;
        }

        /**
         * Initializes engine and plugin.
         *
         * @param application the application
         * @param delegate the FlutterBoostDelegate
         * @param callback Invoke the callback when the engine was started.
         */
        public void setup(Application application, FlutterBoostDelegate delegate, Callback callback) {
            // 1. initialize default engine, and places it in cache with default engineId.
            String defaultEngineId = FlutterBoost.getInstance().getDefaultEngineId();
            FlutterEngine engine = FlutterEngineCache.getInstance().get(defaultEngineId);
            if (engine == null) {
                engine = new FlutterEngine(application);
                engine.getNavigationChannel().setInitialRoute(this.initialRoute);
                engine.getDartExecutor().executeDartEntrypoint(new DartExecutor.DartEntrypoint(
                        FlutterMain.findAppBundlePath(), this.dartEntrypointFunctionName));
                if(callback != null) callback.onStart(engine);
                FlutterEngineCache.getInstance().put(defaultEngineId, engine);
            }

            // 2. set delegate
            FlutterBoostPlugin plugin = FlutterBoostUtils.getFlutterBoostPlugin(engine);
            if (plugin != null) {
                plugin.setDelegate(delegate);
            } else {
                throw new RuntimeException("The FlutterBoostPlugin cann't be found: " + defaultEngineId);
            }

            // 3. register ActivityLifecycleCallbacks
            FlutterBoost.getInstance().setupActivityLifecycleCallback(application);
        }
    }

    public static CachedEngineConfigs withCachedEngines() {
        return new CachedEngineConfigs();
    }

    public static class CachedEngineConfigs {
        private List<String> engineIds = new ArrayList<>();

        public CachedEngineConfigs() {
        }

        public CachedEngineConfigs add(String engineId) {
            this.engineIds.add(engineId);
            return this;
        }

        public void setup(Application application, FlutterBoostDelegate delegate, Callback callback) {
            for(String engineId : engineIds) {
                FlutterEngine engine = FlutterEngineCache.getInstance().get(engineId);
                if (engine == null) {
                    throw new RuntimeException("No such engine exists in FlutterEngineCache: " + engineId);
                }

                FlutterBoostPlugin plugin = FlutterBoostUtils.getFlutterBoostPlugin(engine);
                if (plugin != null) {
                    plugin.setDelegate(delegate);
                } else {
                    throw new RuntimeException("The FlutterBoostPlugin cann't be found: " + engineId);
                }
            }
            FlutterBoost.getInstance().setupActivityLifecycleCallback(application);
        }
    }

    private List<FlutterBoostPlugin> visibilityChangedObservers = new ArrayList<>();
    private ActivityLifecycleCallbacksImp lifecycleCallbacks = new ActivityLifecycleCallbacksImp();
    private void setupActivityLifecycleCallback(Application application) {
        application.unregisterActivityLifecycleCallbacks(lifecycleCallbacks);
        application.registerActivityLifecycleCallbacks(lifecycleCallbacks);
    }

    public void unregisterVisibilityChangedObserver(FlutterBoostPlugin observer) {
        if (observer != null) {
            visibilityChangedObservers.remove(observer);
        }
    }

    public void registerVisibilityChangedObserver(FlutterBoostPlugin observer) {
        if (observer != null) {
            visibilityChangedObservers.add(observer);
        }
    }

    private void dispatchForegroundEvent() {
        for (FlutterBoostPlugin observer : visibilityChangedObservers) {
            observer.onForeground();
        }
    }

    private void dispatchBackgroundEvent() {
        for (FlutterBoostPlugin observer : visibilityChangedObservers) {
            observer.onBackground();
        }
    }

    class ActivityLifecycleCallbacksImp implements Application.ActivityLifecycleCallbacks {
        private Activity currentActiveActivity;
        private boolean alreadyCreated = false;

        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            topActivity = activity;
            // fix bug : The LauncherActivity will be launch by clicking app icon 
            // when app enter background in HuaWei Rom, cause missing forgoround event
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