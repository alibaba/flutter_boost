package com.idlefish.flutterboost;

import android.support.annotation.Nullable;

import com.idlefish.flutterboost.interfaces.IStateListener;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class BoostChannel {

    private static BoostChannel sInstance;

    private final MethodChannel mMethodChannel;
    private final Set<MethodChannel.MethodCallHandler> mMethodCallHandlers = new HashSet<>();
    private final Map<String,Set<EventListener>> mEventListeners = new HashMap<>();

    private static final Set<ActionAfterRegistered> sActions = new HashSet<>();

    public static BoostChannel singleton() {
        if (sInstance == null) {
            throw new RuntimeException("BoostChannel not register yet");
        }

        return sInstance;
    }

    public static void addActionAfterRegistered(ActionAfterRegistered action) {
        if(action == null) return;

        if(sInstance == null) {
            sActions.add(action);
        }else{
            action.onChannelRegistered(sInstance);
        }
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        sInstance = new BoostChannel(registrar);

        for(ActionAfterRegistered a : sActions) {
            a.onChannelRegistered(sInstance);
        }

        if(FlutterBoost.sInstance != null) {
            final IStateListener stateListener = FlutterBoost.sInstance.mStateListener;
            if (stateListener != null) {
                stateListener.onChannelRegistered(registrar, sInstance);
            }
        }

        sActions.clear();
    }

    private BoostChannel(PluginRegistry.Registrar registrar){
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

                    if(listeners != null) {
                        for(Object o:listeners) {
                            ((EventListener)o).onEvent(name,args);
                        }
                    }
                }else{
                    Object[] handlers;
                    synchronized (mMethodCallHandlers) {
                        handlers = mMethodCallHandlers.toArray();
                    }

                    for(Object o:handlers) {
                        ((MethodChannel.MethodCallHandler)o).onMethodCall(methodCall,result);
                    }
                }
            }
        });
    }

    public void invokeMethodUnsafe(final String name,Serializable args){
        invokeMethod(name, args, new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object o) {
                //every thing ok...
            }

            @Override
            public void error(String s, @Nullable String s1, @Nullable Object o) {
                Debuger.log("invoke method "+name+" error:"+s+" | "+s1);
            }

            @Override
            public void notImplemented() {
                Debuger.log("invoke method "+name+" notImplemented");
            }
        });
    }

    public void invokeMethod(final String name,Serializable args){
        invokeMethod(name, args, new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object o) {
                //every thing ok...
            }

            @Override
            public void error(String s, @Nullable String s1, @Nullable Object o) {
                Debuger.exception("invoke method "+name+" error:"+s+" | "+s1);
            }

            @Override
            public void notImplemented() {
                Debuger.exception("invoke method "+name+" notImplemented");
            }
        });
    }

    public void invokeMethod(final String name,Serializable args,MethodChannel.Result result){
        if("__event__".equals(name)) {
            Debuger.exception("method name should not be __event__");
        }

        mMethodChannel.invokeMethod(name, args, result);
    }

    public void addMethodCallHandler(MethodChannel.MethodCallHandler handler) {
        synchronized (mMethodCallHandlers){
            mMethodCallHandlers.add(handler);
        }
    }

    public void removeMethodCallHandler(MethodChannel.MethodCallHandler handler) {
        synchronized (mMethodCallHandlers) {
            mMethodCallHandlers.remove(handler);
        }
    }

    public void addEventListener(String name, EventListener listener) {
        synchronized (mEventListeners){
            Set<EventListener> set = mEventListeners.get(name);
            if(set == null) {
                set = new HashSet<>();
            }
            set.add(listener);
            mEventListeners.put(name,set);
        }
    }

    public void removeEventListener(EventListener listener) {
        synchronized (mEventListeners) {
            for(Set<EventListener> set:mEventListeners.values()) {
                set.remove(listener);
            }
        }
    }

    public void sendEvent(String name,Map args){
        Map event = new HashMap();
        event.put("name",name);
        event.put("arguments",args);
        mMethodChannel.invokeMethod("__event__",event);
    }

    public interface EventListener {
        void onEvent(String name, Map args);
    }

    public interface ActionAfterRegistered {
        void onChannelRegistered(BoostChannel channel);
    }
}
