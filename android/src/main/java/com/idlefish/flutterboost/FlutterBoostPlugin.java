package com.idlefish.flutterboost;

import java.util.Date;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class FlutterBoostPlugin implements FlutterPlugin, Messages.NativeRouterApi {
    private Messages.FlutterRouterApi mApi;
    private NativeRouterApi mDelegate;

    public void setDelegate(NativeRouterApi delegate) {
        this.mDelegate = delegate;
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        Messages.NativeRouterApi.setup(binding.getBinaryMessenger(), this);
        mApi = new Messages.FlutterRouterApi(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        mApi = null;
    }

    @Override
    public void pushNativeRoute(Messages.CommonParams params) {
        if (mDelegate != null) {
            mDelegate.pushNativeRoute(params.getPageName(), params.getArguments());
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public void pushFlutterRoute(Messages.CommonParams params) {
        if (mDelegate != null) {
            mDelegate.pushFlutterRoute(params.getPageName(), params.getUniqueId(), params.getArguments());
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public void popRoute(Messages.CommonParams params) {
        if (mDelegate != null) {
            mDelegate.popRoute(params.getPageName(), params.getUniqueId());
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    public interface Reply<T> {
        void reply(T reply);
    }

    public void pushRoute(String pageName, HashMap<String, Object> arguments, final Reply<Void> callback) {
        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setPageName(pageName);
            params.setArguments(arguments);
            mApi.pushRoute(params, reply -> {
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    /**
     * groupName,保持唯一，
     *  用来当前页面关闭后，和它同 groupname 的tab 都移除。
     *
     * @param uniqueId
     * @param pageName
     * @param arguments
     */
    public void showTabRoute(String groupName, String uniqueId, String pageName, HashMap<String, Object> arguments) {
        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setPageName(pageName);
            params.setUniqueId(uniqueId);
            params.setGroupName(groupName);
            params.setArguments(arguments);
            mApi.showTabRoute(params, reply -> {
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void popRoute(String uniqueId,final Reply<Void> callback) {
        if (mApi != null) {
            mApi.popRoute(reply -> {
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public String generateUniqueId(String pageName) {
        Date date = new Date();
        return "__container_uniqueId_key__" + date.getTime()+"_"+ pageName;
    }
}