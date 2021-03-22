package com.idlefish.flutterboost;

import android.util.Log;

import com.idlefish.flutterboost.containers.FlutterViewContainer;
import com.idlefish.flutterboost.containers.FlutterViewContainerObserver;
import com.idlefish.flutterboost.containers.InitiatorLocation;

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

    public enum BackForeGroundEvent {
        NONE,
        FOREGROUND,
        BACKGROUND,
    }

    public void onForeground() {
        ContainerShadowNode node = getCurrentShadowNode();
        if (node != null) {
            node.setBackForeGroundEvent(BackForeGroundEvent.FOREGROUND);
        }

        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            channel.onForeground(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onForeground: " + channel);
    }

    public void onBackground() {
        ContainerShadowNode node = getCurrentShadowNode();
        if (node != null) {
            node.setBackForeGroundEvent(BackForeGroundEvent.BACKGROUND);
        }

        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            channel.onBackground(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onBackground: " + channel);
    }

    public void onNativeViewShow() {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            channel.onNativeViewShow(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onNativeViewShow: " + channel);
    }

    public void onNativeViewHide() {
        if (channel != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            channel.onNativeViewHide(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onNativeViewHide: " + channel);
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
        private BackForeGroundEvent event;

        public static ContainerShadowNode create(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            return new ContainerShadowNode(container, plugin);
        }

        private ContainerShadowNode(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            assert container != null;
            this.container = new WeakReference<>(container);
            this.plugin = plugin;
            setBackForeGroundEvent(BackForeGroundEvent.NONE);
        }

        private boolean isCurrentTopContainer() {
            assert getUniqueId() != null;
            FlutterViewContainer top = plugin.getTopContainer();
            if (top != null && top.getUniqueId() == getUniqueId()) {
                return true;
            }
            return false;
        }

        public FlutterViewContainer container() {
            return container.get();
        }
        public void setBackForeGroundEvent(BackForeGroundEvent event) {
            this.event = event;
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
        public void onAppear(InitiatorLocation location) {
            if (isCurrentTopContainer() &&
                    InitiatorLocation.SwitchTabs == location &&
                    BackForeGroundEvent.FOREGROUND != event) {
                // The native view was popped
                plugin.onNativeViewHide();
            }

            setBackForeGroundEvent(BackForeGroundEvent.NONE);
            plugin.reorderContainer(getUniqueId(), this);
            plugin.pushRoute(getUniqueId(), getUrl(), getUrlParams(), null);
            Log.v(TAG, "#onAppear: " + location + ", " + getUniqueId() + ", " + plugin.getContainers());
        }

        @Override
        public void onDisappear(InitiatorLocation location) {
            if (isCurrentTopContainer() &&
                    // InitiatorLocation.SwitchTabs == location &&
                    BackForeGroundEvent.BACKGROUND != event) {
                // The native view was pushed
                plugin.onNativeViewShow();
            }

            setBackForeGroundEvent(BackForeGroundEvent.NONE);
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
