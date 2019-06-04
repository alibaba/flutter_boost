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

import com.taobao.idlefish.flutterboost.NavigationService.NavigationService;

import java.util.HashMap;
import java.util.Map;

import fleamarket.taobao.com.xservicekit.handler.MessageResult;

class PageResultMediator {

    private Map<String,PageResultHandler> _handlers = new HashMap<>();

    void onPageResult(String key , Map resultData,Map params){
        if(key == null) return;

        if(_handlers.containsKey(key)){
            _handlers.get(key).onResult(key,resultData);
            _handlers.remove(key);
        }else{

            if(params == null || !params.containsKey("forward")){
                if(params == null){
                    params = new HashMap();
                }

                params.put("forward",1);
                NavigationService.onNativePageResult(new MessageResult<Boolean>() {
                    @Override
                    public void success(Boolean var1) {

                    }

                    @Override
                    public void error(String var1, String var2, Object var3) {

                    }

                    @Override
                    public void notImplemented() {

                    }
                },key,key,resultData,params);
            }else{
                int forward = (Integer) params.get("forward");
                params.put("forward",++forward);
                if(forward <= 2){
                    NavigationService.onNativePageResult(new MessageResult<Boolean>() {
                        @Override
                        public void success(Boolean var1) {

                        }

                        @Override
                        public void error(String var1, String var2, Object var3) {

                        }

                        @Override
                        public void notImplemented() {

                        }
                    },key,key,resultData,params);
                }
            }
        }
    }

    void setHandler(String key, PageResultHandler handler){
        if(key == null || handler == null) return;
        _handlers.put(key,handler);
    }

    void removeHandler(String key){
        if(key == null) return;;
        _handlers.remove(key);
    }

}
