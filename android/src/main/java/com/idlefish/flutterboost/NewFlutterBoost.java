package com.idlefish.flutterboost;


import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import androidx.annotation.NonNull;
import com.idlefish.flutterboost.interfaces.*;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.view.FlutterMain;

import java.util.HashMap;
import java.util.Map;

public class NewFlutterBoost {

    private Platform mPlatform;

    private FlutterViewContainerManager mManager;

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

        if (mPlatform.whenEngineStart() == ConfigBuilder.IMMEDIATELY) {

            doInitialFlutterViewRun(mPlatform);
        }

        platform.getApplication().registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {

            @Override
            public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
                Log.e("bbbb1", "xxxxx");

                if (mPlatform.whenEngineStart() == ConfigBuilder.ANY_ACTIVITY_CREATED) {
                    Log.e("bbbb2", "xxxxx");

                    doInitialFlutterViewRun(mPlatform);
                }
            }

            @Override
            public void onActivityStarted(Activity activity) {
                if (mCurrentActiveActivity == null) {
                    Debuger.log("Application entry foreground");

                    if (NewFlutterBoost.instance().engineProvider() != null) {
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

                    if (mPlatform.engineProvider() != null) {
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

                    if (mPlatform.engineProvider() != null) {
                        HashMap<String, String> map = new HashMap<>();
                        map.put("type", "background");
                        channel().sendEvent("lifecycle", map);
                    }
                    mCurrentActiveActivity = null;
                }
            }
        });


        BoostPluginRegistry registry = new BoostPluginRegistry(this.engineProvider(),
                mPlatform.getApplication());
        mPlatform.registerPlugins(registry);


    }

    private void doInitialFlutterViewRun(Platform platform) {
        // Don't attempt to start a FlutterEngine if we're using a cached FlutterEngine.
//        if (host.getCachedEngineId() != null) {
//            return;
//        }
        FlutterEngine flutterEngine = platform.engineProvider();

        if (flutterEngine.getDartExecutor().isExecutingDart()) {
            // No warning is logged because this situation will happen on every config
            // change if the developer does not choose to retain the Fragment instance.
            // So this is expected behavior in many cases.
            return;
        }

        Log.e("bbbb3", "xxxxx");
        // The engine needs to receive the Flutter app's initial route before executing any
        // Dart code to ensure that the initial route arrives in time to be applied.
        if (platform.initialRoute() != null) {
            flutterEngine.getNavigationChannel().setInitialRoute(platform.initialRoute());
        }
        // Configure the Dart entrypoint and execute it.
        DartExecutor.DartEntrypoint entrypoint = new DartExecutor.DartEntrypoint(
                FlutterMain.findAppBundlePath(),
                "main"
        );
        flutterEngine.getDartExecutor().executeDartEntrypoint(entrypoint);
    }


    public static class ConfigBuilder {

        public static final String DEFAULT_DART_ENTRYPOINT = "main";
        public static final String DEFAULT_INITIAL_ROUTE = "/";
        public static int IMMEDIATELY = 0;          //立即启动引擎

        public static int ANY_ACTIVITY_CREATED = 1; //当有任何Activity创建时,启动引擎


        private String dartEntrypoint = DEFAULT_DART_ENTRYPOINT;
        private String initialRoute = DEFAULT_INITIAL_ROUTE;
        private int whenEngineStart = ANY_ACTIVITY_CREATED;


        private boolean isDebug = false;

        private FlutterView.RenderMode renderMode = FlutterView.RenderMode.surface;

        private Application mApp;

        private INativeRouter router = null;

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

        public ConfigBuilder whenEngineStart(@NonNull int whenEngineStart) {
            this.whenEngineStart = whenEngineStart;
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

                public FlutterView.RenderMode renderMode() {
                    return ConfigBuilder.this.renderMode;
                }
            };

            return platform;

        }

    }


    public FlutterEngine engineProvider() {
        return sInstance.mPlatform.engineProvider();
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


}
