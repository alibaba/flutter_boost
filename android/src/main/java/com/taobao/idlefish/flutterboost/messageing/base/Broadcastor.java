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

        String eventName = (String)arguments.get("name");
        Map eventArguments = (Map)arguments.get("arguments");

        List<EvenListener> list = lists.get(eventName);
        if(list == null){
            return ;
        }
        for(EvenListener l : list){
            l.onEvent(eventName,eventArguments);
        }

        return;
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
