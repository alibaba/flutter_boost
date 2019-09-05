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
package com.idlefish.flutterboost;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.view.ViewCompat;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.accessibility.AccessibilityNodeProvider;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.idlefish.flutterboost.interfaces.IStateListener;

import java.lang.reflect.Method;
import java.util.LinkedList;
import java.util.List;

import io.flutter.embedding.android.FlutterView;
import io.flutter.plugin.platform.PlatformPlugin;
import io.flutter.view.AccessibilityBridge;

public class BoostFlutterView extends FrameLayout {

    private BoostFlutterEngine mFlutterEngine;

    private XFlutterView mFlutterView;

    private Bundle mArguments;

    private RenderingProgressCoverCreator mRenderingProgressCoverCreator;

    private View mRenderingProgressCover;

    private final List<OnFirstFrameRenderedListener> mFirstFrameRenderedListeners = new LinkedList<>();

    private boolean mEngineAttached = false;

    private boolean mNeedSnapshotWhenDetach = false;

    private SnapshotView mSnapshot;

    private final io.flutter.embedding.engine.renderer.OnFirstFrameRenderedListener mOnFirstFrameRenderedListener =
            new io.flutter.embedding.engine.renderer.OnFirstFrameRenderedListener() {
        @Override
        public void onFirstFrameRendered() {
            Debuger.log("BoostFlutterView onFirstFrameRendered");

            if(mRenderingProgressCover != null && mRenderingProgressCover.getParent() != null) {
                ((ViewGroup)mRenderingProgressCover.getParent()).removeView(mRenderingProgressCover);
            }

            if(mNeedSnapshotWhenDetach) {
                mSnapshot.dismissSnapshot(BoostFlutterView.this);
            }

            final Object[] listeners = mFirstFrameRenderedListeners.toArray();
            for (Object obj : listeners) {
                ((OnFirstFrameRenderedListener) obj).onFirstFrameRendered(BoostFlutterView.this);
            }
        }
    };

    private final ViewTreeObserver.OnGlobalLayoutListener mGlobalLayoutListener = new ViewTreeObserver.OnGlobalLayoutListener() {
        @Override
        public void onGlobalLayout() {
            ViewCompat.requestApplyInsets(mFlutterView);
        }
    };

    public BoostFlutterView(Context context, BoostFlutterEngine engine, Bundle args, RenderingProgressCoverCreator creator) {
        super(context);
        mFlutterEngine = engine;
        mArguments = args;
        mRenderingProgressCoverCreator = creator;
        init();
    }

