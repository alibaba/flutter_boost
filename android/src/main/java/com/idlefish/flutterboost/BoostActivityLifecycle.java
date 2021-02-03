package com.idlefish.flutterboost;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;

public class BoostActivityLifecycle implements Application.ActivityLifecycleCallbacks {
        private Activity mCurrentActiveActivity;
        private boolean mEnterActivityCreate = false;

        private void callForeground() {
            FlutterBoost.instance().getPlugin().onForeground();

        }

        private void callBackground() {
            FlutterBoost.instance().getPlugin().onBackground();
        }
        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            FlutterBoost.instance().setCurrentActivity(activity) ;
            // fix bug : The LauncherActivity will be launch by clicking app icon when app
            // enter background in HuaWei Rom, cause missing foreground event
            if (mEnterActivityCreate && mCurrentActiveActivity == null) {
                Intent intent = activity.getIntent();
                if (!activity.isTaskRoot()
                        && intent != null
                        && intent.hasCategory(Intent.CATEGORY_LAUNCHER)
                        && intent.getAction() != null
                        && intent.getAction().equals(Intent.ACTION_MAIN)) {
                    return;
                }
            }
            mEnterActivityCreate = true;
            mCurrentActiveActivity = activity;
        }

        @Override
        public void onActivityStarted(Activity activity) {
            if (!mEnterActivityCreate) {
                return;
            }
            if (mCurrentActiveActivity == null) {
                callForeground();
            }
            mCurrentActiveActivity = activity;
        }

        @Override
        public void onActivityResumed(Activity activity) {
            FlutterBoost.instance().setCurrentActivity(activity) ;
            if (!mEnterActivityCreate) {
                return;
            }
            mCurrentActiveActivity = activity;
        }

        @Override
        public void onActivityPaused(Activity activity) {
        }

        @Override
        public void onActivityStopped(Activity activity) {
            if (!mEnterActivityCreate) {
                return;
            }
            if (mCurrentActiveActivity == activity) {
                callBackground();
                mCurrentActiveActivity = null;
            }
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            if (!mEnterActivityCreate) {
                return;
            }
            if (mCurrentActiveActivity == activity) {
                callBackground();
                mCurrentActiveActivity = null;
            }
        }
    }