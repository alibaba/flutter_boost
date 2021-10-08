package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostUtils;
import com.idlefish.flutterboost.Messages;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.embedding.android.LifecycleView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.android.TransparencyMode;
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_UNIQUE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL_PARAM;

public class FlutterBoostView extends LifecycleView implements FlutterViewContainer {
    private static final String TAG = "FlutterBoostView";
    private final String who = UUID.randomUUID().toString();
    private Callback callback;
    private boolean hasCreated;
    private boolean hasDestroyed;

    private boolean hasDestroyed() {
        if (hasDestroyed) {
            Log.w(TAG, "Application attempted to call on a destroyed View", new Throwable());
        }
        return hasDestroyed;
    }

    @NonNull
    public static CachedEngineBuilder withCachedEngine() {
        return new CachedEngineBuilder();
    }

    public static class CachedEngineBuilder {
        private RenderMode renderMode = RenderMode.texture;
        private TransparencyMode transparencyMode = TransparencyMode.transparent;
        private boolean shouldAttachEngineToActivity = true;
        private String url;
        private HashMap<String, Object> params;

        private CachedEngineBuilder() {
        }

        @NonNull
        public CachedEngineBuilder renderMode(@NonNull RenderMode renderMode) {
            this.renderMode = renderMode;
            return this;
        }

        @NonNull
        public CachedEngineBuilder transparencyMode(
                @NonNull TransparencyMode transparencyMode) {
            this.transparencyMode = transparencyMode;
            return this;
        }

        @NonNull
        protected Bundle createArgs() {
            Bundle args = new Bundle();
            args.putString(ARG_CACHED_ENGINE_ID, FlutterBoost.ENGINE_ID);
            args.putString(
                    ARG_FLUTTERVIEW_RENDER_MODE,
                    renderMode != null ? renderMode.name() : RenderMode.surface.name());
            args.putString(
                    ARG_FLUTTERVIEW_TRANSPARENCY_MODE,
                    transparencyMode != null ? transparencyMode.name() : TransparencyMode.transparent.name());
            args.putString(EXTRA_URL, url);
            args.putSerializable(EXTRA_URL_PARAM, params);
            args.putString(EXTRA_UNIQUE_ID, FlutterBoostUtils.createUniqueId(url));
            return args;
        }

        public FlutterBoostView build(Activity context) {
            return build(context, null);
        }

        @NonNull
        public FlutterBoostView build(Activity context, Callback callback) {
            FlutterBoostView view = new FlutterBoostView(context, callback);
            Bundle args = createArgs();
            view.setArguments(args);
            return view;
        }

        @NonNull
        public CachedEngineBuilder url(
                @NonNull String url) {
            this.url = url;
            return this;
        }

        @NonNull
        public CachedEngineBuilder urlParams(@NonNull Map<String, Object> params) {
            this.params = (params instanceof HashMap) ? (HashMap)params : new HashMap<String, Object>(params);
            return this;
        }
    }

    private FlutterBoostView(Activity context, Callback callback) {
        super(context);
        this.callback = callback;
    }


    @Override
    public void onCreate() {
        super.onCreate();
        FlutterBoost.instance().getPlugin().onContainerCreated(this);
        onStart();
        hasCreated = true;
    }

    @Override
    public void onResume() {
        if(hasDestroyed()) return;
        if (!hasCreated) {
            onCreate();
        }
        super.onResume();
        FlutterBoost.instance().getPlugin().onContainerAppeared(this);
        flutterView().attachToFlutterEngine(getFlutterEngine());
        getFlutterEngine().getLifecycleChannel().appIsResumed();
    }

    @Override
    public void onPause() {
        if(hasDestroyed()) return;
        super.onPause();
        flutterView().detachFromFlutterEngine();
        getFlutterEngine().getLifecycleChannel().appIsResumed();
    }

    @Override
    public void onStop() {
        if(hasDestroyed()) return;
        super.onStop();
        FlutterBoost.instance().getPlugin().onContainerDisappeared(this);
    }

    @Override
    public void onDestroy() {
        if(hasDestroyed()) return;
        if (hasCreated) {
            super.onDestroy();
            FlutterBoost.instance().getPlugin().onContainerDestroyed(this);
        }
        hasDestroyed = true;
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (!hasCreated) {
            onCreate();
        }

        if (getVisibility() == View.VISIBLE) {
            FlutterBoost.instance().getPlugin().onContainerAppeared(this);
            flutterView().attachToFlutterEngine(getFlutterEngine());
        } else if (getVisibility() == View.GONE) {
            FlutterBoost.instance().getPlugin().onContainerDisappeared(this);
            flutterView().detachFromFlutterEngine();
        }
    }

    public void onBackPressed() {
        FlutterBoost.instance().getPlugin().onBackPressed();
    }

    @Override
    public Activity getContextActivity() {
        return getActivity();
    }

    @Override
    public void finishContainer(Map<String, Object> result) {
        if (callback != null) {
            callback.finishContainer(result);
        } else {
            getActivity().finish();
        }
    }

    @Override
    public String getCachedEngineId() {
      return getArguments().getString(ARG_CACHED_ENGINE_ID, FlutterBoost.ENGINE_ID);
    }

    public void onFlutterUiDisplayed() {
        if (callback != null) {
            callback.onFlutterUiDisplayed();
        } else {
            Activity attachedActivity = getActivity();
            if (attachedActivity instanceof FlutterUiDisplayListener) {
                ((FlutterUiDisplayListener) attachedActivity).onFlutterUiDisplayed();
            }
        }
    }

    public void onFlutterUiNoLongerDisplayed() {
        if (callback != null) {
            callback.onFlutterUiNoLongerDisplayed();
        } else {
            Activity attachedActivity = getActivity();
            if (attachedActivity instanceof FlutterUiDisplayListener) {
                ((FlutterUiDisplayListener) attachedActivity).onFlutterUiNoLongerDisplayed();
            }
        }
    }

    public String getUrl() {
        if (!getArguments().containsKey(EXTRA_URL)) {
            throw new RuntimeException("Oops! The view url are *MISSED*! You should "
                    + "override the |getUrl|, or set url via CachedEngineBuilder.");
        }
        return getArguments().getString(EXTRA_URL);
    }

    public Map<String, Object> getUrlParams() {
        return (HashMap<String, Object>)getArguments().getSerializable(EXTRA_URL_PARAM);
    }

    public String getUniqueId() {
        return getArguments().getString(EXTRA_UNIQUE_ID, this.who);
    }

    public interface Callback extends FlutterUiDisplayListener {
        void finishContainer(Map<String, Object> result);
        void onFlutterUiDisplayed();
        void onFlutterUiNoLongerDisplayed();
    }
}