package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.view.FlutterMain;

public class FlutterBoost {

    public final static String ENGINE_ID = "flutter_boost_default_engine";

    private static FlutterBoost sInstance = null;

    private Activity mTopActivity = null;

    private FlutterBoostPlugin mPlugin;

    public static FlutterBoost instance() {
        if (sInstance == null) {
            sInstance = new FlutterBoost();
        }
        return sInstance;
    }

    public static String generateUniqueId(String pageName) {
        return System.currentTimeMillis() + "_" + pageName;
    }

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

    public static DefaultEngineConfig withDefaultEngine() {
        return new DefaultEngineConfig();
    }

    public static class DefaultEngineConfig {
        private String mInitialRoute = "/";
        private String mDartEntrypointFunctionName = "main";

        public DefaultEngineConfig() {
        }

        @NonNull
        public DefaultEngineConfig initialRoute(@NonNull String initialRoute) {
            mInitialRoute = initialRoute;
            return this;
        }

        @NonNull
        public DefaultEngineConfig entrypoint(@NonNull String dartEntrypointFunctionName) {
            mDartEntrypointFunctionName = dartEntrypointFunctionName;
            return this;
        }

        public void init(Application application, FlutterBoostDelegate delegate) {
            // 1. initialize default engine
            FlutterEngine engine = FlutterEngineCache.getInstance().get(ENGINE_ID);
            if (engine == null) {
                engine = new FlutterEngine(application);
                engine.getNavigationChannel().setInitialRoute(mInitialRoute);
                engine.getDartExecutor().executeDartEntrypoint(new DartExecutor.DartEntrypoint(
                        FlutterMain.findAppBundlePath(), mDartEntrypointFunctionName));
                FlutterEngineCache.getInstance().put(ENGINE_ID, engine);
            }

            // 2. set delegate
            FlutterBoost.instance().getPlugin().setDelegate(delegate);

            //3. register ActivityLifecycleCallbacks
            FlutterBoost.instance().setupActivityLifecycleCallback(application);

        }
    }

    public FlutterBoostPlugin getPlugin() {
        if (mPlugin == null) {
            FlutterEngine engine = FlutterEngineCache.getInstance().get(ENGINE_ID);
            if (engine == null) {
                throw new RuntimeException("FlutterBoost might *not* have been initialized yet!!!");
            }
            mPlugin = getFlutterBoostPlugin(engine);
        }
        return mPlugin;
    }

    public void setupActivityLifecycleCallback(Application application) {
        application.registerActivityLifecycleCallbacks(new BoostActivityLifecycle());
    }

    /**
     * 提供给业务 最上层的activity。
     * @return
     */
    public Activity getTopActivity() {
        return mTopActivity;
    }

    /**
     * 根据unqueid，返回容器
     * 兼容老版本
     * @param uniqueId
     * @return
     */
    public FlutterViewContainer findFlutterViewContainerById(String uniqueId) {
        return getPlugin().findContainerById(uniqueId);
    }

    /**
     * 根据unqueid，返回容器
     * 兼容老版本
     * @return
     */
    public FlutterViewContainer getTopFlutterViewContainer() {
        return getPlugin().getTopContainer();
    }

    private List<FlutterBoostPlugin> mVisibilityChangedObservers = new ArrayList<>();
    public void unregisterVisibilityChangedObserver(FlutterBoostPlugin observer) {
        if (observer != null) {
            mVisibilityChangedObservers.remove(observer);
        }
    }

    public void registerVisibilityChangedObserver(FlutterBoostPlugin observer) {
        if (observer != null) {
            mVisibilityChangedObservers.add(observer);
        }
    }

    private void callForeground() {
        for (FlutterBoostPlugin observer : mVisibilityChangedObservers) {
            observer.onForeground();
        }
    }

    private void callBackground() {
        for (FlutterBoostPlugin observer : mVisibilityChangedObservers) {
            observer.onBackground();
        }
    }

    class BoostActivityLifecycle implements Application.ActivityLifecycleCallbacks {
        private Activity mCurrentActiveActivity;
        private boolean mEnterActivityCreate = false;

        @Override
        public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
            mTopActivity = activity;
            // fix bug : The LauncherActivity will be launch by clicking app icon when app
            // enter background in HuaWei Rom, cause missing foreground event
            if (mEnterActivityCreate && mCurrentActiveActivity == null) {
                Intent intent = activity.getIntent();
                if (!activity.isTaskRoot()
                        && intent != null
                        && intent.hasCategory(Intent.CATEGORY_LAUNCHER)
                        && intent.getAction() != null
                        && intent.getAction().equals(Intent.ACTION_MAIN)) {
                    return;
                }
            }
            mEnterActivityCreate = true;
            mCurrentActiveActivity = activity;
        }

        @Override
        public void onActivityStarted(@NonNull Activity activity) {
            if (!mEnterActivityCreate) {
                return;
            }
            if (mCurrentActiveActivity == null) {
                callForeground();
            }
            mCurrentActiveActivity = activity;
        }

        @Override
        public void onActivityResumed(@NonNull Activity activity) {
            mTopActivity = activity;
            if (!mEnterActivityCreate) {
                return;
            }
            mCurrentActiveActivity = activity;
        }

        @Override
        public void onActivityPaused(@NonNull Activity activity) {
        }

        @Override
        public void onActivityStopped(@NonNull Activity activity) {
            if (!mEnterActivityCreate) {
                return;
            }
            if (mCurrentActiveActivity == activity) {
                callBackground();
                mCurrentActiveActivity = null;
            }
        }

        @Override
        public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {
        }

        @Override
        public void onActivityDestroyed(@NonNull Activity activity) {
            if (!mEnterActivityCreate) {
                return;
            }
            if (mCurrentActiveActivity == activity) {
                callBackground();
                mCurrentActiveActivity = null;
            }
        }
    }
}
