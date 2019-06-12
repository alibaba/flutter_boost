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
import android.os.Looper;
import android.support.annotation.NonNull;

import com.taobao.idlefish.flutterboost.interfaces.IFlutterEngineProvider;

import io.flutter.app.FlutterPluginRegistry;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterView;
import io.flutter.view.TextureRegistry;

public class BoostEngineProvider implements IFlutterEngineProvider {

    static final BoostEngineProvider sInstance = new BoostEngineProvider();

    private BoostEngine mEngine = null;

    private BoostEngineProvider() {
    }

    @Override
    public FlutterEngine createEngine(Context context) {

        Utils.assertCallOnMainThread();

        if (mEngine == null) {
            FlutterShellArgs flutterShellArgs = new FlutterShellArgs(new String[0]);
            FlutterMain.ensureInitializationComplete(
                    context.getApplicationContext(), flutterShellArgs.toArray());

            mEngine = new BoostEngine(context.getApplicationContext());
            mEngine.startRun();
        }
        return mEngine;
    }

    @Override
    public FlutterEngine tryGetEngine() {
        return mEngine;
    }

    public static class BoostEngine extends FlutterEngine {
        final Context mContext;

        public BoostEngine(@NonNull Context context) {
            super(context);
            mContext = context;
        }

        public void startRun() {
            if (!getDartExecutor().isExecutingDart()) {
                getNavigationChannel().setInitialRoute("/");

                DartExecutor.DartEntrypoint entryPoint = new DartExecutor.DartEntrypoint(
                        mContext.getResources().getAssets(),
                        FlutterMain.findAppBundlePath(mContext),
                        "main");
                getDartExecutor().executeDartEntrypoint(entryPoint);
            }
        }
    }
}
