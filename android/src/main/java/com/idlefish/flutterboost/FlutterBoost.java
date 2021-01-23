package com.idlefish.flutterboost;


import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;

import androidx.annotation.NonNull;

import com.idlefish.flutterboost.interfaces.*;

import io.flutter.embedding.android.FlutterEngineProvider;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterJNI;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterMain;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FlutterBoost {
    private Platform mPlatform;

    private FlutterViewContainerManager mManager;
    private FlutterEngine mEngine;
    private Activity mCurrentActiveActivity;
    private boolean mEnterActivityCreate =false;
    static FlutterBoost sInstance = null;
    private static boolean sInit;

    private long FlutterPostFrameCallTime = 0;
    private Application.ActivityLifecycleCallbacks mActivityLifecycleCallbacks;
    private PluginRegistry mRegistry;

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
        if (sInit){
            Debuger.log("FlutterBoost is alread inited. Do not init twice");
            return;
        }

        mPlatform = platform;
        mManager = new FlutterViewContainerManager();

        mActivityLifecycleCallbacks = new Application.ActivityLifecycleCallbacks() {

            @Override
            public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
                //fix crash：'FlutterBoostPlugin not register yet'
                //case: initFlutter after Activity.OnCreate method，and then called start/stop crash
                // In SplashActivity ,showDialog(in OnCreate method) to check permission, if authorized, then init sdk and jump homePage)
                mEnterActivityCreate = true;
                mCurrentActiveActivity = activity;
                if (mPlatform.whenEngineStart() == ConfigBuilder.ANY_ACTIVITY_CREATED) {
                    doInitialFlutter();
                }
            }

            @Override
            public void onActivityStarted(Activity activity) {
                if (!mEnterActivityCreate){
                    return;
                }
                if (mCurrentActiveActivity == null) {
                    Debuger.log("Application entry foreground");

                    if (mEngine != null) {
                        HashMap<String, String> map = new HashMap<>();
                        map.put("type", "foreground");
                        channel().sendEvent("lifecycle", map);
                    }
                }
                mCurrentActiveActivity = activity;
            }

            @Override
            public void onActivityResumed(Activity activity) {
                if (!mEnterActivityCreate){
                    return;
                }
                mCurrentActiveActivity = activity;
            }

            @Override
            public void onActivityPaused(Activity activity) {
                if (!mEnterActivityCreate){
                    return;
                }
            }

            @Override
            public void onActivityStopped(Activity activity) {
                if (!mEnterActivityCreate){
                    return;
                }
                if (mCurrentActiveActivity == activity) {
                    Debuger.log("Application entry background");

                    if (mEngine != null) {
                        HashMap<String, String> map = new HashMap<>();
                        map.put("type", "background");
                        channel().sendEvent("lifecycle", map);
                    }
                    mCurrentActiveActivity = null;
                }
            }

            @Override
            public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
                if (!mEnterActivityCreate){
                    return;
                }
            }

            @Override
            public void onActivityDestroyed(Activity activity) {
                if (!mEnterActivityCreate){
                    return;
                }
                if (mCurrentActiveActivity == activity) {
                    Debuger.log("Application entry background");

                    if (mEngine != null) {
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
        sInit = true;

    }

    public void doInitialFlutter() {
        if (mEngine != null) {
            return;
        }

        if (mPlatform.lifecycleListener != null) {
            mPlatform.lifecycleListener.beforeCreateEngine();
        }
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
                mPlatform.dartEntrypoint()
        );

        flutterEngine.getDartExecutor().executeDartEntrypoint(entrypoint);
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

        private List<String> shellArgs;

        private BoostLifecycleListener lifecycleListener;

        private FlutterEngineProvider flutterEngineProvider = null;




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

        public ConfigBuilder lifecycleListener(BoostLifecycleListener lifecycleListener) {
            this.lifecycleListener = lifecycleListener;
            return this;
        }

        public ConfigBuilder flutterEngineProvider(FlutterEngineProvider flutterEngineProvider) {
            this.flutterEngineProvider = flutterEngineProvider;
            return this;
        }

        public ConfigBuilder shellArgs(List<String> shellArgs) {
            this.shellArgs = shellArgs;
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
                public String dartEntrypoint() { return ConfigBuilder.this.dartEntrypoint; }

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

                public List<String> shellArgs() {
                    return ConfigBuilder.this.shellArgs;
                }

                public  FlutterEngineProvider flutterEngineProvider() {
                    return flutterEngineProvider;
                }
            };

            platform.lifecycleListener = this.lifecycleListener;
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


    private FlutterEngine createEngine() {
        if (mEngine == null) {
            FlutterMain.startInitialization(mPlatform.getApplication());

            FlutterShellArgs flutterShellArgs = new FlutterShellArgs(mPlatform.shellArgs() != null ? mPlatform.shellArgs() : Arrays.asList(new String[0]));
            FlutterMain.ensureInitializationComplete(
                    mPlatform.getApplication().getApplicationContext(), flutterShellArgs.toArray());
            if (mPlatform.flutterEngineProvider() != null) {
                mEngine = mPlatform.flutterEngineProvider().provideFlutterEngine(mPlatform.getApplication().getApplicationContext());
            }

            if (mEngine == null) {
                mEngine = new FlutterEngine(mPlatform.getApplication().getApplicationContext(),FlutterLoader.getInstance(),new FlutterJNI(),null,false);
            }

//            registerPlugins(mEngine);

            if (mPlatform.whenEngineStart() == ConfigBuilder.FLUTTER_ACTIVITY_CREATED) {
                // 如果是启动FlutterActivity时，在启动页面时注册插件
            } else {
                registerPlugins(mEngine);
            }

          //  mRegistry = new BoostPluginRegistry(createEngine());
          //  mPlatform.registerPlugins(mRegistry);
        }
        return mEngine;

    }

    public void registerPlugins(FlutterEngine engine) {
        try {
            Class<?> generatedPluginRegistrant = Class.forName("io.flutter.plugins.GeneratedPluginRegistrant");
            Method registrationMethod = generatedPluginRegistrant.getDeclaredMethod("registerWith", FlutterEngine.class);
            registrationMethod.invoke(null, engine);
        } catch (Exception e) {
            Debuger.exception(e);
        }
    }

    public FlutterEngine engineProvider() {
        return mEngine;
    }


    public void boostDestroy() {
        if (mEngine != null) {
            mEngine.destroy();
        }
        if (mPlatform.lifecycleListener != null) {
            mPlatform.lifecycleListener.onEngineDestroy();
        }
        mEngine = null;
        mCurrentActiveActivity = null;
    }


    public interface BoostLifecycleListener {

        void beforeCreateEngine();

        void onEngineCreated();

        void onPluginsRegistered();

        void onEngineDestroy();
    }


}
