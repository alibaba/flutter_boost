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

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.ProgressBar;

import com.taobao.idlefish.flutterboost.BoostFlutterView;
import com.taobao.idlefish.flutterboost.FlutterBoostPlugin;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;

import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterView;

abstract public class BoostFlutterActivity extends FlutterActivity implements IFlutterViewContainer {

    private FlutterContent mFlutterContent;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);

        mFlutterContent = new FlutterContent(this);

        setContentView(mFlutterContent);

        FlutterBoostPlugin.containerManager().onContainerCreate(this);
        onRegisterPlugins(this);
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
        FlutterBoostPlugin.containerManager().onContainerAppear(BoostFlutterActivity.this);
        mFlutterContent.attachFlutterView(getBoostFlutterView());
    }

    @Override
    protected void onPause() {
        mFlutterContent.detachFlutterView();
        FlutterBoostPlugin.containerManager().onContainerDisappear(this);
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        FlutterBoostPlugin.containerManager().onContainerDestroy(this);
        mFlutterContent.destroy();
        super.onDestroy();
    }

    public FlutterView createFlutterView(Context context) {
        return FlutterBoostPlugin.viewProvider().createFlutterView(this);
    }

    @Override
    public FlutterNativeView createFlutterNativeView() {
        return FlutterBoostPlugin.viewProvider().createFlutterNativeView(this);
    }

    @Override
    public boolean retainFlutterNativeView() {
        return true;
    }

    protected View createSplashScreenView() {
        FrameLayout frameLayout = new FrameLayout(this);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER;
        frameLayout.addView(new ProgressBar(this), params);
        return frameLayout;
    }

    protected View createFlutterInitCoverView() {
        View initCover = new View(this);
        initCover.setBackgroundColor(Color.WHITE);
        return initCover;
    }

    @Override
    public void onContainerShown() {
        mFlutterContent.onContainerShown();
    }

    @Override
    public void onContainerHidden() {
        mFlutterContent.onContainerHidden();
    }

    @Override
    public void onBackPressed() {
        FlutterBoostPlugin.containerManager().onBackPressed(this);
    }

    @Override
    public Activity getActivity() {
        return this;
    }

    @Override
    public BoostFlutterView getBoostFlutterView() {
        return (BoostFlutterView) getFlutterView();
    }

    @Override
    public void destroyContainer() {
        finish();
    }

    @Override
    public abstract String getContainerName();

    @Override
    public abstract Map getContainerParams();


    @Override
    public void setBoostResult(HashMap result) {
        FlutterBoostPlugin.setBoostResult(this, result);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        //防止imagepick等回调数据被拦截
        if(data != null && data.hasExtra(IFlutterViewContainer.RESULT_KEY)){
            FlutterBoostPlugin.onBoostResult(this,requestCode,resultCode,data);
        } else {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }

    class FlutterContent extends FlutterViewStub {

        public FlutterContent(Context context) {
            super(context);
        }

        @Override
        public View createFlutterInitCoverView() {
            return BoostFlutterActivity.this.createFlutterInitCoverView();
        }

        @Override
        public BoostFlutterView getBoostFlutterView() {
            return BoostFlutterActivity.this.getBoostFlutterView();
        }

        @Override
        public View createSplashScreenView() {
            return BoostFlutterActivity.this.createSplashScreenView();
        }
    }
}
