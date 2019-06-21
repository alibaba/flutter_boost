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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MessageDispatcherImp implements MessageDispatcher {

    private Map<String,MessageHandler> handlers = new HashMap<>();

    @Override
    public boolean dispatch(Message msg, MessageResult result) {
        if(msg == null){
            return false;
        }

        MessageHandler h = handlers.get(msg.name());

        if(h != null){
            return h.onMethodCall(msg.name(),msg.arguments(),result);
        }

        return false;
    }

    @Override
    public void addHandler(MessageHandler handler) {
        if(handler == null){
            return;
        }

        List<String> names = handler.handleMessageNames();
        for(String name : names){
            handlers.put(name,handler);
        }
    }

    @Override
    public void removeHandler(MessageHandler handler) {
        if(handler == null){
            return;
        }
        List<String> names = handler.handleMessageNames();
        for(String name : names){
            if(handler == handlers.get(name)){
                handlers.remove(name);
            }
        }
    }
}
