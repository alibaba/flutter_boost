package com.idlefish.flutterboost;

import android.os.Handler;
import android.util.Log;

import androidx.annotation.Nullable;

import com.idlefish.flutterboost.interfaces.IContainerRecord;

import java.io.Serializable;
import java.util.*;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class FlutterBoostPlugin {

    private static FlutterBoostPlugin sInstance;

    private final MethodChannel mMethodChannel;
    private final Set<MethodChannel.MethodCallHandler> mMethodCallHandlers = new HashSet<>();
    private final Map<String, Set<EventListener>> mEventListeners = new HashMap<>();

    private static final Set<ActionAfterRegistered> sActions = new HashSet<>();

    public static FlutterBoostPlugin singleton() {
        if (sInstance == null) {
            throw new RuntimeException("FlutterBoostPlugin not register yet");
        }

        return sInstance;
    }

    public static void addActionAfterRegistered(ActionAfterRegistered action) {
        if (action == null) return;

        if (sInstance == null) {
            sActions.add(action);
        } else {
            action.onChannelRegistered(sInstance);
        }
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        sInstance = new FlutterBoostPlugin(registrar);

        for (ActionAfterRegistered a : sActions) {
            a.onChannelRegistered(sInstance);
        }

        sActions.clear();
    }

    private FlutterBoostPlugin(PluginRegistry.Registrar registrar) {
        mMethodChannel = new MethodChannel(registrar.messenger(), "flutter_boost");

        mMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                if (methodCall.method.equals("__event__")) {
                    String name = methodCall.argument("name");
                    Map args = methodCall.argument("arguments");

                    Object[] listeners = null;
                    synchronized (mEventListeners) {
                        Set<EventListener> set = mEventListeners.get(name);
                        if (set != null) {
                            listeners = set.toArray();
                        }
                    }

                    if (listeners != null) {
                        for (Object o : listeners) {
                            ((EventListener) o).onEvent(name, args);
                        }
                    }
                } else {
                    Object[] handlers;
                    synchronized (mMethodCallHandlers) {
                        handlers = mMethodCallHandlers.toArray();
                    }

                    for (Object o : handlers) {
                        ((MethodChannel.MethodCallHandler) o).onMethodCall(methodCall, result);
                    }
                }
            }
        });

        addMethodCallHandler(new BoostMethodHandler());

    }

    public void invokeMethodUnsafe(final String name, Serializable args) {
        invokeMethod(name, args, new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object o) {
                //every thing ok...
            }

            @Override
            public void error(String s, @Nullable String s1, @Nullable Object o) {
                Debuger.log("invoke method " + name + " error:" + s + " | " + s1);
            }

            @Override
            public void notImplemented() {
                Debuger.log("invoke method " + name + " notImplemented");
            }
        });
    }

    public void invokeMethod(final String name, Serializable args) {
        invokeMethod(name, args, new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object o) {
                //every thing ok...
            }

            @Override
            public void error(String s, @Nullable String s1, @Nullable Object o) {
                Debuger.exception("invoke method " + name + " error:" + s + " | " + s1);
            }

            @Override
            public void notImplemented() {
                Debuger.exception("invoke method " + name + " notImplemented");
            }
        });
    }

    public void invokeMethod(final String name, Serializable args, MethodChannel.Result result) {
        if ("__event__".equals(name)) {
            Debuger.exception("method name should not be __event__");
        }

        mMethodChannel.invokeMethod(name, args, result);
    }

    public void addMethodCallHandler(MethodChannel.MethodCallHandler handler) {
        synchronized (mMethodCallHandlers) {
            mMethodCallHandlers.add(handler);
        }
    }

    public void removeMethodCallHandler(MethodChannel.MethodCallHandler handler) {
        synchronized (mMethodCallHandlers) {
            mMethodCallHandlers.remove(handler);
        }
    }

    public void addEventListener(String name, EventListener listener) {
        synchronized (mEventListeners) {
            Set<EventListener> set = mEventListeners.get(name);
            if (set == null) {
                set = new HashSet<>();
            }
            set.add(listener);
            mEventListeners.put(name, set);
        }
    }

    public void removeEventListener(EventListener listener) {
        synchronized (mEventListeners) {
            for (Set<EventListener> set : mEventListeners.values()) {
                set.remove(listener);
            }
        }
    }

    public void sendEvent(String name, Map args) {
        Map event = new HashMap();
        event.put("name", name);
        event.put("arguments", args);
        mMethodChannel.invokeMethod("__event__", event);
    }

    public interface EventListener {
        void onEvent(String name, Map args);
    }

    public interface ActionAfterRegistered {
        void onChannelRegistered(FlutterBoostPlugin channel);
    }


    class BoostMethodHandler implements MethodChannel.MethodCallHandler {

        @Override
        public void onMethodCall(MethodCall methodCall, final MethodChannel.Result result) {

            FlutterViewContainerManager mManager = (FlutterViewContainerManager) FlutterBoost.instance().containerManager();
            switch (methodCall.method) {
                case "pageOnStart": {
                    Map<String, Object> pageInfo = new HashMap<>();

                    try {
                        IContainerRecord record = mManager.getCurrentTopRecord();

                        if (record == null) {
                            record = mManager.getLastGenerateRecord();
                        }

                        if (record != null) {
                            pageInfo.put("name", record.getContainer().getContainerUrl());
                            pageInfo.put("params", record.getContainer().getContainerUrlParams());
                            pageInfo.put("uniqueId", record.uniqueId());
                        }

                        result.success(pageInfo);
                        FlutterBoost.instance().setFlutterPostFrameCallTime(new Date().getTime());


                    } catch (Throwable t) {
                        result.error("no flutter page found!", t.getMessage(), Log.getStackTraceString(t));
                    }
                }
                break;
                case "openPage": {
                    try {
                        Map<String, Object> params = methodCall.argument("urlParams");
                        Map<String, Object> exts = methodCall.argument("exts");
                        String url = methodCall.argument("url");

                        mManager.openContainer(url, params, exts, new FlutterViewContainerManager.OnResult() {
                            @Override
                            public void onResult(Map<String, Object> rlt) {
                                if (result != null) {
                                    result.success(rlt);
                                }
                            }
                        });
                    } catch (Throwable t) {
                        result.error("open page error", t.getMessage(), Log.getStackTraceString(t));
                    }
                }
                break;
                case "closePage": {
                    try {
                        String uniqueId = methodCall.argument("uniqueId");
                        Map<String, Object> resultData = methodCall.argument("result");
                        Map<String, Object> exts = methodCall.argument("exts");

                        mManager.closeContainer(uniqueId, resultData, exts);
                        result.success(true);
                    } catch (Throwable t) {
                        result.error("close page error", t.getMessage(), Log.getStackTraceString(t));
                    }
                }
                break;
                case "onShownContainerChanged": {
                    try {
                        String newId = methodCall.argument("newName");
                        String oldId = methodCall.argument("oldName");

                        mManager.onShownContainerChanged(newId, oldId);
                        result.success(true);
                    } catch (Throwable t) {
                        result.error("onShownContainerChanged", t.getMessage(), Log.getStackTraceString(t));
                    }
                }
                break;
                default: {
                    result.notImplemented();
                }
            }
        }
    }
}
