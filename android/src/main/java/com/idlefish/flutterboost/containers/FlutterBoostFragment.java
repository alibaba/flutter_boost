package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.idlefish.flutterboost.Assert;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostUtils;
import com.idlefish.flutterboost.Messages;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterFragment;
import io.flutter.embedding.android.FlutterTextureView;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.android.TransparencyMode;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.platform.PlatformPlugin;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.ACTIVITY_RESULT_KEY;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_UNIQUE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL_PARAM;

public class FlutterBoostFragment extends FlutterFragment implements FlutterViewContainer {
    private static final String TAG = "FlutterBoostFragment";
    private static final boolean DEBUG = false;
    private final String who = UUID.randomUUID().toString();
    private final FlutterTextureHooker textureHooker=new FlutterTextureHooker();
    private FlutterView flutterView;
    private PlatformPlugin platformPlugin;
    private LifecycleStage stage;
    private boolean isAttached = false;
    private boolean isFinishing = false;

    // @Override
    public void detachFromFlutterEngine() {
        /**
         * Override and do nothing.
         *
         * The idea here is to avoid releasing delegate when
         * a new FlutterFragment is attached in Flutter2.0.
         */
        if (DEBUG) Log.d(TAG, "#detachFromFlutterEngine: " + this);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        stage = LifecycleStage.ON_CREATE;
        if (DEBUG) Log.d(TAG, "#onCreate: " + this);
    }

    @Override
    public void onStart() {
        super.onStart();
        if (DEBUG) Log.d(TAG, "#onStart: " + this);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stage = LifecycleStage.ON_DESTROY;
        textureHooker.onFlutterTextureViewRelease();
        detachFromEngineIfNeeded();
        if (DEBUG) Log.d(TAG, "#onDestroy: " + this);
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (DEBUG) Log.d(TAG, "#onAttach: " + this);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        FlutterBoost.instance().getPlugin().onContainerCreated(this);
        View view = super.onCreateView(inflater, container, savedInstanceState);
        flutterView = FlutterBoostUtils.findFlutterView(view);
        // Detach FlutterView from engine before |onResume|.
        flutterView.detachFromFlutterEngine();
        if (DEBUG) Log.d(TAG, "#onCreateView: " + flutterView + ", " + this);
        return view;
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        // If |onHiddenChanged| method is called before the |onCreateView|,
        // we just return here.
        if (flutterView == null) return;
        if (hidden) {
            didFragmentHide();
        } else {
            didFragmentShow();
        }
        if (DEBUG) Log.d(TAG, "#onHiddenChanged: hidden="  + hidden + ", " + this);
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        // If |setUserVisibleHint| method is called before the |onCreateView|,
        // we just return here.
        if (flutterView == null) return;
        if (isVisibleToUser) {
            didFragmentShow();
        } else {
            didFragmentHide();
        }
        if (DEBUG) Log.d(TAG, "#setUserVisibleHint: isVisibleToUser="  + isVisibleToUser + ", " + this);
    }

    @Override
    public void onResume() {
        super.onResume();
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
            final FlutterContainerManager containerManager = FlutterContainerManager.instance();
            FlutterViewContainer top = containerManager.getTopActivityContainer();
            boolean isActiveContainer = containerManager.isActiveContainer(this);
            if (isActiveContainer && top != null && top != this.getContextActivity() && !top.isOpaque() && top.isPausing()) {
                Log.w(TAG, "Skip the unexpected activity lifecycle event on Android Q. " +
                        "See https://issuetracker.google.com/issues/185693011 for more details.");
                return;
            }
        }

