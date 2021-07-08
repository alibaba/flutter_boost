package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostUtils;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.platform.PlatformPlugin;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.ACTIVITY_RESULT_KEY;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.DEFAULT_BACKGROUND_MODE;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_BACKGROUND_MODE;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_CACHED_ENGINE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_ENABLE_STATE_RESTORATION;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_UNIQUE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL_PARAM;

public class FlutterBoostActivity extends FlutterActivity implements FlutterViewContainer {
    private static final String TAG = "FlutterBoostActivity";
    private final String who = UUID.randomUUID().toString();
    private FlutterView flutterView;
    private PlatformPlugin platformPlugin;
    private boolean isAttachedToActivity = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        flutterView = FlutterBoostUtils.findFlutterView(getWindow().getDecorView());
        FlutterBoost.instance().getPlugin().onContainerCreated(this);
    }

    // @Override
    public void detachFromFlutterEngine() {
        /**
         * Override and do nothing.
         *
         * The idea here is to avoid releasing delegate when
         * a new FlutterActivity is attached in Flutter2.0.
         */
    }

    @Override
    public void onResume() {
        super.onResume();
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
            if (FlutterBoost.instance().isAppInBackground() &&
                    !FlutterContainerManager.instance().isTopContainer(getUniqueId())) {
                Log.w(TAG, "Unexpected activity lifecycle event on Android Q. " +
                        "See https://issuetracker.google.com/issues/185693011 for more details.");
                return;
            }
        }

        platformPlugin = new PlatformPlugin(getActivity(), getFlutterEngine().getPlatformChannel());
        attachToActivity();
        FlutterBoost.instance().getPlugin().onContainerAppeared(this);
        assert (flutterView != null);
        ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(flutterView, getFlutterEngine());
    }

    @Override
    protected void onStop() {
        super.onStop();
        getFlutterEngine().getLifecycleChannel().appIsResumed();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
            if (FlutterBoost.instance().isAppInBackground() &&
                    !FlutterContainerManager.instance().isTopContainer(getUniqueId())) {
                Log.w(TAG, "Unexpected activity lifecycle event on Android Q. " +
                        "See https://issuetracker.google.com/issues/185693011 for more details.");
                return;
            }
        }

        FlutterBoost.instance().getPlugin().onContainerDisappeared(this);
        assert (flutterView != null);
        ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(flutterView, getFlutterEngine());
        detachFromActivity();
        platformPlugin.destroy();
        platformPlugin = null;
        getFlutterEngine().getLifecycleChannel().appIsResumed();
    }

    @Override
    protected void onDestroy() {
        // Get engine before |super.onDestroy| callback.
        FlutterEngine engine = getFlutterEngine();
        super.onDestroy();
        engine.getLifecycleChannel().appIsResumed();
        FlutterBoost.instance().getPlugin().onContainerDestroyed(this);
    }

    @Override
    public boolean shouldRestoreAndSaveState() {
        if (getIntent().hasExtra(EXTRA_ENABLE_STATE_RESTORATION)) {
            return getIntent().getBooleanExtra(EXTRA_ENABLE_STATE_RESTORATION, false);
        }
        // Defaults to |true|.
        return true;
    }

    @Override
    public PlatformPlugin providePlatformPlugin(Activity activity, FlutterEngine flutterEngine) {
        return null;
    }

    @Override
    public boolean shouldDestroyEngineWithHost() {
        // The |FlutterEngine| should outlive this FlutterActivity.
        return false;
    }

    @Override
    public boolean shouldAttachEngineToActivity() {
        // We manually manage the relationship between the Activity and FlutterEngine here.
        return false;
    }

    @Override
    public void onBackPressed() {
        ActivityAndFragmentPatch.onBackPressed();
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
        if (result != null) {
            Intent intent = new Intent();
            intent.putExtra(ACTIVITY_RESULT_KEY, new HashMap<String, Object>(result));
            setResult(Activity.RESULT_OK, intent);
        }
        finish();
    }

    @Override
    public String getUrl() {
        if (!getIntent().hasExtra(EXTRA_URL)) {
            throw new RuntimeException("Oops! The activity url are *MISSED*! You should "
                    + "override the |getUrl|, or set url via CachedEngineIntentBuilder.");
        }
        return getIntent().getStringExtra(EXTRA_URL);
    }

    @Override
    public Map<String, Object> getUrlParams() {
        return (HashMap<String, Object>)getIntent().getSerializableExtra(EXTRA_URL_PARAM);
    }

    @Override
    public String getUniqueId() {
        if (!getIntent().hasExtra(EXTRA_UNIQUE_ID)) {
            return this.who;
        }
        return getIntent().getStringExtra(EXTRA_UNIQUE_ID);
    }

    @Override
    public String getCachedEngineId() {
      return FlutterBoost.ENGINE_ID;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // lifecycle is onActivityResult->onResume
        attachToActivity();
        super.onActivityResult(requestCode, resultCode, data);
    }

    private void attachToActivity() {
        if (isAttachedToActivity) {
            return;
        }
        isAttachedToActivity = true;
        getFlutterEngine().getActivityControlSurface().attachToActivity(getActivity(), getLifecycle());
    }

    private void detachFromActivity() {
        if (!isAttachedToActivity) {
            return;
        }
        isAttachedToActivity = false;
        getFlutterEngine().getActivityControlSurface().detachFromActivity();
    }

    public static class CachedEngineIntentBuilder {
        private final Class<? extends FlutterBoostActivity> activityClass;
        private boolean destroyEngineWithActivity = false;
        private String backgroundMode = DEFAULT_BACKGROUND_MODE;
        private String url;
        private HashMap<String, Object> params;
        private String uniqueId;

        public CachedEngineIntentBuilder(Class<? extends FlutterBoostActivity> activityClass) {
            this.activityClass = activityClass;
        }


        public FlutterBoostActivity.CachedEngineIntentBuilder destroyEngineWithActivity(boolean destroyEngineWithActivity) {
            this.destroyEngineWithActivity = destroyEngineWithActivity;
            return this;
        }


        public FlutterBoostActivity.CachedEngineIntentBuilder backgroundMode(io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode backgroundMode) {
            this.backgroundMode = backgroundMode.name();
            return this;
        }

        public FlutterBoostActivity.CachedEngineIntentBuilder url(String url) {
            this.url = url;
            return this;
        }

        public FlutterBoostActivity.CachedEngineIntentBuilder urlParams(Map<String, Object> params) {
            this.params = (params instanceof HashMap) ? (HashMap)params : new HashMap<String, Object>(params);
            return this;
        }

        public FlutterBoostActivity.CachedEngineIntentBuilder uniqueId(String uniqueId) {
            this.uniqueId = uniqueId;
            return this;
        }

        public Intent build(Context context) {
            return new Intent(context, activityClass)
                    .putExtra(EXTRA_CACHED_ENGINE_ID, FlutterBoost.ENGINE_ID) // default engine
                    .putExtra(EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, destroyEngineWithActivity)
                    .putExtra(EXTRA_BACKGROUND_MODE, backgroundMode)
                    .putExtra(EXTRA_URL, url)
                    .putExtra(EXTRA_URL_PARAM, params)
                    .putExtra(EXTRA_UNIQUE_ID, uniqueId != null ? uniqueId : FlutterBoostUtils.createUniqueId(url));
        }
    }

}