    private void init() {
        if (mFlutterEngine == null) {
            mFlutterEngine = createFlutterEngine(getContext());
        }

        if (mArguments == null) {
            mArguments = new Bundle();
        }

        mFlutterView = new XFlutterView(getContext(), getRenderMode(), getTransparencyMode());
        addView(mFlutterView, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        mSnapshot = new SnapshotView(getContext());

        if(mRenderingProgressCoverCreator != null) {
            mRenderingProgressCover = mRenderingProgressCoverCreator
                    .createRenderingProgressCover(getContext());
        }else{
            mRenderingProgressCover = createRenderingProgressCorver();
        }

        if(mRenderingProgressCover != null) {
            addView(mRenderingProgressCover, new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }

        mFlutterView.addOnFirstFrameRenderedListener(mOnFirstFrameRenderedListener);

        mFlutterEngine.startRun((Activity)getContext());

        final IStateListener stateListener = FlutterBoost.sInstance.mStateListener;
        if(stateListener != null) {
            stateListener.onFlutterViewInited(mFlutterEngine,this);
        }

        checkAssert();
    }

    private void checkAssert(){
        try {
            Method method = FlutterView.class.getDeclaredMethod("sendViewportMetricsToFlutter");
            if(method == null) {
                throw new Exception("method: FlutterView.sendViewportMetricsToFlutter not found!");
            }
        }catch (Throwable t){
            Debuger.exception(t);
        }
    }

    protected View createRenderingProgressCorver(){
        FrameLayout frameLayout = new FrameLayout(getContext());
        frameLayout.setBackgroundColor(Color.WHITE);

        LinearLayout linearLayout = new LinearLayout(getContext());
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        layoutParams.gravity = Gravity.CENTER;
        frameLayout.addView(linearLayout,layoutParams);

        ProgressBar progressBar = new ProgressBar(getContext());
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER_HORIZONTAL;
        linearLayout.addView(progressBar,params);

        TextView textView = new TextView(getContext());
        params = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.CENTER_HORIZONTAL;
        textView.setText("Frame Rendering...");
        linearLayout.addView(textView,params);

        return frameLayout;
    }

    protected BoostFlutterEngine createFlutterEngine(Context context) {
        return FlutterBoost.singleton().engineProvider().provideEngine(context);
    }

    public void addFirstFrameRendered(OnFirstFrameRenderedListener listener) {
        mFirstFrameRenderedListeners.add(listener);
    }

    public void removeFirstFrameRendered(OnFirstFrameRenderedListener listener) {
        mFirstFrameRenderedListeners.remove(listener);
    }


    protected FlutterView.RenderMode getRenderMode() {
        String renderModeName = mArguments.getString("flutterview_render_mode", FlutterView.RenderMode.surface.name());
        return FlutterView.RenderMode.valueOf(renderModeName);
    }


    protected FlutterView.TransparencyMode getTransparencyMode() {
        String transparencyModeName = mArguments.getString("flutterview_transparency_mode", FlutterView.TransparencyMode.transparent.name());
        return FlutterView.TransparencyMode.valueOf(transparencyModeName);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ViewCompat.requestApplyInsets(this);
        getViewTreeObserver().addOnGlobalLayoutListener(mGlobalLayoutListener);
    }


    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        getViewTreeObserver().removeOnGlobalLayoutListener(mGlobalLayoutListener);
        onDetach();
    }

    public BoostFlutterEngine getEngine(){
        return mFlutterEngine;
    }

    public void onResume() {
        Debuger.log("BoostFlutterView onResume");
//        mFlutterEngine.getLifecycleChannel().appIsResumed();
    }

//    public void onPostResume() {
//        Debuger.log("BoostFlutterView onPostResume");
//        mPlatformPlugin.onPostResume();
//    }

    public void onPause() {
        Debuger.log("BoostFlutterView onPause");
//        mFlutterEngine.getLifecycleChannel().appIsInactive();
    }

    public void onStop() {
        Debuger.log("BoostFlutterView onStop");
//        mFlutterEngine.getLifecycleChannel().appIsPaused();
    }

    public void onAttach() {
        Debuger.log("BoostFlutterView onAttach");
        final IStateListener stateListener = FlutterBoost.sInstance.mStateListener;
        if(stateListener != null) {
            stateListener.beforeEngineAttach(mFlutterEngine,this);
        }
        mFlutterView.attachToFlutterEngine(mFlutterEngine);
        mEngineAttached = true;
        if(stateListener != null) {
            stateListener.afterEngineAttached(mFlutterEngine,this);
        }
    }

    public void toggleSnapshot() {
        mSnapshot.toggleSnapshot(this);
    }

    public void toggleAttach() {
        if(mEngineAttached) {
            onDetach();
        }else{
            onAttach();
        }
    }

    public void onDetach() {
        Debuger.log("BoostFlutterView onDetach");

        if(mNeedSnapshotWhenDetach) {
            mSnapshot.showSnapshot(BoostFlutterView.this);
        }

        final IStateListener stateListener = FlutterBoost.sInstance.mStateListener;
        if(stateListener != null) {
            stateListener.beforeEngineDetach(mFlutterEngine,this);
        }
        mFlutterView.detachFromFlutterEngine();
        mEngineAttached = false;
        if(stateListener != null) {
            stateListener.afterEngineDetached(mFlutterEngine,this);
        }
    }

    public void onDestroy() {
        Debuger.log("BoostFlutterView onDestroy");

        mFlutterView.removeOnFirstFrameRenderedListener(mOnFirstFrameRenderedListener);
        mFlutterView.release();
    }

    //混合栈的返回和原来Flutter的返回逻辑不同
    public void onBackPressed() {
//        Debuger.log("onBackPressed()");
//        if (mFlutterEngine != null) {
//            mFlutterEngine.getNavigationChannel().popRoute();
//        } else {
//            Debuger.log("Invoked onBackPressed() before BoostFlutterView was attached to an Activity.");
//        }
    }

    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (mFlutterEngine != null) {
            mFlutterEngine.getPluginRegistry().onRequestPermissionsResult(requestCode, permissions, grantResults);
        } else {
            Debuger.log("onRequestPermissionResult() invoked before BoostFlutterView was attached to an Activity.");
        }

    }

