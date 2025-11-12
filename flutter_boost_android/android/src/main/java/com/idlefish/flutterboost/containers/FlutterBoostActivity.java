// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import com.idlefish.flutterboost.Assert;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostUtils;

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
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
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
    private static final String TAG = "FlutterBoost_java";
    private final String who = UUID.randomUUID().toString();
    private final FlutterTextureHooker textureHooker =new FlutterTextureHooker();
    private FlutterView flutterView;
    protected PlatformPlugin platformPlugin;
    private LifecycleStage stage;
    private boolean isAttached = false;

    PlatformChannel.SystemChromeStyle restoreTheme = null;

    private boolean isDebugLoggingEnabled() {
        return FlutterBoostUtils.isDebugLoggingEnabled();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onCreate: " + this);
        final FlutterContainerManager containerManager = FlutterContainerManager.instance();
        FlutterViewContainer top = containerManager.getTopContainer();
        if (top != this && top instanceof FlutterBoostActivity) {
            // find the theme of the previous container
            restoreTheme = ContainerThemeMgr.findTheme((FlutterBoostActivity) top);
        } else if (top == null) {
            // this is the first active container, try to get the theme of the last-destroyed container
            restoreTheme = ContainerThemeMgr.getFinalStyle();
        }
        super.onCreate(savedInstanceState);
        stage = LifecycleStage.ON_CREATE;
        flutterView = FlutterBoostUtils.findFlutterView(getWindow().getDecorView());
        flutterView.detachFromFlutterEngine(); // Avoid failure when attaching to engine in |onResume|.
        FlutterBoost.instance().getPlugin().onContainerCreated(this);
    }

    @Override
    public void detachFromFlutterEngine() {
        /**
         * TODO:// Override and do nothing to avoid destroying
         * FlutterView unexpectedly.
         */
        if (isDebugLoggingEnabled()) Log.d(TAG, "#detachFromFlutterEngine: " + this);
    }

    @Override
    public boolean shouldDispatchAppLifecycleState() {
        return false;
    }

    /**
     * Whether to automatically attach the {@link FlutterView} to the engine.
     *
     * <p>In the add-to-app scenario where multiple {@link FlutterView} share the same {@link
     * FlutterEngine}, the host application desires to determine the timing of attaching the {@link
     * FlutterView} to the engine, for example, during the {@code onResume} instead of the {@code
     * onCreateView}.
     *
     * <p>Defaults to {@code true}.
     */
    @Override
    public boolean attachToEngineAutomatically() {
        return false;
    }

    @Override
    // This method is called right before the activity's onPause() callback.
    public void onUserLeaveHint() {
        super.onUserLeaveHint();
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onUserLeaveHint: " + this);
    }

    @Override
    protected void onStart() {
        super.onStart();
        stage = LifecycleStage.ON_START;
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onStart: " + this);
    }

    @Override
    protected void onStop() {
        super.onStop();
        stage = LifecycleStage.ON_STOP;
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onStop: " + this);
    }

    @Override
    public void onResume() {
        super.onResume();
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onResume: " + this + ", isOpaque=" + isOpaque());
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


        // try to detach *prevous* container from the engine.
        FlutterViewContainer top = containerManager.getTopContainer();
        if (top != null && top != this) top.detachFromEngineIfNeeded();

        FlutterBoost.instance().getPlugin().onContainerAppeared(this, () -> {
            // attach new container to the engine.
            attachToEngineIfNeeded();
            textureHooker.onFlutterTextureViewRestoreState();
            // Since we takeover PlatformPlugin from FlutterActivityAndFragmentDelegate,
            // the system UI overlays can't be updated in |onPostResume| callback. So we
            // update system UI overlays to match Flutter's desired system chrome style here.
            onUpdateSystemUiOverlays();
        });
    }

    // Update system UI overlays to match Flutter's desired system chrome style
    protected void onUpdateSystemUiOverlays() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onUpdateSystemUiOverlays: " + this);
        Assert.assertNotNull(platformPlugin);
        platformPlugin.updateSystemUiOverlays();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onPause: " + this + ", isOpaque=" + isOpaque());
        // update the restoreTheme of this container
        ContainerThemeMgr.onActivityPause(this, restoreTheme);
        restoreTheme = ContainerThemeMgr.findTheme(this);
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

        // We defer |performDetach| call to new Flutter container's |onResume|.
        setIsFlutterUiDisplayed(false);
    }

    @Override
    public void onFlutterTextureViewCreated(FlutterTextureView flutterTextureView) {
        super.onFlutterTextureViewCreated(flutterTextureView);
        textureHooker.hookFlutterTextureView(flutterTextureView);
    }

    private void performAttach() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#performAttach: " + this);

        // Attach plugins to the activity.
        getFlutterEngine().getActivityControlSurface().attachToActivity(getExclusiveAppComponent(), getLifecycle());

        if (platformPlugin == null) {
            platformPlugin = new PlatformPlugin(getActivity(), getFlutterEngine().getPlatformChannel(), this);
            // Set the restoreTheme to current container
            if (restoreTheme != null) {
                FlutterBoostUtils.setSystemChromeSystemUIOverlayStyle(platformPlugin, restoreTheme);
            }
        }

        // Attach rendering pipeline.
        flutterView.attachToFlutterEngine(getFlutterEngine());
    }

    private void performDetach() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#performDetach: " + this);

        // Plugins are no longer attached to the activity.
        getFlutterEngine().getActivityControlSurface().detachFromActivity();

        // Release Flutter's control of UI such as system chrome.
        releasePlatformChannel();

        // Detach rendering pipeline.
        flutterView.detachFromFlutterEngine();
    }

    private void releasePlatformChannel() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#releasePlatformChannel: " + this);
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

    public void attachToEngineIfNeeded() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#attachToEngineIfNeeded: " + this);
        if (!isAttached) {
            performAttach();
            isAttached = true;
        }
    }

    @Override
    public void detachFromEngineIfNeeded() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#detachFromEngineIfNeeded: " + this);
        if (isAttached) {
            performDetach();
            isAttached = false;
        }
    }

    @Override
    protected void onDestroy() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onDestroy: " + this);
        ContainerThemeMgr.onActivityDestroy(this);
        stage = LifecycleStage.ON_DESTROY;
        detachFromEngineIfNeeded();
        textureHooker.onFlutterTextureViewRelease();
        FlutterBoost.instance().getPlugin().onContainerDestroyed(this);

        // Call super's onDestroy
        super.onDestroy();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onConfigurationChanged: " + (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE ? "LANDSCAPE" : "PORTRAIT") + ", " +  this);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onSaveInstanceState: " + this);
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
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onBackPressed: " + this);
        // Intercept the user's press of the back key.
        FlutterBoost.instance().getPlugin().onBackPressed();
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
        if (isDebugLoggingEnabled()) Log.d(TAG, "#finishContainer: " + this);
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
