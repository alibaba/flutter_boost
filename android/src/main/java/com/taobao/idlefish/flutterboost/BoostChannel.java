package com.taobao.idlefish.flutterboost;

import android.support.annotation.Nullable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class BoostChannel {

    private final MethodChannel mMethodChannel;
    private final Set<MethodChannel.MethodCallHandler> mMethodCallHandlers = new HashSet<>();
    private final Map<String,Set<EventListener>> mEventListeners = new HashMap<>();

    BoostChannel(MethodChannel methodChannel){
        mMethodChannel = methodChannel;

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
}