    public void onNewIntent(Intent intent) {
        if (mFlutterEngine != null) {
            mFlutterEngine.getPluginRegistry().onNewIntent(intent);
        } else {
            Debuger.log("onNewIntent() invoked before BoostFlutterView was attached to an Activity.");
        }

    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (mFlutterEngine != null) {
            mFlutterEngine.getPluginRegistry().onActivityResult(requestCode, resultCode, data);
        } else {
            Debuger.log("onActivityResult() invoked before BoostFlutterView was attached to an Activity.");
        }
    }

    public void onUserLeaveHint() {
        if (mFlutterEngine != null) {
            mFlutterEngine.getPluginRegistry().onUserLeaveHint();
        } else {
            Debuger.log("onUserLeaveHint() invoked before BoostFlutterView was attached to an Activity.");
        }

    }

    public void onTrimMemory(int level) {
        if (mFlutterEngine != null) {
            if (level == 10) {
                mFlutterEngine.getSystemChannel().sendMemoryPressureWarning();
            }
        } else {
            Debuger.log("onTrimMemory() invoked before BoostFlutterView was attached to an Activity.");
        }
    }

    public void onLowMemory() {
        mFlutterEngine.getSystemChannel().sendMemoryPressureWarning();
    }

    public static class Builder {
        private Context context;
        private BoostFlutterEngine engine;
        private FlutterView.RenderMode renderMode;
        private FlutterView.TransparencyMode transparencyMode;
        private RenderingProgressCoverCreator renderingProgressCoverCreator;

        public Builder(Context ctx) {
            this.context = ctx;
            renderMode = FlutterView.RenderMode.surface;
            transparencyMode = FlutterView.TransparencyMode.transparent;
        }

        public Builder flutterEngine(BoostFlutterEngine engine) {
            this.engine = engine;
            return this;
        }


        public Builder renderMode(FlutterView.RenderMode renderMode) {
            this.renderMode = renderMode;
            return this;
        }

        public Builder renderingProgressCoverCreator(RenderingProgressCoverCreator creator) {
            this.renderingProgressCoverCreator = creator;
            return this;
        }

        public Builder transparencyMode(FlutterView.TransparencyMode transparencyMode) {
            this.transparencyMode = transparencyMode;
            return this;
        }

        public BoostFlutterView build() {
            Bundle args = new Bundle();
            args.putString("flutterview_render_mode", renderMode != null ? renderMode.name() : FlutterView.RenderMode.surface.name());
            args.putString("flutterview_transparency_mode", transparencyMode != null ? transparencyMode.name() : FlutterView.TransparencyMode.transparent.name());

            return new BoostFlutterView(context, engine, args,renderingProgressCoverCreator);
        }
    }

    public interface OnFirstFrameRenderedListener {
        void onFirstFrameRendered(BoostFlutterView view);
    }

    public interface RenderingProgressCoverCreator {
        View createRenderingProgressCover(Context context);
    }
}
