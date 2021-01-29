package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostPlugin;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.LifecycleView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.android.TransparencyMode;
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_UNIQUE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL_PARAM;

public class FlutterBoostView extends LifecycleView implements FlutterViewContainer {
    private static final String TAG = "FlutterBoostView";
    private FlutterViewContainerObserver mObserver;
    private Callback mCallback;
    private boolean mCreateAndStart;
    private boolean mIsDestroyed;

    private boolean isDestroyed() {
        if (mIsDestroyed) {
            Log.w(TAG, "Application attempted to call on a destroyed View", new Throwable());
        }
        return mIsDestroyed;
    }

    @NonNull
    public static CachedEngineBuilder withCachedEngine(@NonNull String engineId) {
        return new CachedEngineBuilder(engineId);
    }

    public static class CachedEngineBuilder {
        private final String engineId;
        private RenderMode renderMode = RenderMode.texture;
        private TransparencyMode transparencyMode = TransparencyMode.transparent;
        private boolean shouldAttachEngineToActivity = true;
        private String url;
        private HashMap<String, String> urlParam;

        private CachedEngineBuilder(@NonNull String engineId) {
            this.engineId = engineId;
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
            args.putString(ARG_CACHED_ENGINE_ID, engineId);
            args.putString(
                    ARG_FLUTTERVIEW_RENDER_MODE,
                    renderMode != null ? renderMode.name() : RenderMode.surface.name());
            args.putString(
                    ARG_FLUTTERVIEW_TRANSPARENCY_MODE,
                    transparencyMode != null ? transparencyMode.name() : TransparencyMode.transparent.name());
            args.putString(EXTRA_URL, url);
            args.putSerializable(EXTRA_URL_PARAM, urlParam);
            args.putString(EXTRA_UNIQUE_ID, FlutterBoost.generateUniqueId(url));
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
        public CachedEngineBuilder params(@NonNull HashMap<String, String> param) {
            this.urlParam = param;
            return this;
        }
    }

    private FlutterBoostView(Activity context, Callback callback) {
        super(context);
        mCallback = callback;
    }


    @Override
    public void onCreate() {
        super.onCreate();
        mObserver = FlutterBoostPlugin.ContainerShadowNode.create(this, FlutterBoost.getFlutterBoostPlugin(getFlutterEngine()));
        mObserver.onCreateView();
        onStart();
        mCreateAndStart = true;
    }

    @Override
    public void onResume() {
        if(isDestroyed()) return;
        if (!mCreateAndStart) {
            onCreate();
            mCreateAndStart = true;
        }
        super.onResume();
        ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(flutterView(), getFlutterEngine(), this);
        getFlutterEngine().getLifecycleChannel().appIsResumed();
        mObserver.onAppear(ChangeReason.Unspecified);
    }

    @Override
    public void onPause() {
        if(isDestroyed()) return;
        super.onPause();
        ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(flutterView(), getFlutterEngine());
        getFlutterEngine().getLifecycleChannel().appIsResumed();
    }

    @Override
    public void onStop() {
        if(isDestroyed()) return;
        super.onStop();
        mObserver.onDisappear(ChangeReason.Unspecified);
    }

    @Override
    public void onDestroy() {
        if(isDestroyed()) return;
        super.onDestroy();
        mObserver.onDestroyView();
        mIsDestroyed = true;
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (!mCreateAndStart) {
            onCreate();
            mCreateAndStart = true;
        }

        if (getVisibility() == View.VISIBLE) {
            ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(flutterView(), getFlutterEngine(), this);
            mObserver.onAppear(ChangeReason.RouteReorder);
        } else if (getVisibility() == View.GONE) {
            ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(flutterView(), getFlutterEngine());
            mObserver.onDisappear(ChangeReason.RouteReorder);
        }
    }

    public void onBackPressed() {
        ActivityAndFragmentPatch.onBackPressed();
    }

    @Override
    public Activity getContextActivity() {
        return getActivity();
    }

    @Override
    public void finishContainer(Map<String, Object> result) {
        if (mCallback != null) {
            mCallback.finishContainer(result);
        } else {
            getActivity().finish();
        }
    }

    public void onFlutterUiDisplayed() {
        if (mCallback != null) {
            mCallback.onFlutterUiDisplayed();
        } else {
            Activity attachedActivity = getActivity();
            if (attachedActivity instanceof FlutterUiDisplayListener) {
                ((FlutterUiDisplayListener) attachedActivity).onFlutterUiDisplayed();
            }
        }
    }

    public void onFlutterUiNoLongerDisplayed() {
        if (mCallback != null) {
            mCallback.onFlutterUiNoLongerDisplayed();
        } else {
            Activity attachedActivity = getActivity();
            if (attachedActivity instanceof FlutterUiDisplayListener) {
                ((FlutterUiDisplayListener) attachedActivity).onFlutterUiNoLongerDisplayed();
            }
        }
    }

    @Nullable
    public String getUrl() {
        return getArguments().getString(EXTRA_URL);
    }

    @Nullable
    public HashMap<String, String> getUrlParams() {
        return (HashMap<String, String>)getArguments().getSerializable(EXTRA_URL_PARAM);
    }

    public String getUniqueId() {
        return getArguments().getString(EXTRA_UNIQUE_ID);
    }

    public interface Callback extends FlutterUiDisplayListener {
        void finishContainer(Map<String, Object> result);
        void onFlutterUiDisplayed();
        void onFlutterUiNoLongerDisplayed();
    }
}