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
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.taobao.idlefish.flutterboost.BoostFlutterView;
import com.taobao.idlefish.flutterboost.Debuger;

abstract public class FlutterViewStub extends FrameLayout {

    public static final Handler sHandler = new ProcessHandler(Looper.getMainLooper());

    protected Bitmap mBitmap;
    protected ImageView mSnapshot;
    protected FrameLayout mStub;
    protected View mCover;
    protected View mSplashScreenView;

    public FlutterViewStub(Context context) {
        super(context);

        mStub = new FrameLayout(context);
        mStub.setBackgroundColor(Color.WHITE);
        addView(mStub, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        mSnapshot = new ImageView(context);
        mSnapshot.setScaleType(ImageView.ScaleType.FIT_CENTER);
        mSnapshot.setLayoutParams(new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        mCover = createFlutterInitCoverView();
        addView(mCover, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        final BoostFlutterView flutterView = getBoostFlutterView();
        if (!flutterView.firstFrameCalled()) {
            mSplashScreenView = createSplashScreenView();
            addView(mSplashScreenView, new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }
    }

    public void onContainerShown() {
        Debuger.log("onContainerShown");
        sHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (mSplashScreenView != null) {
                    FlutterViewStub.this.removeView(mSplashScreenView);
                    mSplashScreenView = null;
                }

                if (mCover != null) {
                    FlutterViewStub.this.removeView(mCover);
                }

                if (mSnapshot.getParent() == FlutterViewStub.this) {
                    FlutterViewStub.this.removeView(mSnapshot);
                    mSnapshot.setImageBitmap(null);
                    if (mBitmap != null && !mBitmap.isRecycled()) {
                        mBitmap.recycle();
                        mBitmap = null;
                    }
                }

                getBoostFlutterView().scheduleFrame();
                getBoostFlutterView().requestFocus();
                getBoostFlutterView().invalidate();
            }
        }, 167);
    }

    public void onContainerHidden() {
        //Debuger.log("onContainerHidden");
    }

    public void snapshot() {
        if (mStub.getChildCount() <= 0) return;
        if (mSnapshot.getParent() != null) return;

        BoostFlutterView flutterView = (BoostFlutterView) mStub.getChildAt(0);

        mBitmap = flutterView.getBitmap();
        if (mBitmap != null && !mBitmap.isRecycled()) {
            mSnapshot.setImageBitmap(mBitmap);
            addView(mSnapshot);
        }
    }

    public void attachFlutterView(final BoostFlutterView flutterView) {
        if (flutterView.getParent() != mStub) {
            sHandler.removeMessages(ProcessHandler.MSG_DETACH);

            Debuger.log("attachFlutterView");

            if (flutterView.getParent() != null) {
                ((ViewGroup) flutterView.getParent()).removeView(flutterView);
            }

            mStub.addView(flutterView, new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }
    }


    public void detachFlutterView() {
        if (mStub.getChildCount() <= 0) return;

        final BoostFlutterView flutterView = (BoostFlutterView) mStub.getChildAt(0);

        if (flutterView == null) return;

        if (mSnapshot.getParent() == null) {
            mBitmap = flutterView.getBitmap();
            if (mBitmap != null && !mBitmap.isRecycled()) {
                mSnapshot.setImageBitmap(mBitmap);
                Debuger.log("snapshot view");
                addView(mSnapshot);
            }
        }

        Message msg = new Message();
        msg.what = ProcessHandler.MSG_DETACH;
        msg.obj = new Runnable() {
            @Override
            public void run() {
                if (flutterView.getParent() != null && flutterView.getParent() == mStub) {
                    Debuger.log("detachFlutterView");
                    mStub.removeView(flutterView);
                }
            }
        };
        sHandler.sendMessageDelayed(msg,18);
    }

    public void destroy() {
        removeAllViews();
        mSnapshot.setImageBitmap(null);
        if (mBitmap != null && !mBitmap.isRecycled()) {
            mBitmap.recycle();
            mBitmap = null;
        }
    }

    protected View createFlutterInitCoverView() {
        View initCover = new View(getContext());
        initCover.setBackgroundColor(Color.WHITE);
        return initCover;
    }

    protected View createSplashScreenView() {
        FrameLayout layout = new FrameLayout(getContext());
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER;
        layout.addView(new ProgressBar(getContext()),params);
        return layout;
    }

    abstract protected BoostFlutterView getBoostFlutterView();

    public static class ProcessHandler extends Handler {

        static final int MSG_DETACH = 175101;

        ProcessHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            if (msg.obj instanceof Runnable) {
                Runnable run = (Runnable) msg.obj;
                run.run();
            }
        }
    }
}
