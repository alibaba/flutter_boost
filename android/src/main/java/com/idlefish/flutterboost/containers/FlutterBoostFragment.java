package com.idlefish.flutterboost.containers;


import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.util.Map;

import io.flutter.embedding.android.RenderMode;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.PAGE_NAME;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.UNIQUE_ID;

public class FlutterBoostFragment extends CopyFlutterFragment implements FlutterViewContainer {
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        ActivityAndFragmentPatch.setStackTop(this);

        return super.onCreateView(inflater, container, savedInstanceState);

    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        if (hidden) {
            ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(delegate.getFlutterView(), delegate.getFlutterEngine());
        } else {
            ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(delegate.getFlutterView(), delegate.getFlutterEngine(), this);
        }
        super.onHiddenChanged(hidden);
    }

    @Override
    public void onResume() {
        super.onResume();
        ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(delegate.getFlutterView(), delegate.getFlutterEngine(), this);

    }

    @Override
    public RenderMode getRenderMode() {
        return ActivityAndFragmentPatch.getRenderMode();
    }

    @Override
    public void onPause() {
        super.onPause();
        ActivityAndFragmentPatch.removeStackTop(this);
        ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(delegate.getFlutterView(), delegate.getFlutterEngine());
    }

    @Override
    public Activity getContextActivity() {
        return this.getActivity();
    }

    @Override
    public void finishContainer(Map<String, Object> result) {
        this.getActivity().finish();
    }

    @Override
    public String getContainerUrl() {
        return getArguments().getString(PAGE_NAME, null);
    }

    @Override
    public String getUniqueId() {
        return getArguments().getString(UNIQUE_ID, null);
    }

}
