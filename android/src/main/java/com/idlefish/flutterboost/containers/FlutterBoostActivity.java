package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;


import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.RenderMode;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.DEFAULT_BACKGROUND_MODE;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_BACKGROUND_MODE;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_CACHED_ENGINE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.PAGE_NAME;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.UNIQUE_ID;

public class FlutterBoostActivity extends FlutterActivity implements FlutterViewContainer {
    private FlutterView flutterView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ActivityAndFragmentPatch.pushContainer(this);
    }

    private void findFlutterView(View view) {
        if (view instanceof ViewGroup) {
            ViewGroup vp = (ViewGroup) view;
            for (int i = 0; i < vp.getChildCount(); i++) {
                View viewchild = vp.getChildAt(i);
                if (viewchild instanceof FlutterView) {
                    flutterView = (FlutterView) viewchild;
                    return;
                } else {
                    findFlutterView(viewchild);
                }

            }
        }
    }

    @Override
    public void onResume() {
        if (flutterView == null) {
            findFlutterView(this.getWindow().getDecorView());
        }
        super.onResume();
        ActivityAndFragmentPatch.setStackTop(this);
        ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(flutterView,
                this.getFlutterEngine(), this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        ActivityAndFragmentPatch.removeStackTop(this);
        ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(flutterView, this.getFlutterEngine());
        this.getFlutterEngine().getLifecycleChannel().appIsResumed();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        this.getFlutterEngine().getLifecycleChannel().appIsResumed();

    }

    @Override
    public void onBackPressed() {
        ActivityAndFragmentPatch.onBackPressed(this.getUniqueId());
    }

    @Override
    public RenderMode getRenderMode() {
        return ActivityAndFragmentPatch.getRenderMode();
    }

    @Override
    public Activity getContextActivity() {
        return this;
    }

    @Override
    public void finishContainer(Map<String, Object> result) {
        this.finish();
    }

    @Override
    public String getContainerUrl() {
        return getIntent().getStringExtra(PAGE_NAME);
    }

    @Override
    public String getUniqueId() {
        return getIntent().getStringExtra(UNIQUE_ID);
    }


    public static class CachedEngineIntentBuilder {
        private final Class<? extends FlutterBoostActivity> activityClass;
        private final String cachedEngineId;
        private boolean destroyEngineWithActivity = false;
        private String backgroundMode = DEFAULT_BACKGROUND_MODE;
        private String uniqueId;
        private String pageName;

        public CachedEngineIntentBuilder(
                Class<? extends FlutterBoostActivity> activityClass, String engineId) {
            this.activityClass = activityClass;
            this.cachedEngineId = engineId;
        }


        public FlutterBoostActivity.CachedEngineIntentBuilder destroyEngineWithActivity(boolean destroyEngineWithActivity) {
            this.destroyEngineWithActivity = destroyEngineWithActivity;
            return this;
        }


        public FlutterBoostActivity.CachedEngineIntentBuilder backgroundMode(io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode backgroundMode) {
            this.backgroundMode = backgroundMode.name();
            return this;
        }

        public FlutterBoostActivity.CachedEngineIntentBuilder pageName(String pageName) {
            this.pageName = pageName;
            return this;
        }

        public FlutterBoostActivity.CachedEngineIntentBuilder uniqueId(String uniqueId) {
            this.uniqueId = uniqueId;
            return this;
        }

        public Intent build(Context context) {
            return new Intent(context, activityClass)
                    .putExtra(EXTRA_CACHED_ENGINE_ID, cachedEngineId)
                    .putExtra(EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, destroyEngineWithActivity)
                    .putExtra(EXTRA_BACKGROUND_MODE, backgroundMode)
                    .putExtra(PAGE_NAME, pageName)
                    .putExtra(UNIQUE_ID, uniqueId);
        }
    }

}
