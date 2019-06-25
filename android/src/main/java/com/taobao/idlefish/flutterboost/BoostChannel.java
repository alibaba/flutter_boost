package com.taobao.idlefish.flutterboost;

import android.support.annotation.Nullable;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class BoostChannel {

    private final MethodChannel mMethodChannel;
    private final EventChannel mEventChannel;
    private final Set<MethodChannel.MethodCallHandler> mMethodCallHandlers = new HashSet<>();

    private EventChannel.EventSink mEventSink;

    BoostChannel(MethodChannel methodChannel, EventChannel eventChannel){
        mMethodChannel = methodChannel;
        mEventChannel = eventChannel;

        mMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                Object[] handlers;
                synchronized (mMethodCallHandlers) {
                    handlers = mMethodCallHandlers.toArray();
                }

                for(Object o:handlers) {
                    ((MethodChannel.MethodCallHandler)o).onMethodCall(methodCall,result);
                }
            }
        });

        mEventChannel.setStreamHandler(new EventChannel.StreamHandler(){
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                mEventSink = eventSink;
            }

            @Override
            public void onCancel(Object o) {

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

    public void sendEvent(Serializable event){
        if(mEventSink == null) {
            Debuger.exception("event stream not listen yet!");
        }

        mEventSink.success(event);
    }
}
