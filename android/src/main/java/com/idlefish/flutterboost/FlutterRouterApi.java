package com.idlefish.flutterboost;

import android.text.format.DateUtils;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;

public class FlutterRouterApi {

    private BinaryMessenger binaryMessenger;

    public void setBinaryMessenger(BinaryMessenger binaryMessenger) {
        this.binaryMessenger = binaryMessenger;
    }

    public static void setup(BinaryMessenger binaryMessenger) {
        FlutterBoost.instance().getFlutterRouterApi().setBinaryMessenger(binaryMessenger);
    }

    public interface Reply<T> {
        void reply(T reply);
    }

    public void pushRoute(String pageName, String uniqueId, Map arguments, final Reply<Void> callback) {
        final Map<String, Object> mapMessage = new HashMap<String, Object>();
        mapMessage.put("pageName", pageName);
        mapMessage.put("uniqueId", uniqueId);
        mapMessage.put("arguments", arguments);

        BasicMessageChannel<Object> channel =
                new BasicMessageChannel<Object>(binaryMessenger, RouterApiChannel.FlutterRouterApi_PushRoute, new StandardMessageCodec());

        channel.send(mapMessage, new BasicMessageChannel.Reply<Object>() {
            public void reply(Object channelReply) {
                if (callback != null) {
                    callback.reply(null);
                }
            }
        });
    }

    public String generateUniqueId(String pageName) {
        Date date = new Date();
        return "__container_uniqueId_key__" + date.getTime()+"_"+ pageName;
    }

    /**
     * @param uniqueId
     * @param pageName
     * @param arguments
     * @param callback
     */
    public void pushOrShowRoute(String uniqueId, String pageName, Map arguments, boolean openContainer, final Reply<Void> callback) {
        final Map<String, Object> mapMessage = new HashMap<String, Object>();
        mapMessage.put("uniqueId", uniqueId);
        mapMessage.put("arguments", arguments);
        mapMessage.put("pageName", pageName);
        mapMessage.put("openContainer", openContainer);
        BasicMessageChannel<Object> channel =
                new BasicMessageChannel<Object>(binaryMessenger, RouterApiChannel.FlutterRouterApi_PushOrShowRoute, new StandardMessageCodec());

        channel.send(mapMessage, new BasicMessageChannel.Reply<Object>() {
            public void reply(Object channelReply) {
                if (callback != null) {
                    callback.reply(null);
                }
            }
        });
    }

    /**
     * groupName,保持唯一，
     *  用来当前页面关闭后，和它同 groupname 的tab 都移除。
     *
     * @param uniqueId
     * @param pageName
     * @param arguments
     */
    public void showRoute(String groupName, String uniqueId, String pageName, Map arguments) {
        final Map<String, Object> mapMessage = new HashMap<String, Object>();
        mapMessage.put("groupName", groupName);
        mapMessage.put("uniqueId", uniqueId);
        mapMessage.put("arguments", arguments);
        mapMessage.put("pageName", pageName);
        BasicMessageChannel<Object> channel =
                new BasicMessageChannel<Object>(binaryMessenger, RouterApiChannel.FlutterRouterApi_ShowRoute, new StandardMessageCodec());

        channel.send(mapMessage, new BasicMessageChannel.Reply<Object>() {
            public void reply(Object channelReply) {
//                if (callback != null) {
//                    callback.reply(null);
//                }
            }
        });
    }
    public void popRoute(String uniqueId,final Reply<Void> callback) {
        final Map<String, Object> mapMessage = new HashMap<String, Object>();
        mapMessage.put("uniqueId", uniqueId);
        BasicMessageChannel<Object> channel =
                new BasicMessageChannel<Object>(binaryMessenger, RouterApiChannel.FlutterRouterApi_PopRoute, new StandardMessageCodec());
        channel.send(mapMessage, new BasicMessageChannel.Reply<Object>() {
            public void reply(Object channelReply) {
                callback.reply(null);
            }
        });
    }

}

