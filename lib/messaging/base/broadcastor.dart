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

import 'package:flutter/services.dart';

typedef Future<dynamic> EventListener(String name , Map arguments);

class Broadcastor{

  MethodChannel _channel;
  Map<String,List<EventListener>> _lists = Map();

  Broadcastor(MethodChannel channel){
    _channel = channel;
  }

  void sendEvent(String name , Map arguments){

    if(name == null) {
      return;
    }

    if(arguments == null){
      arguments = Map();
    }

    Map msg = Map();
    msg["name"] = name;
    msg["arguments"] = arguments;
    _channel.invokeMethod("__event__",msg);
  }

  Function addEventListener(String name , EventListener listener){
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

  Future<dynamic> handleCall(MethodCall call){
    if(!_lists.containsKey(call.method) || call.method != "__event__"){
      return Future<dynamic>((){});
    }

    String name = call.arguments["name"];
    Map arg = call.arguments["arguments"];
    List<EventListener> list = _lists[call.method];
    for(EventListener l in list){
      l(name,arg);
    }

    return Future<dynamic>((){});
  }

}