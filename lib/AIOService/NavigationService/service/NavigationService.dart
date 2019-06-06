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
 import 'package:xservice_kit/foundation_ext/foundation_ext.dart';
 import 'package:xservice_kit/ServiceTemplate.dart';
 import 'package:xservice_kit/ServiceGateway.dart';
 
 class NavigationService {
 
 static final ServiceTemplate _service  =
 new ServiceTemplate("NavigationService");
 
 static void regsiter() {
   ServiceGateway.sharedInstance().registerService(_service);
 }
 //List event from event channel.
 static int listenEvent(void onData(dynamic event)) {
     return _service.listenEvent(onData);
 }
 //Cancel event for subscription with ID.
 static void cancelEventForSubscription(int subID) {
      _service.cancelEventForSubscription(subID);
 }
 static Future<bool> onShownContainerChanged(String newName,String oldName,Map params) {
     Map<String,dynamic> properties = new Map<String,dynamic>();
     properties["newName"]=newName;
     properties["oldName"]=oldName;
     properties["params"]=params;
   return _service.methodChannel().invokeMethod('onShownContainerChanged',properties).then<bool>((value){
       return BOOL(value);
     });
 }
 static Future<bool> onFlutterPageResult(String uniqueId,String key,Map resultData,Map params) {
     Map<String,dynamic> properties = new Map<String,dynamic>();
     properties["uniqueId"]=uniqueId;
     properties["key"]=key;
     properties["resultData"]=resultData;
     properties["params"]=params;
   return _service.methodChannel().invokeMethod('onFlutterPageResult',properties).then<bool>((value){
       return BOOL(value);
     });
 }
 static Future<Map> pageOnStart(Map params) async {
   Map<String,dynamic> properties = new Map<String,dynamic>();
   properties["params"]=params;
   try {
     return await _service.methodChannel().invokeMethod('pageOnStart',properties).then<Map>((value){
       return value as Map;
     });
   } catch (e) {
     print('Page on start exception');
     return Future<Map>.value({});
 }
 }
 static Future<bool> openPage(String pageName,Map params,bool animated) {
     Map<String,dynamic> properties = new Map<String,dynamic>();
     properties["pageName"]=pageName;
     properties["params"]=params;
     properties["animated"]=animated;
   return _service.methodChannel().invokeMethod('openPage',properties).then<bool>((value){
       return BOOL(value);
     });
 }
 static Future<bool> closePage(String uniqueId,String pageName,Map params,bool animated) {
     Map<String,dynamic> properties = new Map<String,dynamic>();
     properties["uniqueId"]=uniqueId;
     properties["pageName"]=pageName;
     properties["params"]=params;
     properties["animated"]=animated;
   return _service.methodChannel().invokeMethod('closePage',properties).then<bool>((value){
       return BOOL(value);
     });
 }
 /// 通知原生模块flutter是否可以pop
 static void flutterCanPop(bool canPop) {
   Map<String,dynamic> properties = new Map<String,dynamic>();
   properties["canPop"]=canPop;
   _service.methodChannel().invokeMethod('flutterCanPop',properties);
 }
 }