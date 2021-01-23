package com.idlefish.flutterboost;

import android.util.Log;

import androidx.annotation.IntDef;

import com.idlefish.flutterboost.containers.FlutterViewContainer;
import com.idlefish.flutterboost.containers.FlutterViewContainerObserver;
import com.idlefish.flutterboost.containers.ChangeReason;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
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
            ContainerShadowNode node = mAllContainers.get(uniqueId);
            if (node != null) {
                if (node.container() != null) {
                    node.container().finishContainer(params.getArguments());
                }
                node.setIsPopping();
            } else {
                Log.v(TAG, "Something wrong ?! Can't find container: " + uniqueId);
            }
        } else {
            throw new RuntimeException("Oops!! The unique id is null!");
        }
    }

    public interface Reply<T> {
        void reply(T reply);
    }

    public void pushRoute(String uniqueId, String pageName, HashMap<String, String> arguments,
                          @ChangeReason int hint, final Reply<Void> callback) {
        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            params.setUniqueId(uniqueId);
            params.setPageName(pageName);
            params.setArguments(arguments);
            params.setHint((long) hint);
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

    @IntDef({VisibilityEvent.NONE, VisibilityEvent.FOREGROUND, VisibilityEvent.BACKGROUND})
    @Retention(RetentionPolicy.SOURCE)
    public @interface VisibilityEvent {
        int NONE = 0;
        int FOREGROUND = 1;
        int BACKGROUND = 2;
    }

    public void onForeground() {
        ContainerShadowNode node = getStackTop();
        if (node != null) {
            node.setVisibilityEvent(VisibilityEvent.FOREGROUND);
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
            node.setVisibilityEvent(VisibilityEvent.BACKGROUND);
        }

        if (mApi != null) {
            Messages.CommonParams params = new Messages.CommonParams();
            mApi.onBackground(params, reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onBackground: " + mApi);
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

    public void updateContainer(String uniqueId, ContainerShadowNode container) {
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
        private @VisibilityEvent int mEvent;
        private boolean mIsPopping;

        public static ContainerShadowNode create(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            return new ContainerShadowNode(container, plugin);
        }

        private ContainerShadowNode(FlutterViewContainer container, FlutterBoostPlugin plugin) {
            assert container != null;
            mContainer = new WeakReference<>(container);
            mPlugin = plugin;
            mIsPopping = false;
            setVisibilityEvent(VisibilityEvent.NONE);
        }

        public FlutterViewContainer container() {
            return mContainer.get();
        }
        public void setVisibilityEvent(@VisibilityEvent int event) {
            mEvent = event;
        }

        public void setIsPopping() {
            mIsPopping = true;
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
        public void onAppear(@ChangeReason int reason) {
            assert container() != null;
            @ChangeReason int hint = reason;
            if (ChangeReason.UNSPECIFIED == hint) {
                if (mPlugin.findContainerById(getUniqueId()) == null) {
                    // create new FlutterView
                    hint = ChangeReason.PUSH_VIEW;
                } else {
                    if (VisibilityEvent.FOREGROUND == mEvent) {
                        assert mPlugin.getTopContainer().getUniqueId() == getUniqueId();
                        // switch to foreground
                        hint = ChangeReason.FOREGROUND;
                    } else {
                        // The previous view was popped
                        hint = ChangeReason.POP_VIEW;
                    }
                }
            }
            setVisibilityEvent(VisibilityEvent.NONE);

            mPlugin.updateContainer(getUniqueId(), this);
            mPlugin.pushRoute(getUniqueId(), getUrl(), getUrlParams(), hint, null);
            Log.v(TAG, "#onAppear: " + getUniqueId() + ", reason: " + ChangeReasonToString(hint) + ", " + mPlugin.getContainers());
        }

        @Override
        public void onDisappear(@ChangeReason int reason) {
            // todo:
            @ChangeReason int hint = reason;
            if (ChangeReason.UNSPECIFIED == hint) {
                FlutterViewContainer top = mPlugin.getTopContainer();
                if (top != null && top.getUniqueId() == getUniqueId() &&
                        VisibilityEvent.BACKGROUND == mEvent) {
                    // switch to background
                    hint = ChangeReason.BACKGROUND;
                } else {
                    if (mIsPopping) {
                        hint = ChangeReason.POP_VIEW;
                    } else {
                        // The native view was pushed
                        hint = ChangeReason.PUSH_VIEW;
                    }
                }
            }
            setVisibilityEvent(VisibilityEvent.NONE);
            Log.v(TAG, "#onDisappear: " + getUniqueId() + ", reason: " + ChangeReasonToString(hint) + ", " + mPlugin.getContainers());
        }

        @Override
        public void onDestroyView() {
            mPlugin.popRoute(getUniqueId(), null);
            mPlugin.removeContainer(getUniqueId());
            Log.v(TAG, "#onDestroyView: " + getUniqueId() + ", " + mPlugin.getContainers());
        }
    }

    static String ChangeReasonToString(@ChangeReason int reason) {
        switch (reason) {
            case ChangeReason.UNSPECIFIED:
                return "UNSPECIFIED";
            case ChangeReason.PUSH_ROUTE:
                return "PUSH_ROUTE";
            case ChangeReason.POP_ROUTE:
                return "POP_ROUTE";
            case ChangeReason.PUSH_VIEW:
                return "PUSH_VIEW";
            case ChangeReason.POP_VIEW:
                return "POP_VIEW";
            case ChangeReason.SWITCH_TAB:
                return "SWITCH_TAB";
            case ChangeReason.FOREGROUND:
                return "FOREGROUND";
            case ChangeReason.BACKGROUND:
                return "BACKGROUND";
            default:
                return "ERROR_XXX";
        }
    }
}
