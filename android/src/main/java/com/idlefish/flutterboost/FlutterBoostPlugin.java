package com.idlefish.flutterboost;

import android.util.Log;

import com.idlefish.flutterboost.containers.FlutterViewContainer;
import com.idlefish.flutterboost.containers.FlutterViewContainerObserver;

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
            ContainerShadowNode node = allContainers.get(uniqueId);
            if (node != null) {
                if (node.container() != null) {
                    node.container().finishContainer((Map<String, Object>) (Object)params.getArguments());
                }
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

    private final Map<String, ContainerShadowNode> allContainers = new LinkedHashMap<>();
    private ContainerShadowNode getCurrentShadowNode() {
        if (allContainers.size() > 0) {
            LinkedList<String> listKeys = new LinkedList<String>(allContainers.keySet());
            return allContainers.get(listKeys.getLast());
        }
        return null;
    }

    public FlutterViewContainer findContainerById(String uniqueId) {
        if (allContainers.containsKey(uniqueId)) {
            return allContainers.get(uniqueId).container();
        }
        return null;
    }

    public FlutterViewContainer getTopContainer() {
        ContainerShadowNode top = getCurrentShadowNode();
        return top != null ? top.container() : null;
    }

    public boolean isTopContainer(String uniqueId) {
        FlutterViewContainer top = getTopContainer();
        if (top != null && top.getUniqueId() == uniqueId) {
            return true;
        }
        return false;
    }

    public void reorderContainer(String uniqueId, ContainerShadowNode container) {
        if (uniqueId == null || container == null) return;
        if (allContainers.containsKey(uniqueId)) {
            allContainers.remove(uniqueId);
        }
        allContainers.put(uniqueId, container);
    }

    public void removeContainer(String uniqueId) {
        if (uniqueId == null) return;
        allContainers.remove(uniqueId);
    }

    public LinkedList<String> getContainers() {
        return new LinkedList<String>(allContainers.keySet());
    }

    public static class ContainerShadowNode implements FlutterViewContainerObserver {
        private WeakReference<FlutterViewContainer> container;
        private FlutterBoostPlugin plugin;

        public static ContainerShadowNode create(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            return new ContainerShadowNode(container, plugin);
        }

        private ContainerShadowNode(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            assert container != null;
            this.container = new WeakReference<>(container);
            this.plugin = plugin;
        }

        public FlutterViewContainer container() {
            return container.get();
        }

        public String getUniqueId() {
            if (container() != null) {
                return container().getUniqueId();
            }
            return null;
        }

        public String getUrl() {
            if (container() != null) {
                return container().getUrl();
            }
            return null;
        }

        public Map<String, Object> getUrlParams() {
            if (container() != null) {
                return container().getUrlParams();
            }
            return null;
        }

        @Override
        public void onCreateView() {
            Log.v(TAG, "#onCreateView: " + getUniqueId() + ", " + plugin.getContainers());
        }

        @Override
        public void onAppear() {
            plugin.reorderContainer(getUniqueId(), this);
            plugin.pushRoute(getUniqueId(), getUrl(), getUrlParams(), null);

            plugin.onContainerShow(getUniqueId());
            Log.v(TAG, "#onAppear: " + getUniqueId() + ", " + plugin.getContainers());
        }

        @Override
        public void onDisappear() {
            plugin.onContainerHide(getUniqueId());
            Log.v(TAG, "#onDisappear: " + getUniqueId() + ", " + plugin.getContainers());
        }

        @Override
        public void onDestroyView() {
            plugin.removeRoute(getUniqueId(), null);
            plugin.removeContainer(getUniqueId());
            Log.v(TAG, "#onDestroyView: " + getUniqueId() + ", " + plugin.getContainers());
        }
    }
}
