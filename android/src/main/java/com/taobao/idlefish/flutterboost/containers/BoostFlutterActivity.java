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
import android.content.Intent;
import android.os.Bundle;

import com.taobao.idlefish.flutterboost.BoostFlutterView;
import com.taobao.idlefish.flutterboost.FlutterBoostPlugin;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;
import com.taobao.idlefish.flutterboost.interfaces.IOperateSyncer;

import java.util.HashMap;

import io.flutter.embedding.android.FlutterView;

public abstract class BoostFlutterActivity extends Activity implements IFlutterViewContainer {

    private BoostFlutterView mFlutterView;
    private IOperateSyncer mSyncer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        BoostFlutterView.Builder builder = new BoostFlutterView.Builder(this);
        mFlutterView = builder.renderMode(FlutterView.RenderMode.texture)
                .transparencyMode(FlutterView.TransparencyMode.opaque)
                .build();

        setContentView(mFlutterView);

        mSyncer = FlutterBoostPlugin.containerManager().generateSyncer(this);
        mSyncer.onCreate();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mSyncer.onAppear();
    }

    @Override
    protected void onPause() {
        mSyncer.onDisappear();
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        mSyncer.onDestroy();
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        mSyncer.onBackPressed();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        mSyncer.onNewIntent(intent);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        mSyncer.onActivityResult(requestCode,resultCode,data);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        mSyncer.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        mSyncer.onTrimMemory(level);
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        mSyncer.onLowMemory();
    }

    @Override
    protected void onUserLeaveHint() {
        super.onUserLeaveHint();
        mSyncer.onUserLeaveHint();
    }

    @Override
    public Activity getContextActivity() {
        return this;
    }

    @Override
    public BoostFlutterView getBoostFlutterView() {
        return mFlutterView;
    }

    @Override
    public void finishContainer() {
        finish();
    }

    @Override
    public void onContainerShown() {}

    @Override
    public void onContainerHidden() {}

    @Override
    public void setBoostResult(HashMap result) {
        Intent data = new Intent();
        data.putExtra(RESULT_KEY,result);
        setResult(RESULT_OK,data);
    }
}