        stage = LifecycleStage.ON_RESUME;
        if (!isHidden()) {
            didFragmentShow();
            getFlutterEngine().getLifecycleChannel().appIsResumed();

            // Update system UI overlays to match Flutter's desired system chrome style
            onUpdateSystemUiOverlays();
        }
       if (DEBUG) Log.d(TAG, "#onResume: isHidden=" + isHidden() + ", " + this);
    }

    // Update system UI overlays to match Flutter's desired system chrome style
    protected void onUpdateSystemUiOverlays() {
        Assert.assertNotNull(platformPlugin);
        platformPlugin.updateSystemUiOverlays();
    }

    @Override
    public RenderMode getRenderMode() {
        // Default to |FlutterTextureView|.
        return RenderMode.texture;
    }

    @Override
    public void onPause() {
        super.onPause();
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
            FlutterViewContainer top = FlutterContainerManager.instance().getTopActivityContainer();
            if (top != null && top != this.getContextActivity() && !top.isOpaque() && top.isPausing()) {
                Log.w(TAG, "Skip the unexpected activity lifecycle event on Android Q. " +
                        "See https://issuetracker.google.com/issues/185693011 for more details.");
                return;
            }
        }

        stage = LifecycleStage.ON_PAUSE;
        didFragmentHide();
        getFlutterEngine().getLifecycleChannel().appIsResumed();
        if (DEBUG) Log.d(TAG, "#onPause: " + this + ", isFinshing=" + isFinishing);
    }

    @Override
    public void onStop() {
        super.onStop();
        stage = LifecycleStage.ON_STOP;
        getFlutterEngine().getLifecycleChannel().appIsResumed();
        if (DEBUG) Log.d(TAG, "#onStop: " + this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        FlutterBoost.instance().getPlugin().onContainerDestroyed(this);
        if (DEBUG) Log.d(TAG, "#onDestroyView: " + this);
    }

    @Override
    public void onDetach() {
        FlutterEngine engine = getFlutterEngine();
        super.onDetach();
        engine.getLifecycleChannel().appIsResumed();
        if (DEBUG) Log.d(TAG, "#onDetach: " + this);
    }

    @Override
    // This method is called right before the activity's onPause() callback.
    public void onUserLeaveHint() {
        super.onUserLeaveHint();
        if (DEBUG) Log.d(TAG, "#onUserLeaveHint: " + this);
    }

    @Override
    public void onBackPressed() {
        // Intercept the user's press of the back key.
        FlutterBoost.instance().getPlugin().onBackPressed();
        if (DEBUG) Log.d(TAG, "#onBackPressed: " + this);
    }

    @Override
    public boolean shouldRestoreAndSaveState() {
      if (getArguments().containsKey(ARG_ENABLE_STATE_RESTORATION)) {
        return getArguments().getBoolean(ARG_ENABLE_STATE_RESTORATION);
      }
      // Defaults to |true|.
      return true;
    }

    @Override
    public PlatformPlugin providePlatformPlugin(Activity activity, FlutterEngine flutterEngine) {
        // We takeover |PlatformPlugin| here.
        return null;
    }

    @Override
    public boolean shouldDestroyEngineWithHost() {
        // The |FlutterEngine| should outlive this FlutterFragment.
        return false;
    }

    @Override
    public void onFlutterTextureViewCreated(FlutterTextureView flutterTextureView) {
        super.onFlutterTextureViewCreated(flutterTextureView);
        textureHooker.hookFlutterTextureView(flutterTextureView);
    }

    @Override
    public Activity getContextActivity() {
        return getActivity();
    }

    @Override
    public void finishContainer(Map<String, Object> result) {
        isFinishing = true;
        if (result != null) {
            Intent intent = new Intent();
            intent.putExtra(ACTIVITY_RESULT_KEY, new HashMap<String, Object>(result));
            getActivity().setResult(Activity.RESULT_OK, intent);
        }
        onFinishContainer();
        if (DEBUG) Log.d(TAG, "#finishContainer: " + this);
    }

    // finish activity container
    protected void onFinishContainer() {
        getActivity().finish();
    }

    @Override
    public String getUrl() {
        if (!getArguments().containsKey(EXTRA_URL)) {
            throw new RuntimeException("Oops! The fragment url are *MISSED*! You should "
                    + "override the |getUrl|, or set url via CachedEngineFragmentBuilder.");
        }
        return getArguments().getString(EXTRA_URL);
    }

    @Override
    public Map<String, Object> getUrlParams() {
        return (HashMap<String, Object>)getArguments().getSerializable(EXTRA_URL_PARAM);
    }

    @Override
    public String getUniqueId() {
        return getArguments().getString(EXTRA_UNIQUE_ID, this.who);
    }

    @Override
    public String getCachedEngineId() {
        return FlutterBoost.ENGINE_ID;
    }

    @Override
    public boolean isPausing() {
        return (stage == LifecycleStage.ON_PAUSE || stage == LifecycleStage.ON_STOP) && !isFinishing;
    }

    private void didFragmentShow() {
        // try to detach prevous container from the engine.
        FlutterViewContainer top = FlutterContainerManager.instance().getTopContainer();
        if (top != null && top != this) {
            top.detachFromEngineIfNeeded();
        }

        FlutterBoost.instance().getPlugin().onContainerAppeared(this);
        performAttach();
        textureHooker.onFlutterTextureViewRestoreState();
        if (DEBUG) Log.d(TAG, "#didFragmentShow: " + this + ", isOpaque=" + isOpaque());
    }

    private void didFragmentHide() {
        FlutterBoost.instance().getPlugin().onContainerDisappeared(this);
        // We defer |performDetach| call to new Flutter container's |onResume|;
        // performDetach();
        if (DEBUG) Log.d(TAG, "#didFragmentHide: " + this + ", isOpaque=" + isOpaque());
    }

    private void performAttach() {
        if (!isAttached) {
            // Attach plugins to the activity.
            getFlutterEngine().getActivityControlSurface().attachToActivity(getActivity(), getLifecycle());

            if (platformPlugin == null) {
                platformPlugin = new PlatformPlugin(getActivity(), getFlutterEngine().getPlatformChannel());
            }

            // Attach rendering pipeline.
            flutterView.attachToFlutterEngine(getFlutterEngine());
            isAttached = true;
            if (DEBUG) Log.d(TAG, "#performAttach: " + this);
        }
    }

    private void performDetach() {
        if (isAttached) {
            // Plugins are no longer attached to the activity.
            getFlutterEngine().getActivityControlSurface().detachFromActivity();

            // Release Flutter's control of UI such as system chrome.
            releasePlatformChannel();

            // Detach rendering pipeline.
            flutterView.detachFromFlutterEngine();

            isAttached = false;
            if (DEBUG) Log.d(TAG, "#performDetach: " + this);
        }
    }

    private void releasePlatformChannel() {
        if (platformPlugin != null) {
            platformPlugin.destroy();
            platformPlugin = null;
        }
    }

    @Override
    public void detachFromEngineIfNeeded() {
        performDetach();
    }

    // Defaults to {@link TransparencyMode#opaque}.
    @Override
    public TransparencyMode getTransparencyMode() {
        String transparencyModeName =
            getArguments()
                .getString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, TransparencyMode.opaque.name());
        return TransparencyMode.valueOf(transparencyModeName);
    }

    @Override
    public boolean isOpaque() {
        return getTransparencyMode() == TransparencyMode.opaque;
    }

    public static class CachedEngineFragmentBuilder {
        private final Class<? extends FlutterBoostFragment> fragmentClass;
        private boolean destroyEngineWithFragment = false;
        private RenderMode renderMode = RenderMode.surface;
        private TransparencyMode transparencyMode = TransparencyMode.opaque;
        private boolean shouldAttachEngineToActivity = true;
        private String url = "/";
        private HashMap<String, Object> params;
        private String uniqueId;

        public CachedEngineFragmentBuilder() {
            this(FlutterBoostFragment.class);
        }

        public CachedEngineFragmentBuilder(Class<? extends FlutterBoostFragment> subclass) {
            fragmentClass = subclass;
        }

        public CachedEngineFragmentBuilder url(String url) {
            this.url = url;
            return this;
        }

        public CachedEngineFragmentBuilder urlParams(Map<String, Object> params) {
            this.params = (params instanceof HashMap) ? (HashMap)params : new HashMap<String, Object>(params);
            return this;
        }

        public CachedEngineFragmentBuilder uniqueId(String uniqueId) {
            this.uniqueId = uniqueId;
            return this;
        }

        public CachedEngineFragmentBuilder destroyEngineWithFragment(
                boolean destroyEngineWithFragment) {
            this.destroyEngineWithFragment = destroyEngineWithFragment;
            return this;
        }

        public CachedEngineFragmentBuilder renderMode( RenderMode renderMode) {
            this.renderMode = renderMode;
            return this;
        }

        public CachedEngineFragmentBuilder transparencyMode(
                 TransparencyMode transparencyMode) {
            this.transparencyMode = transparencyMode;
            return this;
        }

        public CachedEngineFragmentBuilder shouldAttachEngineToActivity(
                boolean shouldAttachEngineToActivity) {
            this.shouldAttachEngineToActivity = shouldAttachEngineToActivity;
            return this;
        }

        /**
         * Creates a {@link Bundle} of arguments that are assigned to the new {@code FlutterFragment}.
         *
         * <p>Subclasses should override this method to add new properties to the {@link Bundle}.
         * Subclasses must call through to the super method to collect all existing property values.
         */
        protected Bundle createArgs() {
            Bundle args = new Bundle();
            args.putString(ARG_CACHED_ENGINE_ID, FlutterBoost.ENGINE_ID);
            args.putBoolean(ARG_DESTROY_ENGINE_WITH_FRAGMENT, destroyEngineWithFragment);
            args.putString(
                    ARG_FLUTTERVIEW_RENDER_MODE,
                    renderMode != null ? renderMode.name() : RenderMode.surface.name());
            args.putString(
                    ARG_FLUTTERVIEW_TRANSPARENCY_MODE,
                    transparencyMode != null ? transparencyMode.name() : TransparencyMode.transparent.name());
            args.putBoolean(ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY, shouldAttachEngineToActivity);
            args.putString(EXTRA_URL, url);
            args.putSerializable(EXTRA_URL_PARAM, params);
            args.putString(EXTRA_UNIQUE_ID, uniqueId != null ? uniqueId : FlutterBoostUtils.createUniqueId(url));
            return args;
        }

        /**
         * Constructs a new {@code FlutterFragment} (or a subclass) that is configured based on
         * properties set on this {@code CachedEngineFragmentBuilder}.
         */
        public <T extends FlutterBoostFragment> T build() {
            try {
                @SuppressWarnings("unchecked")
                T frag = (T) fragmentClass.getDeclaredConstructor().newInstance();
                if (frag == null) {
                    throw new RuntimeException(
                            "The FlutterFragment subclass sent in the constructor ("
                                    + fragmentClass.getCanonicalName()
                                    + ") does not match the expected return type.");
                }

                Bundle args = createArgs();
                frag.setArguments(args);

                return frag;
            } catch (Exception e) {
                throw new RuntimeException(
                        "Could not instantiate FlutterFragment subclass (" + fragmentClass.getName() + ")", e);
            }
        }
    }

}
