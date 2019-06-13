

import 'package:flutter/services.dart';

typedef void VoidCallback();
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

  VoidCallback addEventListener(String name , EventListener listener){
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
      return Future<dynamic>();
    }

    String name = call.arguments["name"];
    String arg = call.arguments["arguments"];
    List<EventListener> list = _lists[call.method];
    for(EventListener l in list){
      l(name,arg);
    }

    return Future<dynamic>();
  }

}