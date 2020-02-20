package com.idlefish.flutterboost;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;
import io.flutter.plugin.common.PluginRegistry.UserLeaveHintListener;
import io.flutter.plugin.common.PluginRegistry.ViewDestroyListener;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterView;
import io.flutter.view.TextureRegistry;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

class BoostRegistrar implements Registrar, FlutterPlugin, ActivityAware {
    private static final String TAG = "ShimRegistrar";
    private final Map<String, Object> globalRegistrarMap;
    private final String pluginId;
    private final Set<ViewDestroyListener> viewDestroyListeners = new HashSet();
    private final Set<RequestPermissionsResultListener> requestPermissionsResultListeners = new HashSet();
    private final Set<ActivityResultListener> activityResultListeners = new HashSet();
    private final Set<NewIntentListener> newIntentListeners = new HashSet();
    private final Set<UserLeaveHintListener> userLeaveHintListeners = new HashSet();
    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityPluginBinding;

    public BoostRegistrar(@NonNull String pluginId, @NonNull Map<String, Object> globalRegistrarMap) {
        this.pluginId = pluginId;
        this.globalRegistrarMap = globalRegistrarMap;
    }

    public Activity activity() {
        if(this.activityPluginBinding != null){
           return this.activityPluginBinding.getActivity();
        }
        if(FlutterBoost.instance().currentActivity()!=null){
            return  FlutterBoost.instance().currentActivity();
        }
        return null;
    }

    public Context context() {
        return this.pluginBinding != null ? this.pluginBinding.getApplicationContext() : null;
    }

    public Context activeContext() {
        return (Context)(this.activityPluginBinding == null ? this.context() : this.activity());
    }

    public BinaryMessenger messenger() {
        return this.pluginBinding != null ? this.pluginBinding.getFlutterEngine().getDartExecutor() : null;
    }

    public TextureRegistry textures() {
        return this.pluginBinding != null ? this.pluginBinding.getFlutterEngine().getRenderer() : null;
    }

    public PlatformViewRegistry platformViewRegistry() {
        return this.pluginBinding != null ? this.pluginBinding.getFlutterEngine().getPlatformViewsController().getRegistry() : null;
    }

    public FlutterView view() {
        throw new UnsupportedOperationException("The new embedding does not support the old FlutterView.");
    }

    public String lookupKeyForAsset(String asset) {
        return FlutterMain.getLookupKeyForAsset(asset);
    }

    public String lookupKeyForAsset(String asset, String packageName) {
        return FlutterMain.getLookupKeyForAsset(asset, packageName);
    }

    public Registrar publish(Object value) {
        this.globalRegistrarMap.put(this.pluginId, value);
        return this;
    }

    public Registrar addRequestPermissionsResultListener(RequestPermissionsResultListener listener) {
        this.requestPermissionsResultListeners.add(listener);
        if (this.activityPluginBinding != null) {
            this.activityPluginBinding.addRequestPermissionsResultListener(listener);
        }

        return this;
    }

    public Registrar addActivityResultListener(ActivityResultListener listener) {
        this.activityResultListeners.add(listener);
        if (this.activityPluginBinding != null) {
            this.activityPluginBinding.addActivityResultListener(listener);
        }

        return this;
    }

    public Registrar addNewIntentListener(NewIntentListener listener) {
        this.newIntentListeners.add(listener);
        if (this.activityPluginBinding != null) {
            this.activityPluginBinding.addOnNewIntentListener(listener);
        }

        return this;
    }

    public Registrar addUserLeaveHintListener(UserLeaveHintListener listener) {
        this.userLeaveHintListeners.add(listener);
        if (this.activityPluginBinding != null) {
            this.activityPluginBinding.addOnUserLeaveHintListener(listener);
        }

        return this;
    }

    @NonNull
    public Registrar addViewDestroyListener(@NonNull ViewDestroyListener listener) {
        this.viewDestroyListeners.add(listener);
        return this;
    }

    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Log.v("ShimRegistrar", "Attached to FlutterEngine.");
        this.pluginBinding = binding;
    }

    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.v("ShimRegistrar", "Detached from FlutterEngine.");
        Iterator var2 = this.viewDestroyListeners.iterator();

        while(var2.hasNext()) {
            ViewDestroyListener listener = (ViewDestroyListener)var2.next();
            listener.onViewDestroy((FlutterNativeView)null);
        }

        this.pluginBinding = null;
    }

    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.v("ShimRegistrar", "Attached to an Activity.");
        this.activityPluginBinding = binding;
        this.addExistingListenersToActivityPluginBinding();
    }

    public void onDetachedFromActivityForConfigChanges() {
        Log.v("ShimRegistrar", "Detached from an Activity for config changes.");
        this.activityPluginBinding = null;
    }

    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        Log.v("ShimRegistrar", "Reconnected to an Activity after config changes.");
        this.activityPluginBinding = binding;
        this.addExistingListenersToActivityPluginBinding();
    }

    public void onDetachedFromActivity() {
        Log.v("ShimRegistrar", "Detached from an Activity.");
        this.activityPluginBinding = null;
    }

    private void addExistingListenersToActivityPluginBinding() {
        Iterator var1 = this.requestPermissionsResultListeners.iterator();

        while(var1.hasNext()) {
            RequestPermissionsResultListener listener = (RequestPermissionsResultListener)var1.next();
            this.activityPluginBinding.addRequestPermissionsResultListener(listener);
        }

        var1 = this.activityResultListeners.iterator();

        while(var1.hasNext()) {
            ActivityResultListener listener = (ActivityResultListener)var1.next();
            this.activityPluginBinding.addActivityResultListener(listener);
        }

        var1 = this.newIntentListeners.iterator();

        while(var1.hasNext()) {
            NewIntentListener listener = (NewIntentListener)var1.next();
            this.activityPluginBinding.addOnNewIntentListener(listener);
        }

        var1 = this.userLeaveHintListeners.iterator();

        while(var1.hasNext()) {
            UserLeaveHintListener listener = (UserLeaveHintListener)var1.next();
            this.activityPluginBinding.addOnUserLeaveHintListener(listener);
        }

    }
}
