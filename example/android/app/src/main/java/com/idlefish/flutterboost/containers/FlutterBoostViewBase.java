package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.activity.ComponentActivity;

import com.idlefish.flutterboost.FlutterBoost;

import java.util.UUID;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.platform.PlatformPlugin;

public abstract class FlutterBoostViewBase extends FrameLayout implements FlutterViewContainer {
    private static final String TAG = "FlutterBoostViewBase";
    private final String who = UUID.randomUUID().toString();

    private final ComponentActivity activity;
    private final FlutterView flutterView;
    private PlatformPlugin platformPlugin;
    private boolean hasDestroyed;
    private boolean hasHooked;

    public FlutterBoostViewBase(ComponentActivity activity) {
        super(activity);
        this.activity = activity;
        flutterView = new FlutterView(activity);
        addView(flutterView);
        FlutterBoost.instance().getPlugin().onContainerCreated(this);
    }

    /**
     * This is the intersection of an available activity and of a visible [FlutterView]. This is
     * where Flutter would start rendering.
     */
    private void hookActivityAndView() {
        assert(activity !=  null && flutterView != null);
        FlutterEngine engine = FlutterBoost.instance().getEngine();
        engine.getLifecycleChannel().appIsResumed();
        assert(engine != null);
        platformPlugin = new PlatformPlugin(activity, engine.getPlatformChannel());
        engine.getActivityControlSurface().attachToActivity(activity, activity.getLifecycle());
        flutterView.attachToFlutterEngine(engine);
        hasHooked = true;
    }

    /**
     * Lost the intersection of either an available activity or a visible
     * [FlutterView].
     */
    private void unhookActivityAndView() {
        if (!hasHooked) return;
        FlutterEngine engine = FlutterBoost.instance().getEngine();
        assert(engine != null && platformPlugin != null);

        // Plugins are no longer attached to an activity.
        engine.getActivityControlSurface().detachFromActivity();

        // Release Flutter's control of UI such as system chrome.
        platformPlugin.destroy();
        platformPlugin = null;

        // Detach rendering pipeline.
        flutterView.detachFromFlutterEngine();
        hasHooked = false;
    }

    private boolean hasDestroyed() {
        if (hasDestroyed) {
            Log.w(TAG, "Application attempted to call on a destroyed View", new Throwable());
        }
        return hasDestroyed;
    }

    public void destroy() {
        if(hasDestroyed()) return;
        FlutterBoost.instance().getPlugin().onContainerDestroyed(this);
        hasDestroyed = true;
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        assert(!hasDestroyed());
        if (getVisibility() == View.VISIBLE) {
            hookActivityAndView();
            FlutterBoost.instance().getPlugin().onContainerAppeared(this);
        } else {
            unhookActivityAndView();
            FlutterBoost.instance().getPlugin().onContainerDisappeared(this);
        }
    }

    public void onBackPressed() {
        assert(!hasDestroyed());
        ActivityAndFragmentPatch.onBackPressed();
    }

    // implements `FlutterViewContainer` interfaces
    @Override
    public Activity getContextActivity() {
        return this.activity;
    }

    @Override
    public String getUniqueId() {
        return this.who + "_" + getUrl();
    }
}