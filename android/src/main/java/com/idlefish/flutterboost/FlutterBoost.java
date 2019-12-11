package com.idlefish.flutterboost;


import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import com.idlefish.flutterboost.interfaces.*;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterMain;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class FlutterBoost {

    private Platform mPlatform;

    private FlutterViewContainerManager mManager;
    private FlutterEngine mEngine;
    private Activity mCurrentActiveActivity;
    private PluginRegistry mRegistry;
    static FlutterBoost sInstance = null;

    private long FlutterPostFrameCallTime = 0;
    private Application.ActivityLifecycleCallbacks mActivityLifecycleCallbacks;

    public long getFlutterPostFrameCallTime() {
        return FlutterPostFrameCallTime;
    }

    public void setFlutterPostFrameCallTime(long FlutterPostFrameCallTime) {
        this.FlutterPostFrameCallTime = FlutterPostFrameCallTime;
    }

    public static FlutterBoost instance() {
        if (sInstance == null) {
            sInstance = new FlutterBoost();
        }
        return sInstance;
    }

    public void init(Platform platform) {


        mPlatform = platform;
        mManager = new FlutterViewContainerManager();

        mActivityLifecycleCallbacks = new Application.ActivityLifecycleCallbacks() {

            @Override
            public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
                mCurrentActiveActivity = activity;
                if (mPlatform.whenEngineStart() == ConfigBuilder.ANY_ACTIVITY_CREATED) {
                    doInitialFlutter();
                    boostPluginRegistry();
                }
                if (mPlatform.whenEngineStart() == ConfigBuilder.IMMEDIATELY) {
                    boostPluginRegistry();

                }

            }

            @Override
            public void onActivityStarted(Activity activity) {
                if (mCurrentActiveActivity == null) {
                    Debuger.log("Application entry foreground");

                    if (createEngine() != null) {
                        HashMap<String, String> map = new HashMap<>();
                        map.put("type", "foreground");
                        channel().sendEvent("lifecycle", map);
                    }
                }
                mCurrentActiveActivity = activity;
            }

            @Override
            public void onActivityResumed(Activity activity) {
                mCurrentActiveActivity = activity;
            }

            @Override
            public void onActivityPaused(Activity activity) {

            }

            @Override
            public void onActivityStopped(Activity activity) {
                if (mCurrentActiveActivity == activity) {
                    Debuger.log("Application entry background");

                    if (createEngine() != null) {
                        HashMap<String, String> map = new HashMap<>();
                        map.put("type", "background");
                        channel().sendEvent("lifecycle", map);
                    }
                    mCurrentActiveActivity = null;
                }
            }

            @Override
            public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

            }

            @Override
            public void onActivityDestroyed(Activity activity) {
                if (mCurrentActiveActivity == activity) {
                    Debuger.log("Application entry background");

                    if (createEngine() != null) {
                        HashMap<String, String> map = new HashMap<>();
                        map.put("type", "background");
                        channel().sendEvent("lifecycle", map);
                    }
                    mCurrentActiveActivity = null;
                }
            }
        };
        platform.getApplication().registerActivityLifecycleCallbacks(mActivityLifecycleCallbacks);

        if (mPlatform.whenEngineStart() == ConfigBuilder.IMMEDIATELY) {

            doInitialFlutter();
        }


    }

    public void doInitialFlutter() {


        if (mEngine != null) return;

        FlutterEngine flutterEngine = createEngine();
        if (mPlatform.lifecycleListener != null) {
            mPlatform.lifecycleListener.onEngineCreated();
        }
        if (flutterEngine.getDartExecutor().isExecutingDart()) {
            return;
        }

        if (mPlatform.initialRoute() != null) {
            flutterEngine.getNavigationChannel().setInitialRoute(mPlatform.initialRoute());
        }
        DartExecutor.DartEntrypoint entrypoint = new DartExecutor.DartEntrypoint(
                FlutterMain.findAppBundlePath(),
                "main"
        );

        flutterEngine.getDartExecutor().executeDartEntrypoint(entrypoint);
        mRegistry = new BoostPluginRegistry(createEngine());

    }

    public void boostPluginRegistry(){
        if(mRegistry!=null&& !mRegistry.hasPlugin("boostPluginRegistry")){
            mPlatform.registerPlugins(mRegistry);
            mRegistry.registrarFor("boostPluginRegistry");
        }

    }

    public static class ConfigBuilder {

        public static final String DEFAULT_DART_ENTRYPOINT = "main";
        public static final String DEFAULT_INITIAL_ROUTE = "/";
        public static int IMMEDIATELY = 0;          //立即启动引擎

        public static int ANY_ACTIVITY_CREATED = 1; //当有任何Activity创建时,启动引擎

        public static int FLUTTER_ACTIVITY_CREATED = 2; //当有flutterActivity创建时,启动引擎


        public static int APP_EXit = 0; //所有flutter Activity destory 时，销毁engine
        public static int All_FLUTTER_ACTIVITY_DESTROY = 1; //所有flutter Activity destory 时，销毁engine

        private String dartEntrypoint = DEFAULT_DART_ENTRYPOINT;
        private String initialRoute = DEFAULT_INITIAL_ROUTE;
        private int whenEngineStart = ANY_ACTIVITY_CREATED;
        private int whenEngineDestory = APP_EXit;


        private boolean isDebug = false;

        private FlutterView.RenderMode renderMode = FlutterView.RenderMode.texture;

        private Application mApp;

        private INativeRouter router = null;

        private BoostLifecycleListener lifecycleListener;

        private BoostPluginsRegister boostPluginsRegister;



        public ConfigBuilder(Application app, INativeRouter router) {
            this.router = router;
            this.mApp = app;
        }

        public ConfigBuilder renderMode(FlutterView.RenderMode renderMode) {
            this.renderMode = renderMode;
            return this;
        }

        public ConfigBuilder dartEntrypoint(@NonNull String dartEntrypoint) {
            this.dartEntrypoint = dartEntrypoint;
            return this;
        }

        public ConfigBuilder initialRoute(@NonNull String initialRoute) {
            this.initialRoute = initialRoute;
            return this;
        }

        public ConfigBuilder isDebug(boolean isDebug) {
            this.isDebug = isDebug;
            return this;
        }

        public ConfigBuilder whenEngineStart(int whenEngineStart) {
            this.whenEngineStart = whenEngineStart;
            return this;
        }

        public ConfigBuilder whenEngineDestory(int whenEngineDestory) {
            this.whenEngineDestory = whenEngineDestory;
            return this;
        }

        public ConfigBuilder lifecycleListener(BoostLifecycleListener lifecycleListener) {
            this.lifecycleListener = lifecycleListener;
            return this;
        }
        public ConfigBuilder pluginsRegister(BoostPluginsRegister boostPluginsRegister) {
            this.boostPluginsRegister = boostPluginsRegister;
            return this;
        }
        public Platform build() {

            Platform platform = new Platform() {

                public Application getApplication() {
                    return ConfigBuilder.this.mApp;
                }

                public boolean isDebug() {

                    return ConfigBuilder.this.isDebug;
                }

                @Override
                public String initialRoute() {
                    return ConfigBuilder.this.initialRoute;
                }

                public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
                    router.openContainer(context, url, urlParams, requestCode, exts);
                }


                public int whenEngineStart() {
                    return ConfigBuilder.this.whenEngineStart;
                }

                @Override
                public int whenEngineDestroy() {
                    return ConfigBuilder.this.whenEngineDestory;
                }

                public FlutterView.RenderMode renderMode() {
                    return ConfigBuilder.this.renderMode;
                }
            };

            platform.lifecycleListener = this.lifecycleListener;
            platform.pluginsRegister=this.boostPluginsRegister;
            return platform;

        }

    }

    public IContainerManager containerManager() {
        return sInstance.mManager;
    }

    public Platform platform() {
        return sInstance.mPlatform;
    }

    public FlutterBoostPlugin channel() {
        return FlutterBoostPlugin.singleton();
    }

    public Activity currentActivity() {
        return sInstance.mCurrentActiveActivity;
    }

    public IFlutterViewContainer findContainerById(String id) {
        return mManager.findContainerById(id);
    }

    public PluginRegistry getPluginRegistry() {
        return mRegistry;
    }

    private FlutterEngine createEngine() {
        if (mEngine == null) {

            FlutterMain.startInitialization(mPlatform.getApplication());

            FlutterShellArgs flutterShellArgs = new FlutterShellArgs(new String[0]);
            FlutterMain.ensureInitializationComplete(
                    mPlatform.getApplication().getApplicationContext(), flutterShellArgs.toArray());

            mEngine = new FlutterEngine(mPlatform.getApplication().getApplicationContext());
        }
        return mEngine;

    }

    public FlutterEngine engineProvider() {
        return mEngine;
    }


    public void boostDestroy() {
        mPlatform.getApplication().unregisterActivityLifecycleCallbacks(mActivityLifecycleCallbacks);
        if (mEngine != null) {
            mEngine.destroy();
        }
        if (mPlatform.lifecycleListener != null) {
            mPlatform.lifecycleListener.onEngineDestroy();
        }
        mEngine = null;
        mRegistry = null;
        mCurrentActiveActivity = null;
    }


    public interface BoostLifecycleListener {
        void onEngineCreated();

        void onPluginsRegistered();

        void onEngineDestroy();
    }


    public interface BoostPluginsRegister {

        void registerPlugins(PluginRegistry mRegistry);
    }

}
