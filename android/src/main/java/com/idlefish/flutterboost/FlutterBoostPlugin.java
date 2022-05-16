package com.idlefish.flutterboost;

import android.util.Log;
import android.util.SparseArray;

import com.idlefish.flutterboost.Messages.Result;
import com.idlefish.flutterboost.Messages.CommonParams;
import com.idlefish.flutterboost.Messages.FlutterRouterApi;
import com.idlefish.flutterboost.Messages.NativeRouterApi;
import com.idlefish.flutterboost.Messages.StackInfo;
import com.idlefish.flutterboost.containers.FlutterContainerManager;
import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class FlutterBoostPlugin implements FlutterPlugin, NativeRouterApi, ActivityAware {
    private static final String TAG = FlutterBoostPlugin.class.getSimpleName();
    private static final boolean DEBUG = false;
    private FlutterEngine engine;
    private FlutterRouterApi channel;
    private FlutterBoostDelegate delegate;
    private StackInfo dartStack;
    private SparseArray<String> pageNames;
    private int requestCode = 1000;

    private HashMap<String, LinkedList<EventListener>> listenersTable = new HashMap<>();

    public FlutterRouterApi getChannel() {
        return channel;
    }

    public void setDelegate(FlutterBoostDelegate delegate) {
        this.delegate = delegate;
    }

    public FlutterBoostDelegate getDelegate() {
        return delegate;
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        if (DEBUG) Log.v(TAG, "#onAttachedToEngine");
        NativeRouterApi.setup(binding.getBinaryMessenger(), this);
        engine = binding.getFlutterEngine();
        channel = new FlutterRouterApi(binding.getBinaryMessenger());
        pageNames = new SparseArray<String>();
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        if (DEBUG) Log.v(TAG, "#onDetachedFromEngine");
        engine = null;
        channel = null;
    }

    @Override
    public void pushNativeRoute(CommonParams params) {
        if (DEBUG) Log.v(TAG, "#pushNativeRoute: " + params.getPageName());
        if (delegate != null) {
            requestCode++;
            if (pageNames != null) {
                pageNames.put(requestCode, params.getPageName());
            }
            FlutterBoostRouteOptions options = new FlutterBoostRouteOptions.Builder()
                    .pageName(params.getPageName())
                    .arguments((Map<String, Object>) (Object) params.getArguments())
                    .requestCode(requestCode)
                    .build();
            delegate.pushNativeRoute(options);
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public void pushFlutterRoute(CommonParams params) {
        if (DEBUG) Log.v(TAG, "#pushFlutterRoute: " + params.getPageName() + ", " + params.getUniqueId());
        if (delegate != null) {
            FlutterBoostRouteOptions options = new FlutterBoostRouteOptions.Builder()
                    .pageName(params.getPageName())
                    .uniqueId(params.getUniqueId())
                    .opaque(params.getOpaque())
                    .arguments((Map<String, Object>) (Object) params.getArguments())
                    .build();
            delegate.pushFlutterRoute(options);
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public void popRoute(CommonParams params, Messages.Result<Void> result) {
        if (DEBUG) Log.v(TAG, "#popRoute: " + params.getPageName() + ", " + params.getUniqueId());
        if (delegate != null) {
            FlutterBoostRouteOptions options = new FlutterBoostRouteOptions.Builder()
                    .pageName(params.getPageName())
                    .uniqueId(params.getUniqueId())
                    .arguments((Map<String, Object>) (Object) params.getArguments())
                    .build();
            boolean isHandle = delegate.popRoute(options);
            //isHandle代表是否已经自定义处理，如果未自定义处理走默认逻辑
            if (!isHandle) {
                String uniqueId = params.getUniqueId();
                if (uniqueId != null) {
                    FlutterViewContainer container = FlutterContainerManager.instance().findContainerById(uniqueId);
                    if (container != null) {
                        container.finishContainer((Map<String, Object>) (Object) params.getArguments());
                    }
                    result.success(null);
                } else {
                    throw new RuntimeException("Oops!! The unique id is null!");
                }
            }
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* set delegate!");
        }
    }

    @Override
    public StackInfo getStackFromHost() {
        if (dartStack == null) {
            return StackInfo.fromMap(new HashMap());
        }
        if (DEBUG) Log.v(TAG, "#getStackFromHost: " + dartStack);
        return dartStack;
    }

    @Override
    public void saveStackToHost(StackInfo arg) {
        dartStack = arg;
        if (DEBUG) Log.v(TAG, "#saveStackToHost: " + dartStack);
    }

    @Override
    public void sendEventToNative(CommonParams arg) {
        //deal with the event from flutter side
        String key = arg.getKey();
        Map<Object, Object> arguments = arg.getArguments();
        assert (key != null);

        if (arguments == null) {
            arguments = new HashMap<>();
        }

        List<EventListener> listeners = listenersTable.get(key);
        if (listeners == null) {
            return;
        }

        for (EventListener listener : listeners) {
            listener.onEvent(key, arguments);
        }
    }

    ListenerRemover addEventListener(String key, EventListener listener) {
        assert (key != null && listener != null);

        LinkedList<EventListener> listeners = listenersTable.get(key);
        if (listeners == null) {
            listeners = new LinkedList<>();
            listenersTable.put(key, listeners);
        }
        listeners.add(listener);

        LinkedList<EventListener> finalListeners = listeners;
        return () -> finalListeners.remove(listener);
    }

    private void checkEngineState() {
        if (engine == null || !engine.getDartExecutor().isExecutingDart()) {
            throw new RuntimeException("The engine is not ready for use. " +
                    "The message may be drop silently by the engine. " +
                    "You should check 'DartExecutor.isExecutingDart()' first!");
        }
    }

    public void pushRoute(String uniqueId, String pageName, Map<String, Object> arguments,
                          final FlutterRouterApi.Reply<Void> callback) {
        if (DEBUG) Log.v(TAG, "#pushRoute: " + pageName + ", " + uniqueId);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            params.setPageName(pageName);
            params.setArguments((Map<Object, Object>) (Object) arguments);
            channel.pushRoute(params, reply -> {
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void popRoute(String uniqueId, final FlutterRouterApi.Reply<Void> callback) {
        if (DEBUG) Log.v(TAG, "#popRoute: " + uniqueId);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            channel.popRoute(params, reply -> {
                if (callback != null) {
                    callback.reply(null);
                }
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onBackPressed() {
        if (channel != null) {
            checkEngineState();
            channel.onBackPressed(reply -> {});
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void removeRoute(String uniqueId, final FlutterRouterApi.Reply<Void> callback) {
        if (DEBUG) Log.v(TAG, "#removeRoute: " + uniqueId);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            channel.removeRoute(params, reply -> {
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
            checkEngineState();
            CommonParams params = new CommonParams();
            channel.onForeground(params, reply -> {
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onForeground: " + channel);
    }

    public void onBackground() {
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            channel.onBackground(params, reply -> {
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onBackground: " + channel);
    }

    public void onContainerShow(String uniqueId) {
        if (DEBUG) Log.v(TAG, "#onContainerShow: " + uniqueId);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            channel.onContainerShow(params, reply -> {
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
    }

    public void onContainerHide(String uniqueId) {
        if (DEBUG) Log.v(TAG, "#onContainerHide: " + uniqueId);
        if (channel != null) {
            checkEngineState();
            CommonParams params = new CommonParams();
            params.setUniqueId(uniqueId);
            channel.onContainerHide(params, reply -> {
            });
        } else {
            throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
        }
        Log.v(TAG, "## onContainerHide: " + uniqueId);
    }

    public void onContainerCreated(FlutterViewContainer container) {
        if (DEBUG) Log.v(TAG, "#onContainerCreated: " + container.getUniqueId());
        FlutterContainerManager.instance().addContainer(container.getUniqueId(), container);
        if (FlutterContainerManager.instance().getContainerSize() == 1) {
           FlutterBoost.instance().changeFlutterAppLifecycle(FlutterBoost.FLUTTER_APP_STATE_RESUMED);
        }
    }

    public void onContainerAppeared(FlutterViewContainer container) {
        String uniqueId = container.getUniqueId();
        if (DEBUG) Log.v(TAG, "#onContainerAppeared: " + uniqueId);
        FlutterContainerManager.instance().activateContainer(uniqueId, container);
        pushRoute(uniqueId, container.getUrl(), container.getUrlParams(), reply -> {});
        onContainerShow(uniqueId);
    }

    public void onContainerDisappeared(FlutterViewContainer container) {
        String uniqueId = container.getUniqueId();
        if (DEBUG) Log.v(TAG, "#onContainerDisappeared: " + uniqueId);
        onContainerHide(uniqueId);
    }

    public void onContainerDestroyed(FlutterViewContainer container) {
        String uniqueId = container.getUniqueId();
        if (DEBUG) Log.v(TAG, "#onContainerDestroyed: " + uniqueId);
        removeRoute(uniqueId, reply -> {});
        FlutterContainerManager.instance().removeContainer(uniqueId);
        if (FlutterContainerManager.instance().getContainerSize() == 0) {
            FlutterBoost.instance().changeFlutterAppLifecycle(FlutterBoost.FLUTTER_APP_STATE_PAUSED);
        }
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        if (DEBUG) Log.v(TAG, "#onAttachedToActivity");
        activityPluginBinding.addActivityResultListener((requestCode, resultCode, intent) -> {
            if (channel != null) {
                checkEngineState();
                CommonParams params = new CommonParams();
                String pageName = pageNames.get(requestCode);
                pageNames.remove(requestCode);
                if (null != pageName) {
                    params.setPageName(pageName);
                    if (intent != null) {
                        Map<Object, Object> result = FlutterBoostUtils.bundleToMap(intent.getExtras());
                        params.setArguments(result);
                    }

                    // Get a result back from an activity when it ends.
                    channel.onNativeResult(params, reply -> {
                    if (DEBUG) Log.v(TAG, "#onNativeResult, pageName=" + pageName);
                    });
                }
            } else {
                throw new RuntimeException("FlutterBoostPlugin might *NOT* have attached to engine yet!");
            }
            return true;
        });
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        if (DEBUG) Log.v(TAG, "#onDetachedFromActivityForConfigChanges");
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        if (DEBUG) Log.v(TAG, "#onReattachedToActivityForConfigChanges");
    }

    @Override
    public void onDetachedFromActivity() {
        if (DEBUG) Log.v(TAG, "#onDetachedFromActivity");
    }
}
