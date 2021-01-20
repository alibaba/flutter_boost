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
    private static final String TAG = "FlutterBoostPlugin";
    private Messages.FlutterRouterApi mApi;
    private FlutterBoostDelegate mDelegate;

    public void setDelegate(FlutterBoostDelegate delegate) {
        this.mDelegate = delegate;
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        Messages.NativeRouterApi.setup(binding.getBinaryMessenger(), this);
        mApi = new Messages.FlutterRouterApi(binding.getBinaryMessenger());
        FlutterBoost.instance().registerVisibilityChangedObserver(this);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        mApi = null;
        FlutterBoost.instance().unregisterVisibilityChangedObserver(this);
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
            mDelegate.pushFlutterRoute(params.getPageName(), params.getArguments());
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public void popRoute(Messages.CommonParams params) {
        String uniqueId = params.getUniqueId();
        if (uniqueId != null) {
            FlutterViewContainer container = findContainerById(uniqueId);
            if (container != null) {
                container.finishContainer(params.getArguments());
            } else {
                Log.e(TAG, "Something wrong ?! Can't find container: " + uniqueId);
            }
        } else {
            throw new RuntimeException("Oops!! The unique id is null!");
        }
    }

    public interface Reply<T> {
        void reply(T reply);
    }

    public void pushRoute(String uniqueId, String pageName, HashMap<String, String> arguments, final Reply<Void> callback) {
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

    public void onForeground() {
        android.util.Log.e("xlog", "## onForeground");
    }

    public void onBackground() {
        android.util.Log.e("xlog", "## onBackground");
    }

    private final Map<String, FlutterViewContainer> mAllContainers = new LinkedHashMap<>();

    public FlutterViewContainer findContainerById(String uniqueId) {
        if (mAllContainers.containsKey(uniqueId)) {
            return mAllContainers.get(uniqueId);
        }
        return null;
    }

    public FlutterViewContainer getTopContainer() {
        if (mAllContainers.size() > 0) {
            LinkedList<String> listKeys = new LinkedList<String>(mAllContainers.keySet());
            return mAllContainers.get(listKeys.getLast());
        }
        return null;
    }

    public void updateContainer(String uniqueId, FlutterViewContainer container) {
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

    public static class ContainerShadowNode implements FlutterViewContainerObserver {
        private WeakReference<FlutterViewContainer> mContainer;
        private FlutterBoostPlugin mPlugin;

        public static ContainerShadowNode create(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            return new ContainerShadowNode(container, plugin);
        }

        private ContainerShadowNode(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            assert container != null;
            mContainer = new WeakReference<>(container);
            mPlugin = plugin;
        }

        public FlutterViewContainer container() {
            return mContainer.get();
        }

        @Override
        public void onCreateView() {
            // todo:
            android.util.Log.e("xlog", "## FlutterViewContainerObserver#onCreateView: " + container().getUniqueId());
        }

        @Override
        public void onAppear() {
            assert container() != null;
            mPlugin.updateContainer(container().getUniqueId(), container());
            mPlugin.pushRoute(container().getUniqueId(), container().getUrl(), container().getUrlParams(),null);
            android.util.Log.e("xlog", "## FlutterViewContainerObserver#onAppear: " + container().getUniqueId());
        }

        @Override
        public void onDisappear() {
            // todo:
            android.util.Log.e("xlog", "## FlutterViewContainerObserver#onDisappear: " + container().getUniqueId());
        }

        @Override
        public void onDestroyView() {
            mPlugin.popRoute(container().getUniqueId(), null);
            mPlugin.removeContainer(container().getUniqueId());
            android.util.Log.e("xlog", "## FlutterViewContainerObserver#onDestroyView: " + container().getUniqueId());
        }
    }
}
