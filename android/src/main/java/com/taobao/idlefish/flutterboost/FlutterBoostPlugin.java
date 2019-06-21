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
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.taobao.idlefish.flutterboost.NavigationService.NavigationService;
import com.taobao.idlefish.flutterboost.interfaces.IContainerManager;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterEngineProvider;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;
import com.taobao.idlefish.flutterboost.interfaces.IPlatform;
import com.taobao.idlefish.flutterboost.interfaces.IStateListener;
import com.taobao.idlefish.flutterboost.loader.ServiceLoader;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;


public class FlutterBoostPlugin implements MethodChannel.MethodCallHandler {

    static FlutterBoostPlugin sInstance = null;

    public static synchronized void init(IPlatform platform) {
        if (sInstance == null) {
            sInstance = new FlutterBoostPlugin(platform);
            ServiceLoader.load();
        }

        if (platform.whenEngineStart() == IPlatform.IMMEDIATELY) {
            sInstance.mEngineProvider
                    .createEngine(platform.getApplication())
                    .startRun(null);
        }
    }

    public static FlutterBoostPlugin singleton() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return sInstance;
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_boost");
        channel.setMethodCallHandler(singleton());
    }

    private final IPlatform mPlatform;
    private final IContainerManager mManager;
    private final IFlutterEngineProvider mEngineProvider;
    IStateListener mStateListener;

    private Activity mCurrentActiveActivity;

    private FlutterBoostPlugin(IPlatform platform) {
        mPlatform = platform;
        mManager = new FlutterViewContainerManager();
        mEngineProvider = new BoostEngineProvider();
        platform.getApplication().registerActivityLifecycleCallbacks(new ActivityLifecycleCallbacks());
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else {
            result.notImplemented();
        }
    }


    public IFlutterEngineProvider engineProvider() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return sInstance.mEngineProvider;
    }

    public IContainerManager containerManager() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return sInstance.mManager;
    }

    public IPlatform platform() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return sInstance.mPlatform;
    }

    public Activity currentActivity() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return sInstance.mCurrentActiveActivity;
    }

    public IFlutterViewContainer findContainerById(String id) {
        return mManager.findContainerById(id);
    }


    public void setStateListener(@Nullable IStateListener listener){
        mStateListener = listener;
    }

    class ActivityLifecycleCallbacks implements Application.ActivityLifecycleCallbacks {
        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            if (platform().whenEngineStart() == IPlatform.ANY_ACTIVITY_CREATED) {
                sInstance.mEngineProvider
                        .createEngine(activity)
                        .startRun(activity);
            }
        }

        @Override
        public void onActivityStarted(Activity activity) {
            if (mCurrentActiveActivity == null) {
                Debuger.log("Application entry foreground");

                if (mEngineProvider.tryGetEngine() != null) {
                    Map<String, String> map = new HashMap<>();
                    map.put("type", "foreground");
                    NavigationService.getService().emitEvent(map);
                }
            }
            mCurrentActiveActivity = activity;
        }

        @Override
        public void onActivityResumed(Activity activity) {
            mCurrentActiveActivity = activity;
        }

        @Override
        public void onActivityPaused(Activity activity) {

        }

        @Override
        public void onActivityStopped(Activity activity) {
            if (mCurrentActiveActivity == activity) {
                Debuger.log("Application entry background");

                if (mEngineProvider.tryGetEngine() != null) {
                    Map<String, String> map = new HashMap<>();
                    map.put("type", "background");
                    NavigationService.getService().emitEvent(map);
                }
                mCurrentActiveActivity = null;
            }
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            if (mCurrentActiveActivity == activity) {
                Debuger.log("Application entry background");

                if (mEngineProvider.tryGetEngine() != null) {
                    Map<String, String> map = new HashMap<>();
                    map.put("type", "background");
                    NavigationService.getService().emitEvent(map);
                }
                mCurrentActiveActivity = null;
            }
        }
    }

    public static void setBoostResult(Activity activity, HashMap result) {
        Intent intent = new Intent();
        if (result != null) {
            intent.putExtra(IFlutterViewContainer.RESULT_KEY, result);
        }
        activity.setResult(Activity.RESULT_OK, intent);
    }
}


