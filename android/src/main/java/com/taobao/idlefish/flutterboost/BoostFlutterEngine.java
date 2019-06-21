package com.taobao.idlefish.flutterboost;

import android.app.Activity;
import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.taobao.idlefish.flutterboost.interfaces.IContainerRecord;
import com.taobao.idlefish.flutterboost.interfaces.IStateListener;

import java.lang.ref.WeakReference;

import io.flutter.app.FlutterPluginRegistry;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterView;
import io.flutter.view.TextureRegistry;

public class BoostFlutterEngine extends FlutterEngine {
    protected final Context mContext;
    protected final BoostPluginRegistry mBoostPluginRegistry;

    protected WeakReference<Activity> mCurrentActivityRef;

    public BoostFlutterEngine(@NonNull Context context) {
        super(context);
        mContext = context.getApplicationContext();
        mBoostPluginRegistry = new BoostPluginRegistry(this,context);
    }

    public void startRun(@Nullable Activity activity) {
        mCurrentActivityRef = new WeakReference<>(activity);

        if (!getDartExecutor().isExecutingDart()) {

            Debuger.log("engine start running...");

            getNavigationChannel().setInitialRoute("/");

            DartExecutor.DartEntrypoint entryPoint = new DartExecutor.DartEntrypoint(
                    mContext.getResources().getAssets(),
                    FlutterMain.findAppBundlePath(mContext),
                    "main");
            getDartExecutor().executeDartEntrypoint(entryPoint);

            final IStateListener stateListener = FlutterBoostPlugin.sInstance.mStateListener;
            if(stateListener != null) {
                stateListener.onEngineStarted(this);
            }

            FlutterBoostPlugin.singleton().platform().onRegisterPlugins(mBoostPluginRegistry);
        }
    }

    public BoostPluginRegistry getBoostPluginRegistry(){
        return mBoostPluginRegistry;
    }

    public boolean isRunning(){
        return getDartExecutor().isExecutingDart();
    }

    public class BoostPluginRegistry extends FlutterPluginRegistry {
        private final FlutterEngine mEngine;

        public BoostPluginRegistry(FlutterEngine engine, Context context) {
            super(engine, context);
            mEngine = engine;
        }

        public PluginRegistry.Registrar registrarFor(String pluginKey) {
            return new BoostRegistrar(mEngine,super.registrarFor(pluginKey));
        }
    }

    public class BoostRegistrar implements PluginRegistry.Registrar {

        private final PluginRegistry.Registrar mRegistrar;
        private final FlutterEngine mEngine;

        BoostRegistrar(FlutterEngine engine, PluginRegistry.Registrar registrar) {
            mRegistrar = registrar;
            mEngine = engine;
        }

        @Override
        public Activity activity() {
            Activity activity;
            IContainerRecord record;

            record = FlutterBoostPlugin.singleton().containerManager().getCurrentTopRecord();
            if(record == null) {
                record = FlutterBoostPlugin.singleton().containerManager().getLastGenerateRecord();
            }

            if(record == null){
                activity = FlutterBoostPlugin.singleton().currentActivity();
            }else{
                activity = record.getContainer().getContextActivity();
            }

            if(activity == null && mCurrentActivityRef != null) {
                activity = mCurrentActivityRef.get();
            }

            if(activity == null) {
                throw new RuntimeException("current has no valid Activity yet");
            }

            return activity;
        }

        @Override
        public Context context() {
            return mRegistrar.context();
        }

        @Override
        public Context activeContext() {
            return mRegistrar.activeContext();
        }

        @Override
        public BinaryMessenger messenger() {
            return mEngine.getDartExecutor();
        }

        @Override
        public TextureRegistry textures() {
            return mEngine.getRenderer();
        }

        @Override
        public PlatformViewRegistry platformViewRegistry() {
            return mRegistrar.platformViewRegistry();
        }

        @Override
        public FlutterView view() {
            throw new RuntimeException("should not use!!!");
        }

        @Override
        public String lookupKeyForAsset(String s) {
            return mRegistrar.lookupKeyForAsset(s);
        }

        @Override
        public String lookupKeyForAsset(String s, String s1) {
            return mRegistrar.lookupKeyForAsset(s,s1);
        }

        @Override
        public PluginRegistry.Registrar publish(Object o) {
            return mRegistrar.publish(o);
        }

        @Override
        public PluginRegistry.Registrar addRequestPermissionsResultListener(PluginRegistry.RequestPermissionsResultListener requestPermissionsResultListener) {
            return mRegistrar.addRequestPermissionsResultListener(requestPermissionsResultListener);
        }

        @Override
        public PluginRegistry.Registrar addActivityResultListener(PluginRegistry.ActivityResultListener activityResultListener) {
            return mRegistrar.addActivityResultListener(activityResultListener);
        }

        @Override
        public PluginRegistry.Registrar addNewIntentListener(PluginRegistry.NewIntentListener newIntentListener) {
            return mRegistrar.addNewIntentListener(newIntentListener);
        }

        @Override
        public PluginRegistry.Registrar addUserLeaveHintListener(PluginRegistry.UserLeaveHintListener userLeaveHintListener) {
            return mRegistrar.addUserLeaveHintListener(userLeaveHintListener);
        }

        @Override
        public PluginRegistry.Registrar addViewDestroyListener(PluginRegistry.ViewDestroyListener viewDestroyListener) {
            return mRegistrar.addViewDestroyListener(viewDestroyListener);
        }
    }
}
