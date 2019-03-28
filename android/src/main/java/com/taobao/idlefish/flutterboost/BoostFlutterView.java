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

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.support.v4.view.ViewCompat;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.SurfaceHolder;
import android.view.WindowInsets;

import com.taobao.idlefish.flutterboost.NavigationService.NavigationService;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterView;

public class BoostFlutterView extends FlutterView {

    private boolean mFirstFrameCalled = false;
    private boolean mResumed = false;
    private WindowInsets mCurrentWindowInsets;

    private BoostCallback mBoostCallback;

    public BoostFlutterView(Context context, AttributeSet attrs, FlutterNativeView nativeView) {
        super(context, attrs, nativeView);
        super.addFirstFrameListener(new FirstFrameListener() {
            @Override
            public void onFirstFrame() {
                mFirstFrameCalled = true;
            }
        });

        try {
            Field field = FlutterView.class.getDeclaredField("mSurfaceCallback");
            field.setAccessible(true);
            SurfaceHolder.Callback cb = (SurfaceHolder.Callback)field.get(this);
            getHolder().removeCallback(cb);
            mBoostCallback = new BoostCallback(cb);
            getHolder().addCallback(mBoostCallback);
        }catch (Throwable t){
            Debuger.exception(t);
        }
    }

    @Override
    public void onStart() {
        //do nothing...
    }

    @Override
    public void onPostResume() {
        //do nothing...
        requestFocus();
    }

    @Override
    public void onPause() {
        //do nothing...
    }

    @Override
    public void onStop() {
        //do nothing...
    }

    @Override
    public FlutterNativeView detach() {
        //do nothing...
        return getFlutterNativeView();
    }

    @Override
    public void destroy() {
        //do nothing...
    }

    @Override
    public Bitmap getBitmap() {
        if(getFlutterNativeView() == null || !getFlutterNativeView().isAttached()) {
            Debuger.exception("FlutterView not attached!");
            return null;
        }

        return super.getBitmap();
    }

    public boolean firstFrameCalled() {
        return mFirstFrameCalled;
    }


    public void boostResume() {
        if (!mResumed) {
            mResumed = true;
            super.onPostResume();
            Debuger.log("resume flutter view");
        }
    }

    public void boostStop() {
        if (mResumed) {
            super.onStop();
            Debuger.log("stop flutter view");
            mResumed = false;
        }
    }

    public boolean isResumed() {
        return  mResumed;
    }

    public void boostDestroy() {
        super.destroy();
    }

    public void scheduleFrame(){
        if (mResumed) {
            Map<String,String> map = new HashMap<>();
            map.put("type","scheduleFrame");
            NavigationService.getService().emitEvent(map);
        }
    }

    class BoostCallback implements SurfaceHolder.Callback {

        final SurfaceHolder.Callback mCallback;

        BoostCallback(SurfaceHolder.Callback cb){
            this.mCallback = cb;
        }

        @Override
        public void surfaceCreated(SurfaceHolder holder) {
            //Debuger.log("flutterView surfaceCreated");
            try {
                mCallback.surfaceCreated(holder);
            }catch (Throwable t){
                Debuger.exception(t);
            }
        }

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
            //Debuger.log("flutterView surfaceChanged");
            try {
                mCallback.surfaceChanged(holder,format,width,height);
                scheduleFrame();
            }catch (Throwable t){
                Debuger.exception(t);
            }
        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {
            //Debuger.log("flutterView surfaceDestroyed");
            try {
                mCallback.surfaceDestroyed(holder);
            }catch (Throwable t){
                Debuger.exception(t);
            }
        }
    }

    @Override
    protected void onAttachedToWindow() {
        //Debuger.log("flutterView onAttachedToWindow");
        super.onAttachedToWindow();
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            final WindowInsets windowInsets = getRootWindowInsets();
//            if(windowInsets != null) {
//                if(mCurrentWindowInsets == null ||
//                        !TextUtils.equals(windowInsets.toString(),mCurrentWindowInsets.toString())) {
//                    Debuger.log("setWindowInsets "+windowInsets.toString());
//
//                    mCurrentWindowInsets = windowInsets;
//                    super.onApplyWindowInsets(mCurrentWindowInsets);
//                }
//            }
//        }else {
//            ViewCompat.requestApplyInsets(this);
//        }
        ViewCompat.requestApplyInsets(this);
    }
}
