package com.idlefish.flutterboost;


import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;

class RouterApiChannel {

    public final static String NativeRouterApi_pushNativeRoute = "NativeRouterApi.pushNativeRoute";
    public final static String NativeRouterApi_PushFlutterRoute = "NativeRouterApi.pushFlutterRoute";
    public final static String NativeRouterApi_PopRoute = "NativeRouterApi.popRoute";
    public final static String FlutterRouterApi_PushRoute = "FlutterRouterApi.pushRoute";
    public final static String FlutterRouterApi_PopRoute = "FlutterRouterApi.popRoute";
//    public final static String FlutterRouterApi_PushOrShowRoute = "FlutterRouterApi.pushOrShowRoute";
    public final static String FlutterRouterApi_ShowTabRoute = "FlutterRouterApi.showTabRoute";


    public static void setup(BinaryMessenger binaryMessenger) {
        {
            BasicMessageChannel<Object> channel =
                    new BasicMessageChannel<Object>(binaryMessenger, NativeRouterApi_pushNativeRoute, new StandardMessageCodec());

            channel.setMessageHandler(new BasicMessageChannel.MessageHandler<Object>() {
                public void onMessage(Object message, BasicMessageChannel.Reply<Object> reply) {
                    Map<String, Object> msg = (HashMap) message;
                    String pageName = (String) msg.get("pageName");
                    Map arguments = (Map) msg.get("arguments");
                    HashMap<String, HashMap> wrapped = new HashMap<String, HashMap>();
                    try {
                        FlutterBoost.instance().getNativeRouterApi().pushNativeRoute(pageName, arguments);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
//                            wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                }
            });
        }
        {
            BasicMessageChannel<Object> channel =
                    new BasicMessageChannel<Object>(binaryMessenger, NativeRouterApi_PushFlutterRoute, new StandardMessageCodec());

            channel.setMessageHandler(new BasicMessageChannel.MessageHandler<Object>() {
                public void onMessage(Object message, BasicMessageChannel.Reply<Object> reply) {
                    Map<String, Object> msg = (HashMap) message;
                    String pageName = (String) msg.get("pageName");
                    String uniqueId = (String) msg.get("uniqueId");
                    Map arguments = (Map) msg.get("arguments");
                    HashMap<String, HashMap> wrapped = new HashMap<String, HashMap>();
                    try {
                        FlutterBoost.instance().getNativeRouterApi().pushFlutterRoute(pageName,uniqueId,  arguments);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
//                            wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                }
            });

        }
        {
            BasicMessageChannel<Object> channel =
                    new BasicMessageChannel<Object>(binaryMessenger, NativeRouterApi_PopRoute, new StandardMessageCodec());
            channel.setMessageHandler(new BasicMessageChannel.MessageHandler<Object>() {
                public void onMessage(Object message, BasicMessageChannel.Reply<Object> reply) {
                    Map<String, Object> msg = (HashMap) message;
                    String pageName = (String) msg.get("pageName");
                    String uniqueId = (String) msg.get("uniqueId");

                    HashMap<String, HashMap> wrapped = new HashMap<String, HashMap>();
                    try {
                        FlutterBoost.instance().getNativeRouterApi().popRoute(pageName, uniqueId);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
//                            wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                }
            });

        }
    }

}
