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
package com.taobao.idlefish.flutterboost;

import android.app.Activity;

import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewProvider;
import com.taobao.idlefish.flutterboost.interfaces.IPlatform;

public class FlutterViewProvider implements IFlutterViewProvider {

    private final IPlatform mPlatform;

    private BoostFlutterNativeView mFlutterNativeView = null;
    private BoostFlutterView mFlutterView = null;

    FlutterViewProvider(IPlatform platform){
        mPlatform = platform;
    }



    @Override
    public BoostFlutterView createFlutterView(IFlutterViewContainer container) {
        Activity activity = mPlatform.getMainActivity();

        if(activity == null) {
            Debuger.log("create Flutter View not with MainActivity");
            activity = container.getActivity();
        }

        if (mFlutterView == null) {
            mFlutterView = new BoostFlutterView(activity, null, createFlutterNativeView(container));
        }
        return mFlutterView;
    }

    @Override
    public BoostFlutterNativeView createFlutterNativeView(IFlutterViewContainer container) {
        if (mFlutterNativeView == null) {
            mFlutterNativeView = new BoostFlutterNativeView(container.getActivity().getApplicationContext());
        }
        return mFlutterNativeView;
    }

    @Override
    public BoostFlutterView tryGetFlutterView() {
        return mFlutterView;
    }

    @Override
    public void stopFlutterView() {
        final BoostFlutterView view = mFlutterView;
        if(view != null) {
            view.boostStop();
        }
    }


    @Override
    public void reset() {
        if(mFlutterNativeView != null) {
            mFlutterNativeView.boostDestroy();
            mFlutterNativeView = null;
        }

        if(mFlutterView != null) {
            mFlutterView.boostDestroy();
            mFlutterView = null;
        }
    }
}
