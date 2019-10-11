package com.idlefish.flutterboost;

import android.app.Activity;
import android.content.Context;
import com.idlefish.flutterboost.interfaces.IContainerRecord;
import io.flutter.app.FlutterPluginRegistry;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.view.FlutterView;
import io.flutter.view.TextureRegistry;

import java.lang.ref.WeakReference;

public class BoostPluginRegistry extends FlutterPluginRegistry {
    protected WeakReference<Activity> mCurrentActivityRef;

    private FlutterEngine mEngine;

        public BoostPluginRegistry(FlutterEngine engine, Context context) {
            super(engine, context);
            mEngine = engine;
        }

        public PluginRegistry.Registrar registrarFor(String pluginKey) {
            return new BoostRegistrar(mEngine, super.registrarFor(pluginKey));
        }





    public  class BoostRegistrar implements PluginRegistry.Registrar {

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

            record = NewFlutterBoost.instance().containerManager().getCurrentTopRecord();
            if (record == null) {
                record = NewFlutterBoost.instance().containerManager().getLastGenerateRecord();
            }

            if (record == null) {
                activity = NewFlutterBoost.instance().currentActivity();
            } else {
                activity = record.getContainer().getContextActivity();
            }

            if (activity == null && mCurrentActivityRef != null) {
                activity = mCurrentActivityRef.get();
            }

            if (activity == null) {
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
            return mRegistrar.lookupKeyForAsset(s, s1);
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
