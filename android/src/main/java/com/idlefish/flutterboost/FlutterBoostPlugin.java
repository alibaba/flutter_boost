package com.idlefish.flutterboost;

import android.util.Log;

import com.idlefish.flutterboost.containers.FlutterContainerManager;
import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class FlutterBoostPlugin implements FlutterPlugin, Messages.NativeRouterApi {
    private static final String TAG = FlutterBoostPlugin.class.getSimpleName();
    private Messages.FlutterRouterApi channel;
    private FlutterBoostDelegate delegate;
    private Messages.StackInfo dartStack;

    public void setDelegate(FlutterBoostDelegate delegate) {
        this.delegate = delegate;
    }

    public FlutterBoostDelegate getDelegate() {
        return delegate ;
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        Messages.NativeRouterApi.setup(binding.getBinaryMessenger(), this);
        channel = new Messages.FlutterRouterApi(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        channel = null;
    }

    @Override
    public void pushNativeRoute(Messages.CommonParams params) {
        if (delegate != null) {
            delegate.pushNativeRoute(params.getPageName(), (Map<String, Object>) (Object)params.getArguments());
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public void pushFlutterRoute(Messages.CommonParams params) {
        if (delegate != null) {
            delegate.pushFlutterRoute(params.getPageName(), params.getUniqueId(), (Map<String, Object>) (Object)params.getArguments());
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public void popRoute(Messages.CommonParams params) {
        String uniqueId = params.getUniqueId();
        if (uniqueId != null) {
            FlutterViewContainer container = FlutterContainerManager.instance().findContainerById(uniqueId);
            if (container != null) {
                container.finishContainer((Map<String, Object>) (Object)params.getArguments());
            }
        } else {
            throw new RuntimeException("Oops!! The unique id is null!");
        }
    }

    @Override
    public Messages.StackInfo getStackFromHost() {
        if (dartStack == null) {
            return Messages.StackInfo.fromMap(new HashMap());
        }
        Log.v(TAG, "#getStackFromHost: " + dartStack);
        return dartStack;
    }

    @Override
    public void saveStackToHost(Messages.StackInfo arg) {
        dartStack = arg;
        Log.v(TAG, "#saveStackToHost: " + dartStack);
    }

    public interface Reply<T> {
        void reply(T reply);
    }

    public void pushRoute(String uniqueId, String pageName, Map<String, Object> arguments,
                          final Reply<Void> callback) {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setUniqueId(uniqueId);
            params.setPageName(pageName);
            params.setArguments((Map<Object, Object>)(Object) arguments);
            channel.pushRoute(params, reply -> {
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void popRoute(String uniqueId,final Reply<Void> callback) {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setUniqueId(uniqueId);
            channel.popRoute(params,reply -> {
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void removeRoute(String uniqueId, final Reply<Void> callback) {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setUniqueId(uniqueId);
            channel.removeRoute(params,reply -> {
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onNativeResult(String name, Map<String, Object> result, final Reply<Void> callback) {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setPageName(name);
            params.setArguments((Map<Object, Object>)(Object) result);
            channel.onNativeResult(params,reply -> {
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onForeground() {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            channel.onForeground(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onForeground: " + channel);
    }

    public void onBackground() {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            channel.onBackground(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onBackground: " + channel);
    }

    public void onContainerShow(String uniqueId) {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setUniqueId(uniqueId);
            channel.onContainerShow(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onContainerShow: " + channel);
    }

    public void onContainerHide(String uniqueId) {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setUniqueId(uniqueId);
            channel.onContainerHide(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onContainerHide: " + channel);
    }

    public void onContainerCreated(FlutterViewContainer container) {
        Log.v(TAG, "#onContainerCreated: " + container.getUniqueId());
    }

    public void onContainerAppeared(FlutterViewContainer container) {
        String uniqueId = container.getUniqueId();
        FlutterContainerManager.instance().reorderContainer(uniqueId, container);
        pushRoute(uniqueId, container.getUrl(), container.getUrlParams(), null);

        onContainerShow(uniqueId);
        Log.v(TAG, "#onContainerAppeared: " + uniqueId + ", " + FlutterContainerManager.instance().getContainers());
    }

    public void onContainerDisappeared(FlutterViewContainer container) {
        String uniqueId = container.getUniqueId();
        onContainerHide(uniqueId);
        Log.v(TAG, "#onContainerDisappeared: " + uniqueId + ", " +  FlutterContainerManager.instance().getContainers());
    }

    public void onContainerDestroyed(FlutterViewContainer container) {
        String uniqueId = container.getUniqueId();
        removeRoute(uniqueId, null);
        FlutterContainerManager.instance().removeContainer(uniqueId);
        Log.v(TAG, "#onContainerDestroyed: " + uniqueId + ", " +  FlutterContainerManager.instance().getContainers());
    }
}
