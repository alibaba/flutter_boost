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
import android.os.Bundle;

import com.taobao.idlefish.flutterboost.messageing.NavigationService;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;
import com.taobao.idlefish.flutterboost.interfaces.IContainerManager;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterEngineProvider;
import com.taobao.idlefish.flutterboost.interfaces.IPlatform;
import com.taobao.idlefish.flutterboost.messageing.base.Broadcastor;
import com.taobao.idlefish.flutterboost.messageing.base.EvenListener;
import com.taobao.idlefish.flutterboost.messageing.base.MessageDispatcher;
import com.taobao.idlefish.flutterboost.messageing.base.MessageDispatcherImp;
import com.taobao.idlefish.flutterboost.messageing.base.MessageImp;
import com.taobao.idlefish.flutterboost.messageing.base.MessageResult;
import com.taobao.idlefish.flutterboost.messageing.handlers.ClosePageHandler;
import com.taobao.idlefish.flutterboost.messageing.handlers.OnFlutterPageResultHandler;
import com.taobao.idlefish.flutterboost.messageing.handlers.OnShownContainerChangedHandler;
import com.taobao.idlefish.flutterboost.messageing.handlers.OpenPageHandler;
import com.taobao.idlefish.flutterboost.messageing.handlers.PageOnStartHandler;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;


public class FlutterBoostPlugin implements MethodChannel.MethodCallHandler, Application.ActivityLifecycleCallbacks {

    private static FlutterBoostPlugin sInstance = null;
    private MessageDispatcher dispatcher = new MessageDispatcherImp();
    private Broadcastor broadcastor = null;

    public static FlutterBoostPlugin getInstance(){
        return sInstance;
    }

    public static synchronized void init(IPlatform platform) {
        if (sInstance == null) {

            sInstance = new FlutterBoostPlugin(platform);

            //Config handler
            sInstance.dispatcher.addHandler(new OnShownContainerChangedHandler());
            sInstance.dispatcher.addHandler(new OnFlutterPageResultHandler());
            sInstance.dispatcher.addHandler(new PageOnStartHandler());
            sInstance.dispatcher.addHandler(new OpenPageHandler());
            sInstance.dispatcher.addHandler(new ClosePageHandler());

            platform.getApplication().registerActivityLifecycleCallbacks(sInstance);
        }
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_boost");
        NavigationService.methodChannel = channel;
        channel.setMethodCallHandler(sInstance);
        sInstance.broadcastor = new Broadcastor(channel);
    }

    public void sendEvent(String name, Map arguments) {
        broadcastor.sendEvent(name, arguments);
    }

    void addEventListener(String name, EvenListener listener) {
        broadcastor.addEventListener(name, listener);
    }

    void removeEventListener(String name, EvenListener listener) {
        broadcastor.removeEventListener(name, listener);
    }


    @Override
    public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if(call.method.equals("__event__")){
            broadcastor.dispatch(call.method,(Map)call.arguments);
        }else{
            dispatcher.dispatch(new MessageImp(call.method, (Map)call.arguments), new MessageResult() {
                @Override
                public void success(Object var1) {
                    result.success(var1);
                }

                @Override
                public void error(String var1, String var2, Object var3) {
                    result.error(var1, var2, var3);
                }

                @Override
                public void notImplemented() {
                    result.notImplemented();
                }
            });
        }
    }

    public static IFlutterEngineProvider engineProvider() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not init yet");
        }

        return BoostEngineProvider.sInstance;
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

    private Activity mCurrentActiveActivity;

    private FlutterBoostPlugin(IPlatform platform) {
        mPlatform = platform;
        mManager = new FlutterViewContainerManager();
    }

    public IFlutterViewContainer findContainerById(String id) {
        return mManager.findContainerById(id);
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
            ctx = sInstance.mPlatform.getApplication();
        }

        sInstance.mPlatform.startActivity(ctx, url, params, requestCode);
    }


    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {

    }

    @Override
    public void onActivityStarted(Activity activity) {
        if (mCurrentActiveActivity == null) {
            Debuger.log("Application entry foreground");

            if (BoostEngineProvider.sInstance.tryGetEngine() != null) {
                Map<String, String> map = new HashMap<>();
                map.put("type", "foreground");
                sInstance.sendEvent("lifecycle",map);
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

            if (BoostEngineProvider.sInstance.tryGetEngine() != null) {
                Map<String, String> map = new HashMap<>();
                map.put("type", "background");
                sInstance.sendEvent("lifecycle",map);
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

            if (BoostEngineProvider.sInstance.tryGetEngine() != null) {
                Map<String, String> map = new HashMap<>();
                map.put("type", "background");
                sInstance.sendEvent("lifecycle",map);
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

//    public static void onBoostResult(IFlutterViewContainer container, int requestCode, int resultCode, Intent intent) {
//        Map map = new HashMap();
//        if (intent != null) {
//            map.put("result", intent.getSerializableExtra(IFlutterViewContainer.RESULT_KEY));
//        }
//        map.put("requestCode", requestCode);
//        map.put("responseCode", resultCode);
//        containerManager().onContainerResult(container, map);
//    }
}


