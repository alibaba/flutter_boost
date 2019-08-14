/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 Alibaba Group
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.taobao.idlefish.flutterboost.containers;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import androidx.fragment.app.Fragment;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ProgressBar;

import com.taobao.idlefish.flutterboost.BoostFlutterView;
import com.taobao.idlefish.flutterboost.Debuger;
import com.taobao.idlefish.flutterboost.FlutterBoostPlugin;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;

import java.util.HashMap;

import io.flutter.plugin.common.PluginRegistry;

abstract public class BoostFlutterFragment extends Fragment implements IFlutterViewContainer {

    FlutterContent mContent;
    PluginRegistry mRegistry;

    boolean resumed = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mRegistry = FlutterBoostPlugin.containerManager().onContainerCreate(this);
        onRegisterPlugins(mRegistry);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        mContent = new FlutterContent(getActivity());
        return mContent;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (!resumed) {
            resumed = true;
            FlutterBoostPlugin.containerManager().onContainerAppear(this);
            mContent.attachFlutterView(getBoostFlutterView());
            Log.e("FlutterBoost", "FlutterMenuFragment resume");
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (resumed) {
            resumed = false;
            mContent.snapshot();
            FlutterBoostPlugin.containerManager().onContainerDisappear(this);
            Log.e("FlutterBoost", "FlutterMenuFragment stop");
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mContent != null) {
            mContent.destroy();
        }
        FlutterBoostPlugin.containerManager().onContainerDestroy(this);
    }

    @Override
    public void onContainerShown() {
        mContent.onContainerShown();
    }

    @Override
    public void onContainerHidden() {
        mContent.onContainerHidden();
    }

    @Override
    public BoostFlutterView getBoostFlutterView() {
        return FlutterBoostPlugin.viewProvider().createFlutterView(this);
    }

    @Override
    public boolean isFinishing() {
        return getActivity().isFinishing();
    }

    protected View createSplashScreenView() {
        FrameLayout layout = new FrameLayout(getContext());
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER;
        layout.addView(new ProgressBar(getContext()),params);
        return layout;
    }

    protected View createFlutterInitCoverView() {
        View initCover = new View(getActivity());
        initCover.setBackgroundColor(Color.WHITE);
        return initCover;
    }

    @Override
    public void setBoostResult(HashMap result) {
    }

    class FlutterContent extends FlutterViewStub {

        public FlutterContent(Context context) {
            super(context);
        }

        @Override
        public View createFlutterInitCoverView() {
            return BoostFlutterFragment.this.createFlutterInitCoverView();
        }

        @Override
        public BoostFlutterView getBoostFlutterView() {
            return BoostFlutterFragment.this.getBoostFlutterView();
        }

        @Override
        public View createSplashScreenView() {
            return BoostFlutterFragment.this.createSplashScreenView();
        }
    }
}
