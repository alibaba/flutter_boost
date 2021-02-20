package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.HashMap;
import java.util.UUID;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.view.FlutterMain;

public class FlutterBoost {
    public final static String ENGINE_ID = "flutter_boost_default_engine";
    private static FlutterBoost sInstance = null;
    private Activity mTopActivity = null;
    private boolean isRunning = false;
    private FlutterBoostPlugin mPlugin;

    public static FlutterBoost instance() {
        if (sInstance == null) {
            sInstance = new FlutterBoost();
        }
        return sInstance;
    }

    public interface Callback {
        void onStart( FlutterEngine engine);
    }

    /**
     * 初始化接口
     * @param application
     * @param delegate
     *  用户自定义设置
     * @param callback
     *  engine启动后回调
     */
    public void setup(Application application, FlutterBoostDelegate delegate,Callback callback) {
        // 1. initialize default engine
        FlutterEngine engine = FlutterEngineCache.getInstance().get(ENGINE_ID);
        if (engine == null) {
            engine = new FlutterEngine(application);
            engine.getNavigationChannel().setInitialRoute(delegate.initialRoute());
            engine.getDartExecutor().executeDartEntrypoint(new DartExecutor.DartEntrypoint(
                    FlutterMain.findAppBundlePath(), delegate.dartEntrypointFunctionName()));
            if(callback!=null) callback.onStart(engine);
            FlutterEngineCache.getInstance().put(ENGINE_ID, engine);
            isRunning = true;
        }
        // 2. set delegate
        getPlugin().setDelegate(delegate);

        //3. register ActivityLifecycleCallbacks
        setupActivityLifecycleCallback(application);

    }

    /**
     * 获取插件
     *
     * @return
     */
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

    /**
     * 判断engine 是否运行中
     *
     * @return
     */
    public boolean isRunning() {
        return isRunning;
    }

    /**
     * 获取engine
     *
     * @return
     */
    public FlutterEngine getEngine() {
        return FlutterEngineCache.getInstance().get(ENGINE_ID);
    }

    public String createUniqueId() {
        return UUID.randomUUID().toString();
    }

    /**
     * 提供给业务 最上层的activity。
     *
     * @return
     */
    public Activity currentActivity() {
        return mTopActivity;
    }

    public void setCurrentActivity(Activity activity) {
        this.mTopActivity = activity;
    }

    /**
     * 根据unqueid，返回容器
     * 兼容老版本
     *
     * @param uniqueId
     * @return
     */
    public FlutterViewContainer findFlutterViewContainerById(String uniqueId) {
        return getPlugin().findContainerById(uniqueId);
    }

    /**
     * 最上层容器
     * 兼容老版本
     *
     * @return
     */
    public FlutterViewContainer getTopContainer() {
        return getPlugin().getTopContainer();
    }


    private void setupActivityLifecycleCallback(Application application) {
        application.registerActivityLifecycleCallbacks(new BoostActivityLifecycle());
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

    /**
     * 打开一个flutter页面
     * @param pageName
     * @param arguments
     */
    public void open(String pageName, HashMap<String, String> arguments) {
        this.getPlugin().getDelegate().pushFlutterRoute(pageName, null, arguments);
    }

    /**
     * 关闭flutter 页面
     * @param uniqueId
     */
    public void close(String uniqueId) {
        Messages.CommonParams params= new Messages.CommonParams();
        params.setUniqueId(uniqueId);
        this.getPlugin().popRoute(params);
    }
}
