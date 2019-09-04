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
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.idlefish.flutterboost.interfaces.IContainerManager;
import com.idlefish.flutterboost.interfaces.IContainerRecord;
import com.idlefish.flutterboost.interfaces.IFlutterEngineProvider;
import com.idlefish.flutterboost.interfaces.IFlutterViewContainer;
import com.idlefish.flutterboost.interfaces.IPlatform;
import com.idlefish.flutterboost.interfaces.IStateListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterBoost {

    static FlutterBoost sInstance = null;

    public static synchronized void init(IPlatform platform) {
        if (sInstance == null) {
            sInstance = new FlutterBoost(platform);
        }

        if (platform.whenEngineStart() == IPlatform.IMMEDIATELY) {
            sInstance.mEngineProvider
                    .provideEngine(platform.getApplication())
                    .startRun(null);
        }
    }

    public static FlutterBoost singleton() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoost not init yet");
        }

        return sInstance;
    }

    private final IPlatform mPlatform;
    private final FlutterViewContainerManager mManager;
    private final IFlutterEngineProvider mEngineProvider;

    IStateListener mStateListener;
    Activity mCurrentActiveActivity;

    private FlutterBoost(IPlatform platform) {
        mPlatform = platform;
        mManager = new FlutterViewContainerManager();

        IFlutterEngineProvider provider = platform.engineProvider();
        if(provider == null) {
            provider = new BoostEngineProvider();
        }
        mEngineProvider = provider;
        platform.getApplication().registerActivityLifecycleCallbacks(new ActivityLifecycleCallbacks());

        BoostChannel.addActionAfterRegistered(new BoostChannel.ActionAfterRegistered() {
            @Override
            public void onChannelRegistered(BoostChannel channel) {
                channel.addMethodCallHandler(new BoostMethodHandler());
            }
        });
    }

    public IFlutterEngineProvider engineProvider() {
        return sInstance.mEngineProvider;
    }

    public IContainerManager containerManager() {
        return sInstance.mManager;
    }

    public IPlatform platform() {
        return sInstance.mPlatform;
    }

    public BoostChannel channel() {
        return BoostChannel.singleton();
    }

    public Activity currentActivity() {
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
                        .provideEngine(activity)
                        .startRun(activity);
            }
        }

        @Override
        public void onActivityStarted(Activity activity) {
            if (mCurrentActiveActivity == null) {
                Debuger.log("Application entry foreground");

                if (mEngineProvider.tryGetEngine() != null) {
                    HashMap<String, String> map = new HashMap<>();
                    map.put("type", "foreground");
                    channel().sendEvent("lifecycle",map);
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
                    HashMap<String, String> map = new HashMap<>();
                    map.put("type", "background");
                    channel().sendEvent("lifecycle",map);
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
                    HashMap<String, String> map = new HashMap<>();
                    map.put("type", "background");
                    channel().sendEvent("lifecycle",map);
                }
                mCurrentActiveActivity = null;
            }
        }
    }

    class BoostMethodHandler implements MethodChannel.MethodCallHandler {

        @Override
        public void onMethodCall(MethodCall methodCall, final MethodChannel.Result result) {
            switch (methodCall.method) {
                case "pageOnStart":
                {
                    Map<String, Object> pageInfo = new HashMap<>();

                    try {
                        IContainerRecord record = mManager.getCurrentTopRecord();

                        if (record == null) {
                            record = mManager.getLastGenerateRecord();
                        }

                        if(record != null) {
                            pageInfo.put("name", record.getContainer().getContainerUrl());
                            pageInfo.put("params", record.getContainer().getContainerUrlParams());
                            pageInfo.put("uniqueId", record.uniqueId());
                        }

                        result.success(pageInfo);
                    } catch (Throwable t) {
                        result.error("no flutter page found!",t.getMessage(),t);
                    }
                }
                break;
                case "openPage":
                {
                    try {
                        Map<String,Object> params = methodCall.argument("urlParams");
                        Map<String,Object> exts = methodCall.argument("exts");
                        String url = methodCall.argument("url");

                        mManager.openContainer(url, params, exts, new FlutterViewContainerManager.OnResult() {
                            @Override
                            public void onResult(Map<String, Object> rlt) {
                                if (result != null) {
                                    result.success(rlt);
                                }
                            }
                        });
                    }catch (Throwable t){
                        result.error("open page error",t.getMessage(),t);
                    }
                }
                break;
                case "closePage":
                {
                    try {
                        String uniqueId = methodCall.argument("uniqueId");
                        Map<String,Object> resultData = methodCall.argument("result");
                        Map<String,Object> exts = methodCall.argument("exts");

                        mManager.closeContainer(uniqueId, resultData,exts);
                        result.success(true);
                    }catch (Throwable t){
                        result.error("close page error",t.getMessage(),t);
                    }
                }
                break;
                case "onShownContainerChanged":
                {
                    try {
                        String newId = methodCall.argument("newName");
                        String oldId = methodCall.argument("oldName");

                        mManager.onShownContainerChanged(newId,oldId);
                        result.success(true);
                    }catch (Throwable t){
                        result.error("onShownContainerChanged",t.getMessage(),t);
                    }
                }
                break;
                default:
                {
                    result.notImplemented();
                }
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


