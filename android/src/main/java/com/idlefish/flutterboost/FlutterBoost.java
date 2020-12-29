package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.idlefish.flutterboost.containers.ContainerManager;

public class FlutterBoost {

    static FlutterBoost sInstance = null;

    private NativeRouterApi mApi;

    private Activity topActivity = null;

    private ContainerManager containerManager;

    FlutterBoost() {
        containerManager = new ContainerManager();
    }

    public static FlutterBoost instance() {
        if (sInstance == null) {
            sInstance = new FlutterBoost();
        }
        return sInstance;
    }

    public void init(Application application, NativeRouterApi api) {
        mApi = api;
        application.registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
                topActivity = activity;
            }

            @Override
            public void onActivityStarted(@NonNull Activity activity) {
                topActivity = activity;
            }

            @Override
            public void onActivityResumed(@NonNull Activity activity) {
                topActivity = activity;
            }

            @Override
            public void onActivityPaused(@NonNull Activity activity) {

            }

            @Override
            public void onActivityStopped(@NonNull Activity activity) {

            }

            @Override
            public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

            }

            @Override
            public void onActivityDestroyed(@NonNull Activity activity) {

            }
        });
    }

    public Activity getTopActivity() {
        return topActivity;
    }

    public NativeRouterApi getApi() {
        return mApi;
    }

    public ContainerManager getContainerManager() {
        return containerManager;
    }
}
