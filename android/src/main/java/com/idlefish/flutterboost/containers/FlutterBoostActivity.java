package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.os.Bundle;


import java.util.Map;

import io.flutter.embedding.android.RenderMode;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.PAGE_NAME;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.UNIQUE_ID;

public class FlutterBoostActivity extends CopyFlutterActvity implements FlutterViewContainer {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ActivityAndFragmentPatch.pushContainer(this);
    }

    @Override
    public void onResume() {
        super.onResume();
        ActivityAndFragmentPatch.setStackTop(this);
        ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(this.delegate.getFlutterView(),
                this.delegate.getFlutterEngine(), this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        ActivityAndFragmentPatch.removeStackTop(this);
        ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(delegate.getFlutterView(), delegate.getFlutterEngine());
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        ActivityAndFragmentPatch.removeContainer(this);
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

}
