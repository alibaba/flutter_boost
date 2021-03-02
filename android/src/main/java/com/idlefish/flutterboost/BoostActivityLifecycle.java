package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;

public class BoostActivityLifecycle implements Application.ActivityLifecycleCallbacks {
    private Activity currentActiveActivity;
    private boolean alreadyCreated = false;

    private void dispatchForegroundEvent() {
        FlutterBoost.instance().getPlugin().onForeground();
    }

    private void dispatchBackgroundEvent() {
        FlutterBoost.instance().getPlugin().onBackground();
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        FlutterBoost.instance().setCurrentActivity(activity) ;
        // fix bug : The LauncherActivity will be launch by clicking app icon when app
        // enter background in HuaWei Rom, cause missing foreground event
        if (alreadyCreated && currentActiveActivity == null) {
            Intent intent = activity.getIntent();
            if (!activity.isTaskRoot()
                    && intent != null
                    && intent.hasCategory(Intent.CATEGORY_LAUNCHER)
                    && intent.getAction() != null
                    && intent.getAction().equals(Intent.ACTION_MAIN)) {
                return;
            }
        }
        alreadyCreated = true;
        currentActiveActivity = activity;
    }

    @Override
    public void onActivityStarted(Activity activity) {
        if (!alreadyCreated) {
            return;
        }
        if (currentActiveActivity == null) {
            dispatchForegroundEvent();
        }
        currentActiveActivity = activity;
    }

    @Override
    public void onActivityResumed(Activity activity) {
        FlutterBoost.instance().setCurrentActivity(activity) ;
        if (!alreadyCreated) {
            return;
        }
        currentActiveActivity = activity;
    }

    @Override
    public void onActivityPaused(Activity activity) {
    }

    @Override
    public void onActivityStopped(Activity activity) {
        if (!alreadyCreated) {
            return;
        }
        if (currentActiveActivity == activity) {
            dispatchBackgroundEvent();
            currentActiveActivity = null;
        }
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
    }

    @Override
    public void onActivityDestroyed(Activity activity) {
        if (!alreadyCreated) {
            return;
        }
        if (currentActiveActivity == activity) {
            dispatchBackgroundEvent();
            currentActiveActivity = null;
        }
    }
}