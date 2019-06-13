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
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import java.util.LinkedList;
import java.util.List;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.renderer.OnFirstFrameRenderedListener;
import io.flutter.plugin.platform.PlatformPlugin;

public class BoostFlutterView extends FrameLayout {

    private FlutterEngine mFlutterEngine;

    private FlutterView mFlutterView;

    private PlatformPlugin mPlatformPlugin;

    private Bundle mArguments;

    private BoostPluginRegistry mBoostPluginRegistry;

    private final List<OnFirstFrameRenderedListener> mFirstFrameRenderedListeners = new LinkedList<>();

    private final OnFirstFrameRenderedListener mOnFirstFrameRenderedListener = new OnFirstFrameRenderedListener() {
        @Override
        public void onFirstFrameRendered() {
            final Object[] listeners = mFirstFrameRenderedListeners.toArray();
            for (Object obj : listeners) {
                ((OnFirstFrameRenderedListener) obj).onFirstFrameRendered();
            }
        }
    };

    public BoostFlutterView(Context context, FlutterEngine engine, Bundle args) {
        super(context);
        mFlutterEngine = engine;
        mArguments = args;
        init();
    }

    private void init() {
        if (mFlutterEngine == null) {
            mFlutterEngine = createFlutterEngine(getContext());
        }

        if (mArguments == null) {
            mArguments = new Bundle();
        }

        mPlatformPlugin = new PlatformPlugin((Activity) getContext(), mFlutterEngine.getPlatformChannel());

        mFlutterView = new FlutterView(getContext(), getRenderMode(), getTransparencyMode());
        addView(mFlutterView, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        mFlutterView.addOnFirstFrameRenderedListener(mOnFirstFrameRenderedListener);

        mBoostPluginRegistry = new BoostPluginRegistry(mFlutterEngine,(Activity)getContext());
        FlutterBoostPlugin.platform().onRegisterPlugins(mBoostPluginRegistry);
    }

    protected FlutterEngine createFlutterEngine(Context context) {
        return BoostEngineProvider.sInstance.createEngine(context);
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
        mPlatformPlugin.onPostResume();
    }

    public void onResume() {
        Debuger.log("BoostFlutterView onResume");
        mFlutterEngine.getLifecycleChannel().appIsResumed();
    }

//    public void onPostResume() {
//        Debuger.log("BoostFlutterView onPostResume");
//        mPlatformPlugin.onPostResume();
//    }

    public void onPause() {
        Debuger.log("BoostFlutterView onPause");
        mFlutterEngine.getLifecycleChannel().appIsInactive();
    }

    public void onStop() {
        Debuger.log("BoostFlutterView onStop");
        mFlutterEngine.getLifecycleChannel().appIsPaused();
    }

    public void onAttach() {
        Debuger.log("BoostFlutterView onAttach");
        mFlutterView.attachToFlutterEngine(mFlutterEngine);
    }

    public void onDetach() {
        Debuger.log("BoostFlutterView onDetach");
        mFlutterView.removeOnFirstFrameRenderedListener(mOnFirstFrameRenderedListener);
        mFlutterView.detachFromFlutterEngine();
    }

    public void onDestroy() {
        Debuger.log("BoostFlutterView onDestroy");
        mPlatformPlugin = null;
        mFlutterEngine = null;
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        onDetach();
    }

    public void onBackPressed() {
        Log.d("FlutterFragment", "onBackPressed()");
        if (mFlutterEngine != null) {
            mFlutterEngine.getNavigationChannel().popRoute();
        } else {
            Log.w("FlutterFragment", "Invoked onBackPressed() before FlutterFragment was attached to an Activity.");
        }

    }

    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (mFlutterEngine != null) {
            mFlutterEngine.getPluginRegistry().onRequestPermissionsResult(requestCode, permissions, grantResults);
        } else {
            Log.w("FlutterFragment", "onRequestPermissionResult() invoked before FlutterFragment was attached to an Activity.");
        }

    }

    public void onNewIntent(Intent intent) {
        if (mFlutterEngine != null) {
            mFlutterEngine.getPluginRegistry().onNewIntent(intent);
        } else {
            Log.w("FlutterFragment", "onNewIntent() invoked before FlutterFragment was attached to an Activity.");
        }

    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (mFlutterEngine != null) {
            mFlutterEngine.getPluginRegistry().onActivityResult(requestCode, resultCode, data);
        } else {
            Log.w("FlutterFragment", "onActivityResult() invoked before FlutterFragment was attached to an Activity.");
        }

    }

    public void onUserLeaveHint() {
        if (mFlutterEngine != null) {
            mFlutterEngine.getPluginRegistry().onUserLeaveHint();
        } else {
            Log.w("FlutterFragment", "onUserLeaveHint() invoked before FlutterFragment was attached to an Activity.");
        }

    }

    public void onTrimMemory(int level) {
        if (mFlutterEngine != null) {
            if (level == 10) {
                mFlutterEngine.getSystemChannel().sendMemoryPressureWarning();
            }
        } else {
            Log.w("FlutterFragment", "onTrimMemory() invoked before FlutterFragment was attached to an Activity.");
        }
    }

    public void onLowMemory() {
        mFlutterEngine.getSystemChannel().sendMemoryPressureWarning();
    }

    public static class Builder {
        private Context context;
        private FlutterEngine engine;
        private FlutterView.RenderMode renderMode;
        private FlutterView.TransparencyMode transparencyMode;

        public Builder(Context ctx) {
            this.context = ctx;
            renderMode = FlutterView.RenderMode.surface;
            transparencyMode = FlutterView.TransparencyMode.transparent;
        }

        public Builder flutterEngine(FlutterEngine engine) {
            this.engine = engine;
            return this;
        }


        public Builder renderMode(FlutterView.RenderMode renderMode) {
            this.renderMode = renderMode;
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

            return new BoostFlutterView(context, engine, args);
        }
    }
}
