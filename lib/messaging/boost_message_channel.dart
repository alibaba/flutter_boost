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

import 'dart:async';
import 'package:flutter/services.dart';

typedef Future<dynamic> EventListener(String name , Map arguments);

class BoostMessageChannel {

  static MethodChannel methodChannel;

  static Map<String,List<EventListener>> _lists = Map();

  static void sendEvent(String name , Map arguments){

    if(name == null) {
      return;
    }

    if(arguments == null){
      arguments = Map();
    }

    Map msg = Map();
    msg["name"] = name;
    msg["arguments"] = arguments;
    methodChannel.invokeMethod("__event__",msg);
  }

  static Function addEventListener(String name , EventListener listener){
    if(name == null || listener == null){
      return (){};
    }

    List<EventListener> list = _lists[name];
    if(list == null){
      list = List();
      _lists[name] = list;
    }

    list.add(listener);

    return (){
      list.remove(listener);
    };
  }

  static Future<dynamic> handleEventCall(MethodCall call){
    if(call.method != "__event__"){
      return Future<dynamic>((){});
    }

    String name = call.arguments["name"];
    Map arg = call.arguments["arguments"];
    List<EventListener> list = _lists[name];
    if(list != null){
      for(EventListener l in list){
        l(name,arg);
      }
    }

    return Future<dynamic>((){});
  }



 static Future<bool> onShownContainerChanged(String newName,String oldName,Map params) {
     Map<String,dynamic> properties = new Map<String,dynamic>();
     properties["newName"]=newName;
     properties["oldName"]=oldName;
     properties["params"]=params;
   return methodChannel.invokeMethod('onShownContainerChanged',properties).then<bool>((value){
       return (value);
     });
 }
 static Future<bool> onFlutterPageResult(String uniqueId,String key,Map resultData,Map params) {
     Map<String,dynamic> properties = new Map<String,dynamic>();
     properties["uniqueId"]=uniqueId;
     properties["key"]=key;
     properties["resultData"]=resultData;
     properties["params"]=params;
   return methodChannel.invokeMethod('onFlutterPageResult',properties).then<bool>((value){
       return (value);
     });
 }
 static Future<Map> pageOnStart(Map params) async {
   Map<String,dynamic> properties = new Map<String,dynamic>();
   properties["params"]=params;
   try {
     return await methodChannel.invokeMethod('pageOnStart',properties).then<Map>((value){
       return value as Map;
     });
   } catch (e) {
     print('Page on start exception');
     return Future<Map>((){});
 }
 }

 static Future<Map<dynamic,dynamic>> openPage(String url,Map urlParams, Map exts) {
     Map<String,dynamic> properties = new Map<String,dynamic>();
     properties["url"]=url;
     properties["urlParams"]=urlParams;
     properties["exts"]=exts;
   return methodChannel.invokeMethod('openPage',properties).then<Map<dynamic,dynamic>>((value){
       return (value);
     });
 }

 static Future<bool> closePage(String uniqueId,{Map<String,dynamic> result,Map<String,dynamic> exts}) {
     Map<String,dynamic> properties = new Map<String,dynamic>();
     properties["uniqueId"]=uniqueId;
     if(result != null){
       properties["result"]=result;
     }
     if(exts != null) {
       properties["exts"] = exts;
     }
     return methodChannel.invokeMethod('closePage',properties).then<bool>((value){
       return value;
     });
 }

 }