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

import android.content.Context;

import com.idlefish.flutterboost.interfaces.IFlutterEngineProvider;
import com.idlefish.flutterboost.interfaces.IStateListener;

import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.view.FlutterMain;

public class BoostEngineProvider implements IFlutterEngineProvider {

    private BoostFlutterEngine mEngine = null;

    public BoostEngineProvider() {}

    @Override
    public BoostFlutterEngine createEngine(Context context) {
        return new BoostFlutterEngine(context.getApplicationContext());
    }

    @Override
    public BoostFlutterEngine provideEngine(Context context) {
        Utils.assertCallOnMainThread();

        if (mEngine == null) {
            FlutterShellArgs flutterShellArgs = new FlutterShellArgs(new String[0]);
            FlutterMain.ensureInitializationComplete(
                    context.getApplicationContext(), flutterShellArgs.toArray());

            mEngine = createEngine(context.getApplicationContext());

            final IStateListener stateListener = FlutterBoost.sInstance.mStateListener;
            if(stateListener != null) {
                stateListener.onEngineCreated(mEngine);
            }
        }
        return mEngine;
    }

    @Override
    public BoostFlutterEngine tryGetEngine() {
        return mEngine;
    }

    public static void assertEngineRunning(){
        final BoostFlutterEngine engine = FlutterBoost.singleton().engineProvider().tryGetEngine();
        if(engine == null || !engine.isRunning()) {
            throw new RuntimeException("engine is not running yet!");
        }
    }
}
