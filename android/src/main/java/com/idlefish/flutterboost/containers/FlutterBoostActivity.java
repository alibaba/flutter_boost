package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import com.idlefish.flutterboost.Assert;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostUtils;
import com.idlefish.flutterboost.Messages;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;
import io.flutter.embedding.android.FlutterTextureView;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.renderer.FlutterRenderer;
import io.flutter.plugin.platform.PlatformPlugin;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.ACTIVITY_RESULT_KEY;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_BACKGROUND_MODE;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_CACHED_ENGINE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_ENABLE_STATE_RESTORATION;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_UNIQUE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL_PARAM;

public class FlutterBoostActivity extends FlutterActivity implements FlutterViewContainer {
    private static final String TAG = "FlutterBoostActivity";
    private static final boolean DEBUG = false;
    private final String who = UUID.randomUUID().toString();
    private final FlutterTextureHooker textureHooker =new FlutterTextureHooker();
    private FlutterView flutterView;
    private PlatformPlugin platformPlugin;
    private LifecycleStage stage;
    private boolean isAttached = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        final FlutterContainerManager containerManager = FlutterContainerManager.instance();
        // try to detach prevous container from the engine.
        FlutterViewContainer top = containerManager.getTopContainer();
        if (top != null && top != this) top.detachFromEngineIfNeeded();
        super.onCreate(savedInstanceState);
        stage = LifecycleStage.ON_CREATE;
        flutterView = FlutterBoostUtils.findFlutterView(getWindow().getDecorView());
        flutterView.detachFromFlutterEngine(); // Avoid failure when attaching to engine in |onResume|.
        FlutterBoost.instance().getPlugin().onContainerCreated(this);
        if (DEBUG) Log.d(TAG, "#onCreate: " + this);
    }

    // @Override
    public void detachFromFlutterEngine() {
        /**
         * Override and do nothing.
         *
         * The idea here is to avoid releasing delegate when
         * a new FlutterActivity is attached in Flutter2.0.
         */
        if (DEBUG) Log.d(TAG, "#detachFromFlutterEngine: " + this);
    }

    @Override
    // This method is called right before the activity's onPause() callback.
    public void onUserLeaveHint() {
        super.onUserLeaveHint();
        if (DEBUG) Log.d(TAG, "#onUserLeaveHint: " + this);
    }

    @Override
    protected void onStart() {
        super.onStart();
        stage = LifecycleStage.ON_START;
        if (DEBUG) Log.d(TAG, "#onStart: " + this);
    }

    @Override
    protected void onStop() {
        super.onStop();
        stage = LifecycleStage.ON_STOP;
        getFlutterEngine().getLifecycleChannel().appIsResumed();
        if (DEBUG) Log.d(TAG, "#onStop: " + this);
    }

    @Override
    public void onResume() {
        super.onResume();
        final FlutterContainerManager containerManager = FlutterContainerManager.instance();
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
            FlutterViewContainer top = containerManager.getTopActivityContainer();
            boolean isActiveContainer = containerManager.isActiveContainer(this);
            if (isActiveContainer && top != null && top != this && !top.isOpaque() && top.isPausing()) {
                Log.w(TAG, "Skip the unexpected activity lifecycle event on Android Q. " +
                        "See https://issuetracker.google.com/issues/185693011 for more details.");
                return;
            }
        }

        stage = LifecycleStage.ON_RESUME;

        // try to detach prevous container from the engine.
        FlutterViewContainer top = containerManager.getTopContainer();
        if (top != null && top != this) top.detachFromEngineIfNeeded();

        performAttach();
        textureHooker.onFlutterTextureViewRestoreState();
        FlutterBoost.instance().getPlugin().onContainerAppeared(this);
        getFlutterEngine().getLifecycleChannel().appIsResumed();

        // Since we takeover PlatformPlugin from FlutterActivityAndFragmentDelegate,
        // the system UI overlays can't be updated in |onPostResume| callback. So we
        // update system UI overlays to match Flutter's desired system chrome style here.
        Assert.assertNotNull(platformPlugin);
        platformPlugin.updateSystemUiOverlays();
        if (DEBUG) Log.d(TAG, "#onResume: " + this + ", isOpaque=" + isOpaque());
    }

    @Override
    protected void onPause() {
        super.onPause();
        FlutterViewContainer top = FlutterContainerManager.instance().getTopActivityContainer();
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
            if (top != null && top != this && !top.isOpaque() && top.isPausing()) {
                Log.w(TAG, "Skip the unexpected activity lifecycle event on Android Q. " +
                        "See https://issuetracker.google.com/issues/185693011 for more details.");
                return;
            }
        }

        stage = LifecycleStage.ON_PAUSE;

        FlutterBoost.instance().getPlugin().onContainerDisappeared(this);
        getFlutterEngine().getLifecycleChannel().appIsResumed();

        // We defer |performDetach| call to new Flutter container's |onResume|.
        setIsFlutterUiDisplayed(false);
        if (DEBUG) Log.d(TAG, "#onPause: " + this + ", isOpaque=" + isOpaque());
    }

    @Override
    public void onFlutterTextureViewCreated(FlutterTextureView flutterTextureView) {
        super.onFlutterTextureViewCreated(flutterTextureView);
        textureHooker.hookFlutterTextureView(flutterTextureView);
    }

    private void performAttach() {
        if (!isAttached) {
            // Attach plugins to the activity.
            getFlutterEngine().getActivityControlSurface().attachToActivity(getActivity(), getLifecycle());

            if (platformPlugin == null) {
                platformPlugin = new PlatformPlugin(getActivity(), getFlutterEngine().getPlatformChannel());
            }

            // Attach rendering pipeline.
            flutterView.attachToFlutterEngine(getFlutterEngine());
            isAttached = true;
            if (DEBUG) Log.d(TAG, "#performAttach: " + this);
        }
    }

    private void performDetach() {
        if (isAttached) {
            // Plugins are no longer attached to the activity.
            getFlutterEngine().getActivityControlSurface().detachFromActivity();

            // Release Flutter's control of UI such as system chrome.
            releasePlatformChannel();

            // Detach rendering pipeline.
            flutterView.detachFromFlutterEngine();
            isAttached = false;
            if (DEBUG) Log.d(TAG, "#performDetach: " + this);
        }
    }

    private void releasePlatformChannel() {
        if (platformPlugin != null) {
            platformPlugin.destroy();
            platformPlugin = null;
        }
    }

    // Fix black screen when activity transition
    private void setIsFlutterUiDisplayed(boolean isDisplayed) {
        try {
            FlutterRenderer flutterRenderer = getFlutterEngine().getRenderer();
            Field isDisplayingFlutterUiField = FlutterRenderer.class.getDeclaredField("isDisplayingFlutterUi");
            isDisplayingFlutterUiField.setAccessible(true);
            isDisplayingFlutterUiField.setBoolean(flutterRenderer, false);
            assert(!flutterRenderer.isDisplayingFlutterUi());
        } catch (Exception e) {
            Log.e(TAG, "You *should* keep fields in io.flutter.embedding.engine.renderer.FlutterRenderer.");
            e.printStackTrace();
        }
    }

    @Override
    public void detachFromEngineIfNeeded() {
        performDetach();
    }

    @Override
    protected void onDestroy() {
        stage = LifecycleStage.ON_DESTROY;
        detachFromEngineIfNeeded();
        textureHooker.onFlutterTextureViewRelease();

        // Get engine before |super.onDestroy| callback.
        FlutterEngine engine = getFlutterEngine();
        super.onDestroy();
        engine.getLifecycleChannel().appIsResumed(); // Go after |super.onDestroy|.
        FlutterBoost.instance().getPlugin().onContainerDestroyed(this);
        if (DEBUG) Log.d(TAG, "#onDestroy: " + this);
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
        // We takeover |PlatformPlugin| here.
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
        // Intercept the user's press of the back key.
        FlutterBoost.instance().getPlugin().onBackPressed();
        if (DEBUG) Log.d(TAG, "#onBackPressed: " + this);
    }

    @Override
    public RenderMode getRenderMode() {
        // Default to |FlutterTextureView|.
        return RenderMode.texture;
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
        if (DEBUG) Log.d(TAG, "#finishContainer: " + this);
    }

    @Override
    public String getUrl() {
        if (!getIntent().hasExtra(EXTRA_URL)) {
            Log.e(TAG, "Oops! The activity url are *MISSED*! You should override"
                    + " the |getUrl|, or set url via |CachedEngineIntentBuilder.url|.");
            return null;
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
    public boolean isOpaque() {
        return getBackgroundMode() ==  BackgroundMode.opaque;
    }

    @Override
    public boolean isPausing() {
        return (stage == LifecycleStage.ON_PAUSE || stage == LifecycleStage.ON_STOP) && !isFinishing();
    }

    public static class CachedEngineIntentBuilder {
        private final Class<? extends FlutterBoostActivity> activityClass;
        private boolean destroyEngineWithActivity = false;
        private String backgroundMode = BackgroundMode.opaque.name();
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


        public FlutterBoostActivity.CachedEngineIntentBuilder backgroundMode(BackgroundMode backgroundMode) {
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
