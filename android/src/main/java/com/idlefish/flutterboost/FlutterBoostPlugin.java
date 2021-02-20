package com.idlefish.flutterboost;

import android.util.Log;

import com.idlefish.flutterboost.containers.InitiatorLocation;
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

    private Messages.FlutterRouterApi mApi;
    private FlutterBoostDelegate mDelegate;



    public void setDelegate(FlutterBoostDelegate delegate) {
        this.mDelegate = delegate;
    }
    public FlutterBoostDelegate getDelegate() {
        return this.mDelegate ;
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
        String uniqueId = params.getUniqueId();
        if (uniqueId != null) {
            ContainerShadowNode node = mAllContainers.get(uniqueId);
            if (node != null) {
                if (node.container() != null) {
                    node.container().finishContainer(params.getArguments());
                }
            }
        } else {
            throw new RuntimeException("Oops!! The unique id is null!");
        }
    }

    public interface Reply<T> {
        void reply(T reply);
    }

    public void pushRoute(String uniqueId, String pageName, HashMap<String, String> arguments,
                          final Reply<Void> callback) {
        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setUniqueId(uniqueId);
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

    public void popRoute(String uniqueId,final Reply<Void> callback) {
        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setUniqueId(uniqueId);
            mApi.popRoute(params,reply -> {
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void removeRoute(String uniqueId,final Reply<Void> callback) {
        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setUniqueId(uniqueId);
            mApi.removeRoute(params,reply -> {
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
        ContainerShadowNode node = getStackTop();
        if (node != null) {
            node.setBackForeGroundEvent(BackForeGroundEvent.FOREGROUND);
        }

        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            mApi.onForeground(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onForeground: " + mApi);
    }

    public void onBackground() {
        ContainerShadowNode node = getStackTop();
        if (node != null) {
            node.setBackForeGroundEvent(BackForeGroundEvent.BACKGROUND);
        }

        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            mApi.onBackground(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onBackground: " + mApi);
    }

    public void onNativeViewShow() {
        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            mApi.onNativeViewShow(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onNativeViewShow: " + mApi);
    }

    public void onNativeViewHide() {
        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            mApi.onNativeViewHide(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onNativeViewHide: " + mApi);
    }

    private final Map<String, ContainerShadowNode> mAllContainers = new LinkedHashMap<>();
    private ContainerShadowNode getStackTop() {
        if (mAllContainers.size() > 0) {
            LinkedList<String> listKeys = new LinkedList<String>(mAllContainers.keySet());
            return mAllContainers.get(listKeys.getLast());
        }
        return null;
    }

    public FlutterViewContainer findContainerById(String uniqueId) {
        if (mAllContainers.containsKey(uniqueId)) {
            return mAllContainers.get(uniqueId).container();
        }
        return null;
    }

    public FlutterViewContainer getTopContainer() {
        ContainerShadowNode top = getStackTop();
        return top != null ? top.container() : null;
    }

    public void reorderContainer(String uniqueId, ContainerShadowNode container) {
        if (uniqueId == null || container == null) return;
        if (mAllContainers.containsKey(uniqueId)) {
            mAllContainers.remove(uniqueId);
        }
        mAllContainers.put(uniqueId, container);
    }

    public void removeContainer(String uniqueId) {
        if (uniqueId == null) return;
        mAllContainers.remove(uniqueId);
    }

    public LinkedList<String> getContainers() {
        return new LinkedList<String>(mAllContainers.keySet());
    }

    public static class ContainerShadowNode implements FlutterViewContainerObserver {
        private WeakReference<FlutterViewContainer> mContainer;
        private FlutterBoostPlugin mPlugin;
        private BackForeGroundEvent mEvent;

        public static ContainerShadowNode create(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            return new ContainerShadowNode(container, plugin);
        }

        private ContainerShadowNode(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            assert container != null;
            mContainer = new WeakReference<>(container);
            mPlugin = plugin;
            setBackForeGroundEvent(BackForeGroundEvent.NONE);
        }

        private boolean isCurrentTopContainer() {
            assert getUniqueId() != null;
            FlutterViewContainer top = mPlugin.getTopContainer();
            if (top != null && top.getUniqueId() == getUniqueId()) {
                return true;
            }
            return false;
        }

        public FlutterViewContainer container() {
            return mContainer.get();
        }
        public void setBackForeGroundEvent(BackForeGroundEvent event) {
            mEvent = event;
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

        public HashMap<String, String> getUrlParams() {
            if (container() != null) {
                return container().getUrlParams();
            }
            return null;
        }

        @Override
        public void onCreateView() {
            Log.v(TAG, "#onCreateView: " + getUniqueId() + ", " + mPlugin.getContainers());
        }

        @Override
        public void onAppear(InitiatorLocation location) {
            if (isCurrentTopContainer() &&
                    InitiatorLocation.Others == location &&
                    BackForeGroundEvent.FOREGROUND != mEvent) {
                // The native view was popped
                mPlugin.onNativeViewHide();
            }

            setBackForeGroundEvent(BackForeGroundEvent.NONE);
            mPlugin.reorderContainer(getUniqueId(), this);
            mPlugin.pushRoute(getUniqueId(), getUrl(), getUrlParams(), null);
            Log.v(TAG, "#onAppear: " + getUniqueId() + ", " + mPlugin.getContainers());
        }

        @Override
        public void onDisappear(InitiatorLocation location) {
            if (isCurrentTopContainer() &&
                    InitiatorLocation.Others == location &&
                    BackForeGroundEvent.BACKGROUND != mEvent) {
                // The native view was pushed
                mPlugin.onNativeViewShow();
            }

            setBackForeGroundEvent(BackForeGroundEvent.NONE);
            Log.v(TAG, "#onDisappear: " + getUniqueId() + ", " + mPlugin.getContainers());
        }

        @Override
        public void onDestroyView() {
            mPlugin.removeRoute(getUniqueId(), null);
            mPlugin.removeContainer(getUniqueId());
            Log.v(TAG, "#onDestroyView: " + getUniqueId() + ", " + mPlugin.getContainers());
        }
    }
}
