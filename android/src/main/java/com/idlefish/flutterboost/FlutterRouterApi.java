package com.idlefish.flutterboost;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;

public  class FlutterRouterApi {

    private BinaryMessenger binaryMessenger;
    static FlutterRouterApi flutterRouterApi;

   public static FlutterRouterApi instance(){
       if(flutterRouterApi==null){
           flutterRouterApi=new FlutterRouterApi();
       }
        return  flutterRouterApi;
    }

    public  void setBinaryMessenger(BinaryMessenger binaryMessenger){
       this.binaryMessenger=binaryMessenger;
    }

    public static void setup(BinaryMessenger binaryMessenger) {
        FlutterRouterApi.instance().setBinaryMessenger(binaryMessenger);
    }

    public interface Reply<T> {
        void reply(T reply);
    }
    public void pushRoute(String pageName, String uniqueId,Map arguments, final Reply<Void> callback) {
        final Map<String , Object> mapMessage = new HashMap<String , Object>();
        mapMessage.put("pageName",pageName);
        mapMessage.put("uniqueId",uniqueId);
        mapMessage.put("arguments",arguments);

        BasicMessageChannel<Object> channel =
                new BasicMessageChannel<Object>(binaryMessenger, RouterApiChannel.FlutterRouterApi_PushRoute, new StandardMessageCodec());

        channel.send(mapMessage, new BasicMessageChannel.Reply<Object>() {
            public void reply(Object channelReply) {
                if(callback!=null){
                    callback.reply(null);
                }
            }
        });
    }
    public void popRoute(final Reply<Void> callback) {
        BasicMessageChannel<Object> channel =
                new BasicMessageChannel<Object>(binaryMessenger, RouterApiChannel.FlutterRouterApi_PopRoute, new StandardMessageCodec());
        channel.send(null, new BasicMessageChannel.Reply<Object>() {
            public void reply(Object channelReply) {
                callback.reply(null);
            }
        });
    }

}

