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
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import com.alibaba.fastjson.JSON;
import com.taobao.idlefish.flutterboost.NavigationService.NavigationService;
import com.taobao.idlefish.flutterboost.interfaces.IContainerRecord;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;
import com.taobao.idlefish.flutterboost.loader.ServiceLoader;
import com.taobao.idlefish.flutterboost.interfaces.IContainerManager;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewProvider;
import com.taobao.idlefish.flutterboost.interfaces.IPlatform;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

import fleamarket.taobao.com.xservicekit.handler.MessageResult;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterView;


public class FlutterBoostPlugin implements MethodChannel.MethodCallHandler, Application.ActivityLifecycleCallbacks {

    private static FlutterBoostPlugin sInstance = null;

    public static synchronized void init(IPlatform platform) {
        if (sInstance == null) {
            sInstance = new FlutterBoostPlugin(platform);
            platform.getApplication().registerActivityLifecycleCallbacks(sInstance);
            ServiceLoader.load();
        }
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_boost");
        channel.setMethodCallHandler(sInstance);
    }

    public static IFlutterViewProvider viewProvider() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return sInstance.mViewProvider;
    }

    public static IContainerManager containerManager() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return sInstance.mManager;
    }

    public static IPlatform platform() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return sInstance.mPlatform;
    }

    public static Activity currentActivity() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return sInstance.mCurrentActiveActivity;
    }

    private final IPlatform mPlatform;
    private final IContainerManager mManager;
    private final IFlutterViewProvider mViewProvider;
    private final PageResultMediator mMediator;


    private Activity mCurrentActiveActivity;

    private FlutterBoostPlugin(IPlatform platform) {
        mPlatform = platform;
        mViewProvider = new FlutterViewProvider(platform);
        mManager = new FlutterViewContainerManager();
        mMediator = new PageResultMediator();
    }

    public IFlutterViewContainer findContainerById(String id) {
        return mManager.findContainerById(id);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else {
            result.notImplemented();
        }
    }

    public static void openPage(Context context, String url, final Map params, int requestCode) {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet!");
        }

        Context ctx = context;
        if (ctx == null) {
            ctx = currentActivity();
        }

        if (ctx == null) {
            ctx = sInstance.mPlatform.getMainActivity();
        }

        if (ctx == null) {
            ctx = sInstance.mPlatform.getApplication();
        }

        //Handling page result.
        if (sInstance.needResult(params)) {
            sInstance.mMediator.setHandler(url, new PageResultHandler() {
                @Override
                public void onResult(String key, Map resultData) {
                    NavigationService.onNativePageResult(new MessageResult<Boolean>() {
                        @Override
                        public void success(Boolean var1) {
                            //Doing nothing now.
                        }

                        @Override
                        public void error(String var1, String var2, Object var3) {
                            //Doing nothing now.
                        }

                        @Override
                        public void notImplemented() {
                            //Doing nothing now.
                        }
                    }, "no use", key, resultData, params);
                }
            });
        }

        sInstance.mPlatform.startActivity(ctx, concatUrl(url, params), requestCode);
    }

    private Boolean needResult(Map params) {

        if (params == null) return false;

        final String key = "needResult";
        if (params.containsKey(key)) {
            if (params.get(key) instanceof Boolean) {
                return (Boolean) params.get(key);
            }
        }
        return false;
    }

    public static void onPageResult(String key, Map resultData) {

        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet!");
        }

        sInstance.mMediator.onPageResult(key, resultData);
    }

    public static void setHandler(String key, PageResultHandler handler) {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet!");
        }

        sInstance.mMediator.setHandler(key, handler);
    }

    public static void removeHandler(String key) {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet!");
        }

        sInstance.mMediator.removeHandler(key);
    }

    private static String concatUrl(String url, Map params) {
        if (params == null || params.isEmpty()) return url;

        Uri uri = Uri.parse(url);
        Uri.Builder builder = uri.buildUpon();
        for (Object key : params.keySet()) {
            Object value = params.get(key);
            if (value != null) {
                String str;
                if (value instanceof Map || value instanceof List) {
                    try {
                        str = URLEncoder.encode(JSON.toJSONString(value), "utf-8");
                    } catch (UnsupportedEncodingException e) {
                        str = value.toString();
                    }
                } else {
                    str = value.toString();
                }
                builder.appendQueryParameter(String.valueOf(key), str);
            }
        }
        return builder.build().toString();
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {

    }

    @Override
    public void onActivityStarted(Activity activity) {
        if (mCurrentActiveActivity == null) {
            Debuger.log("Application entry foreground");

            if (mViewProvider.tryGetFlutterView() != null) {
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

            if (mViewProvider.tryGetFlutterView() != null) {
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

            if (mViewProvider.tryGetFlutterView() != null) {
                Map<String, String> map = new HashMap<>();
                map.put("type", "background");
                NavigationService.getService().emitEvent(map);
            }
            mCurrentActiveActivity = null;
        }


        //reset view provider when single instance context is destroyed
//        final FlutterView flutterView = mViewProvider.tryGetFlutterView();
//        if(flutterView != null) {
//            Activity ctxActivity = (Activity)flutterView.getContext();
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
//                if((ctxActivity.isDestroyed() || ctxActivity == activity) &&
//                        mManager.getLastRecord() == null) {
//                    mViewProvider.reset();
//                }
//            }
//        }
    }

    public static void setBoostResult(Activity activity, HashMap result) {
        Intent intent = new Intent();
        if (result != null) {
            intent.putExtra(IFlutterViewContainer.RESULT_KEY, result);
        }
        activity.setResult(Activity.RESULT_OK, intent);
    }

    public static void onBoostResult(IFlutterViewContainer container, int requestCode, int resultCode, Intent intent) {
        Map map = new HashMap();
        if (intent != null) {
            map.put("result", intent.getSerializableExtra(IFlutterViewContainer.RESULT_KEY));
        }
        map.put("requestCode", requestCode);
        map.put("responseCode", resultCode);
        containerManager().onContainerResult(container, map);
    }
}


