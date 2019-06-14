package com.taobao.idlefish.flutterboost.messageing.base;

import android.support.annotation.Nullable;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class Broadcastor{

    private MethodChannel channel = null;
    private Map<String,List<EvenListener>> lists = new HashMap<>();

    public Broadcastor(MethodChannel channel) {
        this.channel = channel;
    }

    public void sendEvent(String name , Map arguments) {

        if (name == null) {
            return;
        }

        Map msg = new HashMap();
        msg.put("name",name);
        if(arguments != null){
            msg.put("arguments",arguments);
        }

        channel.invokeMethod("__event__", msg, new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object o) {
            }

            @Override
            public void error(String s, @Nullable String s1, @Nullable Object o) {
            }

            @Override
            public void notImplemented() {
            }
        });
    }

    public void dispatch(String name, Map arguments) {

        if(name == null || arguments == null){
            return ;
        }

        List<EvenListener> list = lists.get(name);
        if(list == null){
            return ;
        }

        String eventName = (String)arguments.get("name");
        Map eventArguments = (Map)arguments.get("arguments");

        for(EvenListener l : list){
            l.onEvent(eventName,eventArguments);
        }

        return ;
    }

    public void addEventListener(String name , EvenListener listener){
        if(listener == null || name == null){
            return ;
        }

        List<EvenListener> list = lists.get(name);
        if (list == null){
            list = new LinkedList<>();
            lists.put(name,list);
        }

        list.add(listener);
    }

    public void removeEventListener(String name ,EvenListener listener){
        if(listener == null || name == null){
            return ;
        }

        List<EvenListener> list = lists.get(name);
        if(list != null){
            list.remove(listener);
        }
    }


}
