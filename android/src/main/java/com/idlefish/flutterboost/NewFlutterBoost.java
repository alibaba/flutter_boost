package com.idlefish.flutterboost;


import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import com.idlefish.flutterboost.interfaces.*;
import io.flutter.app.FlutterPluginRegistry;
import io.flutter.embedding.engine.FlutterEngine;

import java.util.HashMap;
import java.util.Map;

public class NewFlutterBoost {

    private Platform mPlatform;
    private FlutterViewContainerManager mManager;
    private IFlutterEngineProvider mEngineProvider;
    private Activity mCurrentActiveActivity;

    static NewFlutterBoost sInstance = null;


    public static NewFlutterBoost instance() {
        if (sInstance == null) {
            sInstance = new NewFlutterBoost();
        }
        return sInstance;
    }

    public void init(Platform platform) {


        mPlatform = platform;
        mManager = new FlutterViewContainerManager();
        mEngineProvider = platform.engineProvider();


        platform.getApplication().registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {

            @Override
            public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
                if (mPlatform.whenEngineStart() == IPlatform.ANY_ACTIVITY_CREATED) {

                }
            }

            @Override
            public void onActivityStarted(Activity activity) {
                if (mCurrentActiveActivity == null) {
                    Debuger.log("Application entry foreground");

                    if (NewFlutterBoost.instance().engineProvider().tryGetEngine() != null) {
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

                    if (mEngineProvider.tryGetEngine() != null) {
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

                    if (mEngineProvider.tryGetEngine() != null) {
                        HashMap<String, String> map = new HashMap<>();
                        map.put("type", "background");
                        channel().sendEvent("lifecycle", map);
                    }
                    mCurrentActiveActivity = null;
                }
            }
        });


        BoostPluginRegistry registry=new BoostPluginRegistry(this.engineProvider().provideEngine(mPlatform.getApplication()),
                mPlatform.getApplication());
        mPlatform.registerPlugins(registry);
    }


    public static class ConfigBuilder {

        protected static final String DEFAULT_DART_ENTRYPOINT = "main";
        protected static final String DEFAULT_INITIAL_ROUTE = "/";

        private String dartEntrypoint = DEFAULT_DART_ENTRYPOINT;
        private String initialRoute = DEFAULT_INITIAL_ROUTE;
        private boolean isDebug = false;
        private int whenEngineStart = 1;
        private Application mApp;

        private INativeRouter router = null;

        public ConfigBuilder(Application app, INativeRouter router) {
            this.router = router;
            this.mApp = app;
        }

        public ConfigBuilder dartEntrypoint(@NonNull String dartEntrypoint) {
            this.dartEntrypoint = dartEntrypoint;
            return this;
        }

        public ConfigBuilder isDebug(boolean isDebug) {
            this.isDebug = isDebug;
            return this;
        }

        public ConfigBuilder whenEngineStart(@NonNull int whenEngineStart) {
            this.whenEngineStart = whenEngineStart;
            return this;
        }

        public Platform build() {

            Platform platform = new Platform() {
                @Override
                public Application getApplication() {
                    return ConfigBuilder.this.mApp;
                }

                public boolean isDebug() {

                    return ConfigBuilder.this.isDebug;
                }

                @Override
                public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
                    router.openContainer(context, url, urlParams, requestCode, exts);
                }


                @Override
                public IFlutterEngineProvider engineProvider() {
                    return new BoostEngineProvider();
                }

                public int whenEngineStart() {
                    return ConfigBuilder.this.whenEngineStart;
                }
            };

            return platform;

        }

    }


    public IFlutterEngineProvider engineProvider() {
        return sInstance.mEngineProvider;
    }

    public IContainerManager containerManager() {
        return sInstance.mManager;
    }

    public IPlatform platform() {
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


}
