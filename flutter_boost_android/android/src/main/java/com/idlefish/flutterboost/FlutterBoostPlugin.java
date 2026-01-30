// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.idlefish.flutterboost;

import android.util.Log;
import android.util.SparseArray;

import com.idlefish.flutterboost.Messages.CommonParams;
import com.idlefish.flutterboost.Messages.FlutterRouterApi;
import com.idlefish.flutterboost.Messages.NativeRouterApi;
import com.idlefish.flutterboost.Messages.StackInfo;
import com.idlefish.flutterboost.containers.FlutterContainerManager;
import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class FlutterBoostPlugin implements FlutterPlugin, NativeRouterApi, ActivityAware {
    private static final String TAG = "FlutterBoost_java";
    private static final String APP_LIFECYCLE_CHANGED_KEY = "app_lifecycle_changed_key";
    private static final String LIFECYCLE_STATE = "lifecycleState";
    // See https://github.com/flutter/engine/pull/42418 for details
    private static final int FLUTTER_APP_STATE_RESUMED = 1;
    private static final int FLUTTER_APP_STATE_PAUSED = 4;

    private FlutterEngine engine;
    private FlutterRouterApi channel;
    private FlutterBoostDelegate delegate;
    private StackInfo dartStack;
    private SparseArray<String> pageNames;
    private int requestCode = 1000;

    private HashMap<String, LinkedList<EventListener>> listenersTable = new HashMap<>();

    private boolean isDebugLoggingEnabled() {
        return FlutterBoostUtils.isDebugLoggingEnabled();
    }

    public FlutterRouterApi getChannel() {
        return channel;
    }

    public void setDelegate(FlutterBoostDelegate delegate) {
        this.delegate = delegate;
    }

    public FlutterBoostDelegate getDelegate() {
        return delegate;
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onAttachedToEngine: " + this);
        NativeRouterApi.setup(binding.getBinaryMessenger(), this);
        engine = binding.getFlutterEngine();
        channel = new FlutterRouterApi(binding.getBinaryMessenger());
        pageNames = new SparseArray<String>();
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onDetachedFromEngine: " + this);
        engine = null;
        channel = null;
    }

    @Override
    public void pushNativeRoute(CommonParams params) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#pushNativeRoute: " + params.getUniqueId() + ", " + this);
        if (delegate != null) {
            requestCode++;
            if (pageNames != null) {
                pageNames.put(requestCode, params.getPageName());
            }
            FlutterBoostRouteOptions options = new FlutterBoostRouteOptions.Builder()
                    .pageName(params.getPageName())
                    .arguments((Map<String, Object>) (Object) params.getArguments())
                    .requestCode(requestCode)
                    .build();
            delegate.pushNativeRoute(options);
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public void pushFlutterRoute(CommonParams params) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#pushFlutterRoute: " + params.getUniqueId() + ", " + this);
        if (delegate != null) {
            FlutterBoostRouteOptions options = new FlutterBoostRouteOptions.Builder()
                    .pageName(params.getPageName())
                    .uniqueId(params.getUniqueId())
                    .opaque(params.getOpaque())
                    .arguments((Map<String, Object>) (Object) params.getArguments())
                    .build();
            delegate.pushFlutterRoute(options);
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public void popRoute(CommonParams params, Messages.Result<Void> result) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#popRoute: " + params.getUniqueId() + ", " + this);
        if (delegate != null) {
            FlutterBoostRouteOptions options = new FlutterBoostRouteOptions.Builder()
                    .pageName(params.getPageName())
                    .uniqueId(params.getUniqueId())
                    .arguments((Map<String, Object>) (Object) params.getArguments())
                    .build();
            boolean isHandle = delegate.popRoute(options);
            //isHandle代表是否已经自定义处理，如果未自定义处理走默认逻辑
            if (!isHandle) {
                String uniqueId = params.getUniqueId();
                if (uniqueId != null) {
                    FlutterViewContainer container = FlutterContainerManager.instance().findContainerById(uniqueId);
                    if (container != null) {
                        container.finishContainer((Map<String, Object>) (Object) params.getArguments());
                    }
                    result.success(null);
                } else {
                    throw new RuntimeException("Oops!! The unique id is null!");
                }
            } else {
                //被拦截处理了，那么直接通知result
                result.success(null);
            }
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public StackInfo getStackFromHost() {
        if (dartStack == null) {
            return StackInfo.fromMap(new HashMap());
        }
        if (isDebugLoggingEnabled()) Log.d(TAG, "#getStackFromHost: " + dartStack + ", " + this);
        return dartStack;
    }

    @Override
    public void saveStackToHost(StackInfo arg) {
        dartStack = arg;
        if (isDebugLoggingEnabled()) Log.d(TAG, "#saveStackToHost: " + dartStack + ", " + this);
    }

    @Override
    public void sendEventToNative(CommonParams arg) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#sendEventToNative: " + this);
        //deal with the event from flutter side
        String key = arg.getKey();
        Map<String, Object> arguments = arg.getArguments();
        assert (key != null);

        if (arguments == null) {
            arguments = new HashMap<>();
        }

        List<EventListener> listeners = listenersTable.get(key);
        if (listeners == null) {
            return;
        }

        for (EventListener listener : listeners) {
            listener.onEvent(key, arguments);
        }
    }

    ListenerRemover addEventListener(String key, EventListener listener) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#addEventListener: " + key + ", " + this);
        assert (key != null && listener != null);

        LinkedList<EventListener> listeners = listenersTable.get(key);
        if (listeners == null) {
            listeners = new LinkedList<>();
            listenersTable.put(key, listeners);
        }
        listeners.add(listener);

        LinkedList<EventListener> finalListeners = listeners;
        return () -> finalListeners.remove(listener);
    }

    void sendEventToFlutter(String key, Map<String, Object> args) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#sendEventToFlutter: " + key + ", " + this);
        Messages.CommonParams params = new Messages.CommonParams();
        params.setKey(key);
        params.setArguments(args);
        getChannel().sendEventToFlutter(params, reply -> {});
    }

    void changeFlutterAppLifecycle(int state) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#changeFlutterAppLifecycle: " + state + ", " + this);
        assert (state == FLUTTER_APP_STATE_PAUSED || state == FLUTTER_APP_STATE_RESUMED);
        Map arguments = new HashMap();
        arguments.put(LIFECYCLE_STATE, state);
        sendEventToFlutter(APP_LIFECYCLE_CHANGED_KEY, arguments);
    }

    private void checkEngineState() {
        if (engine == null || !engine.getDartExecutor().isExecutingDart()) {
            throw new RuntimeException("The engine is not ready for use. " +
                    "The message may be drop silently by the engine. " +
                    "You should check 'DartExecutor.isExecutingDart()' first!");
        }
    }

    public void pushRoute(String uniqueId, String pageName, Map<String, Object> arguments,
                          final FlutterRouterApi.Reply<Void> callback) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#pushRoute start: " + pageName + ", " + uniqueId + ", " + this);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            params.setPageName(pageName);
            params.setArguments(arguments);
            channel.pushRoute(params, reply -> {
                if (isDebugLoggingEnabled()) Log.d(TAG, "#pushRoute end: " + pageName + ", " + uniqueId);
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void popRoute(String uniqueId, final FlutterRouterApi.Reply<Void> callback) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#popRoute start: " + uniqueId + ", " + this);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            channel.popRoute(params, reply -> {
                if (isDebugLoggingEnabled()) Log.d(TAG, "#popRoute end: " + uniqueId + ", " + this);
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onBackPressed() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onBackPressed start: " + this);
        if (channel != null) {
            checkEngineState();
            channel.onBackPressed(reply -> {
                if (isDebugLoggingEnabled()) Log.d(TAG, "#onBackPressed end: " + this);
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void removeRoute(String uniqueId, final FlutterRouterApi.Reply<Void> callback) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#removeRoute start: " + uniqueId + ", " + this);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            channel.removeRoute(params, reply -> {
                if (isDebugLoggingEnabled()) Log.d(TAG, "#removeRoute end: " + uniqueId + ", " + this);
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onForeground() {
        Log.d(TAG, "## onForeground start: " + this);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            channel.onForeground(params, reply -> {
                Log.d(TAG, "## onForeground end: " + this);
            });

            // The scheduling frames are resumed when [onForeground] is called.
            changeFlutterAppLifecycle(FLUTTER_APP_STATE_RESUMED);
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onBackground() {
        Log.d(TAG, "## onBackground start: " + this);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            channel.onBackground(params, reply -> {
                Log.d(TAG, "## onBackground end: " + this);
            });

            // The scheduling frames are paused when [onBackground] is called.
            changeFlutterAppLifecycle(FLUTTER_APP_STATE_PAUSED);
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onContainerShow(String uniqueId) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onContainerShow start: " + uniqueId + ", " + this);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            channel.onContainerShow(params, reply -> {
                if (isDebugLoggingEnabled()) Log.d(TAG, "#onContainerShow end: " + uniqueId + ", " + this);
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onContainerHide(String uniqueId) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onContainerHide start: " + uniqueId + ", " + this);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            channel.onContainerHide(params, reply -> {
                if (isDebugLoggingEnabled()) Log.d(TAG, "#onContainerHide end: " + uniqueId + ", " + this);
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onContainerCreated(FlutterViewContainer container) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onContainerCreated: " + container.getUniqueId() + ", " + this);
        FlutterContainerManager.instance().addContainer(container.getUniqueId(), container);
        if (FlutterContainerManager.instance().getContainerSize() == 1) {
           changeFlutterAppLifecycle(FLUTTER_APP_STATE_RESUMED);
        }
    }

    public void onContainerAppeared(FlutterViewContainer container, Runnable onPushRouteComplete) {
        String uniqueId = container.getUniqueId();
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onContainerAppeared: " + uniqueId + ", " + this);
        FlutterContainerManager.instance().activateContainer(uniqueId, container);
        pushRoute(uniqueId, container.getUrl(), container.getUrlParams(), reply -> {
            if (FlutterContainerManager.instance().isTopContainer(uniqueId)) {
                if (onPushRouteComplete != null) {
                    onPushRouteComplete.run();
                }
            }
        });
        //onContainerDisappeared并非异步触发，为了匹配对应，onContainerShow也不做异步
        onContainerShow(uniqueId);
    }

    public void onContainerDisappeared(FlutterViewContainer container) {
        String uniqueId = container.getUniqueId();
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onContainerDisappeared: " + uniqueId + ", " + this);
        onContainerHide(uniqueId);
    }

    public void onContainerDestroyed(FlutterViewContainer container) {
        String uniqueId = container.getUniqueId();
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onContainerDestroyed: " + uniqueId + ", " + this);
        removeRoute(uniqueId, reply -> {});
        FlutterContainerManager.instance().removeContainer(uniqueId);
        if (FlutterContainerManager.instance().getContainerSize() == 0) {
            changeFlutterAppLifecycle(FLUTTER_APP_STATE_PAUSED);
        }
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onAttachedToActivity: " + this);
        activityPluginBinding.addActivityResultListener((requestCode, resultCode, intent) -> {
            if (channel != null) {
                checkEngineState();
                CommonParams params = new CommonParams();
                String pageName = pageNames.get(requestCode);
                pageNames.remove(requestCode);
                if (null != pageName) {
                    params.setPageName(pageName);
                    if (intent != null) {
                        Map<String, Object> result = FlutterBoostUtils.bundleToMap(intent.getExtras());
                        params.setArguments(result);
                    }

                    // Get a result back from an activity when it ends.
                    channel.onNativeResult(params, reply -> {
                    if (isDebugLoggingEnabled()) Log.d(TAG, "#onNativeResult return, pageName=" + pageName + ", " + this);
                    });
                }
            } else {
                throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
            }
            return true;
        });
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onDetachedFromActivityForConfigChanges: " + this);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onReattachedToActivityForConfigChanges: " + this);
    }

    @Override
    public void onDetachedFromActivity() {
        if (isDebugLoggingEnabled()) Log.d(TAG, "#onDetachedFromActivity: " + this);
    }
}
