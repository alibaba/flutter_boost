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

 package com.taobao.idlefish.flutterboost.NavigationService;
 
 import com.taobao.idlefish.flutterboost.FlutterBoostPlugin;

 import java.util.ArrayList;
 import java.util.List;
 import java.util.Map;
 import fleamarket.taobao.com.xservicekit.handler.MessageHandler;
 import fleamarket.taobao.com.xservicekit.handler.MessageResult;
 import fleamarket.taobao.com.xservicekit.service.ServiceGateway;
 
 public class NavigationService_openPage implements MessageHandler<Boolean>{
     private Object mContext = null;
 
 
     private boolean onCall(MessageResult<Boolean> result,String pageName,Map params,Boolean animated){
         FlutterBoostPlugin.openPage(null,pageName,params,0);
         if(result != null){
             result.success(true);
         }
         return true;
      }
 
 
     //==================Do not edit code blow!==============
     @Override
     public boolean onMethodCall(String name, Map args, MessageResult<Boolean> result) {
       this.onCall(result,(String)args.get("pageName"),(Map)args.get("params"),(Boolean)args.get("animated"));
         return  true;
     }
 
     @Override
     public List<String> handleMessageNames() {
         List<String> h = new ArrayList<>();
         h.add("openPage");
         return h;
     }
     @Override
     public Object getContext() {
         return mContext;
     }
 
     @Override
     public void setContext(Object obj) {
         mContext = obj;
     }
     @Override
     public String service() {
         return "NavigationService";
     }
 
      public static void register(){
          ServiceGateway.sharedInstance().registerHandler(new NavigationService_openPage());
      }
 
 
 }