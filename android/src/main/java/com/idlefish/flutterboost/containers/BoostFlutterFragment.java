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
package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import com.idlefish.flutterboost.BoostFlutterEngine;
import com.idlefish.flutterboost.BoostFlutterView;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.Utils;
import com.idlefish.flutterboost.interfaces.IFlutterViewContainer;
import com.idlefish.flutterboost.interfaces.IOperateSyncer;

import java.util.Map;

import io.flutter.embedding.android.FlutterView;
import io.flutter.plugin.platform.PlatformPlugin;

abstract public class BoostFlutterFragment extends Fragment implements IFlutterViewContainer {

    protected BoostFlutterEngine mFlutterEngine;
    protected BoostFlutterView mFlutterView;
    protected IOperateSyncer mSyncer;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        mSyncer = FlutterBoost.singleton().containerManager().generateSyncer(this);

        mFlutterEngine = createFlutterEngine();
        mFlutterView = createFlutterView(mFlutterEngine);

        mSyncer.onCreate();

        return mFlutterView;
    }

    protected BoostFlutterEngine createFlutterEngine(){
        return FlutterBoost.singleton().engineProvider().provideEngine(getContext());
    }

    protected BoostFlutterView createFlutterView(BoostFlutterEngine engine){
        BoostFlutterView.Builder builder = new BoostFlutterView.Builder(getContextActivity());

        return builder.flutterEngine(engine)
                .renderMode(FlutterView.RenderMode.texture)
                .transparencyMode(FlutterView.TransparencyMode.opaque)
                .build();
    }

    @Override
    public void onResume() {
        super.onResume();
        mSyncer.onAppear();
        mFlutterEngine.getLifecycleChannel().appIsResumed();

    }

    @Override
    public void onPause() {
        mSyncer.onDisappear();
        super.onPause();
        mFlutterEngine.getLifecycleChannel().appIsInactive();

    }

    @Override
    public void onDestroy() {
        mSyncer.onDestroy();
        super.onDestroy();
    }

    public void onBackPressed() {
        mSyncer.onBackPressed();
    }

    public void onNewIntent(Intent intent) {
        mSyncer.onNewIntent(intent);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        mSyncer.onActivityResult(requestCode,resultCode,data);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        mSyncer.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    public void onTrimMemory(int level) {
        mSyncer.onTrimMemory(level);
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        mSyncer.onLowMemory();
    }

    public void onUserLeaveHint() {
        mSyncer.onUserLeaveHint();
    }

    @Override
    public Activity getContextActivity() {
        return getActivity();
    }

    @Override
    public BoostFlutterView getBoostFlutterView() {
        return mFlutterView;
    }

    @Override
    public void finishContainer(Map<String,Object> result) {
        getFragmentManager().popBackStack();
    }

    @Override
    public void onContainerShown() {}

    @Override
    public void onContainerHidden() {}
}
