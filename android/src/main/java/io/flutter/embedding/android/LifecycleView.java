package io.flutter.embedding.android;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivityAndFragmentDelegate;
import io.flutter.embedding.android.FlutterEngineProvider;
import io.flutter.embedding.android.FlutterSurfaceView;
import io.flutter.embedding.android.FlutterTextureView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.android.SplashScreen;
import io.flutter.embedding.android.TransparencyMode;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener;
import io.flutter.plugin.platform.PlatformPlugin;
import io.flutter.view.FlutterMain;

import com.idlefish.flutterboost.containers.ActivityAndFragmentPatch;
import com.idlefish.flutterboost.containers.ContainerShadowNode;
import com.idlefish.flutterboost.containers.FlutterViewContainer;
import com.idlefish.flutterboost.containers.FlutterViewContainerObserver;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_UNIQUE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL_PARAM;
import com.idlefish.flutterboost.FlutterBoost;

public class LifecycleView extends FrameLayout implements LifecycleOwner, FlutterActivityAndFragmentDelegate.Host, FlutterViewContainer {
  protected static final String ARG_DART_ENTRYPOINT = "dart_entrypoint";
  protected static final String ARG_INITIAL_ROUTE = "initial_route";
  protected static final String ARG_APP_BUNDLE_PATH = "app_bundle_path";
  protected static final String ARG_FLUTTER_INITIALIZATION_ARGS = "initialization_args";
  protected static final String ARG_FLUTTERVIEW_RENDER_MODE = "flutterview_render_mode";
  protected static final String ARG_FLUTTERVIEW_TRANSPARENCY_MODE = "flutterview_transparency_mode";
  protected static final String ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY = "should_attach_engine_to_activity";
  protected static final String ARG_CACHED_ENGINE_ID = "cached_engine_id";
  protected static final String ARG_DESTROY_ENGINE_WITH_FRAGMENT = "destroy_engine_with_fragment";
  protected static final String ARG_ENABLE_STATE_RESTORATION = "enable_state_restoration";

  private Activity mActivty;
  private View mFlutterView;
  private Bundle mArguments;
  private Callback mCallback;
  private FlutterActivityAndFragmentDelegate delegate;
  private LifecycleRegistry mLifecycleRegistry = new LifecycleRegistry(this);
  private FlutterViewContainerObserver observer;


  @NonNull
  public static CachedEngineLifecycleViewBuilder withCachedEngine(@NonNull String engineId) {
    return new CachedEngineLifecycleViewBuilder(engineId);
  }


  public static class CachedEngineLifecycleViewBuilder {
    private final String engineId;
    private RenderMode renderMode = RenderMode.texture;
    private TransparencyMode transparencyMode = TransparencyMode.transparent;
    private boolean shouldAttachEngineToActivity = true;
    private String url;
    private HashMap<String, String> urlParam;

    private CachedEngineLifecycleViewBuilder(@NonNull String engineId) {
      this.engineId = engineId;
    }

    @NonNull
    public CachedEngineLifecycleViewBuilder renderMode(@NonNull RenderMode renderMode) {
      this.renderMode = renderMode;
      return this;
    }

    @NonNull
    public CachedEngineLifecycleViewBuilder transparencyMode(
        @NonNull TransparencyMode transparencyMode) {
      this.transparencyMode = transparencyMode;
      return this;
    }

    @NonNull
    public CachedEngineLifecycleViewBuilder shouldAttachEngineToActivity(
        boolean shouldAttachEngineToActivity) {
      this.shouldAttachEngineToActivity = shouldAttachEngineToActivity;
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
      args.putBoolean(ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY, shouldAttachEngineToActivity);
      args.putString(EXTRA_URL, url);
      args.putSerializable(EXTRA_URL_PARAM, urlParam);
      args.putString(EXTRA_UNIQUE_ID, FlutterBoost.generateUniqueId(url));
      return args;
    }

    public LifecycleView build(Activity context) {
      return build(context, null);
    }

    @NonNull
    public LifecycleView build(Activity context, Callback callback) {
      LifecycleView view = new LifecycleView(context, callback);
      Bundle args = createArgs();
      view.setArguments(args);
      view.onCreate();
      view.onStart();
      return view;
    }

    @NonNull
    public CachedEngineLifecycleViewBuilder url(
        @NonNull String url) {
      this.url = url;
      return this;
    }

    @NonNull
    public CachedEngineLifecycleViewBuilder params(@NonNull HashMap<String, String> param) {
      this.urlParam = param;
      return this;
    }
  }

  private LifecycleView(Activity context, Callback callback) {
    super(context);
    mActivty = context;
    mCallback = callback;
  }

  void setArguments(Bundle args) {
    mArguments = args;
  }

  public Bundle getArguments() {
    return mArguments;
  }

  private FlutterView findFlutterView(View view) {
    if (view instanceof ViewGroup) {
      ViewGroup vp = (ViewGroup) view;
      for (int i = 0; i < vp.getChildCount(); i++) {
        View child = vp.getChildAt(i);
        if (child instanceof FlutterView) {
          return (FlutterView) child;
        } else {
          return findFlutterView(child);
        }
      }
    }
    return null;
  }

  public void onCreate() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE);
    delegate = new FlutterActivityAndFragmentDelegate(this);
    delegate.onAttach(getContext());
    mFlutterView = delegate.onCreateView(null, null, null);
    addView(mFlutterView);
    observer = ContainerShadowNode.create(this);
    observer.onCreateView();
  }

  public void onStart() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START);
    delegate.onStart();
  }

  public void onResume() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
    delegate.onResume();
    ActivityAndFragmentPatch.setStackTop(this);
    ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(findFlutterView(mFlutterView), getFlutterEngine(), this);
    observer.onAppear();
  }

  public void onPause() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE);
    delegate.onPause();
    ActivityAndFragmentPatch.removeStackTop(this);
    ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(findFlutterView(mFlutterView), getFlutterEngine());
    observer.onDisappear();
  }

  public void onStop() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP);
    // delegate.onStop();
  }

  public void onDestroy() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY);
    removeView(mFlutterView);
    delegate.onDestroyView();
    delegate = null;
    mFlutterView = null;
    observer.onDestroyView();
  }

  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    try {
        delegate.onActivityResult(requestCode, resultCode, data);
    } catch (Exception e) {
        e.printStackTrace();
    }
  }

  public void onBackPressed() {
    delegate.onBackPressed();
  }


  @Nullable
  protected FlutterEngine getFlutterEngine() {
    return delegate.getFlutterEngine();
  }

  /**
   * /////////////////////////////////////////////
   * FlutterActivityAndFragmentDelegate.Host
   * /////////////////////////////////////////////
   */
  @Nullable
  public Activity getActivity() {
    return mActivty;
  }

  @NonNull
  public Lifecycle getLifecycle() {
    return mLifecycleRegistry;
  }

  @NonNull
  public FlutterShellArgs getFlutterShellArgs() {
    String[] flutterShellArgsArray = getArguments().getStringArray(ARG_FLUTTER_INITIALIZATION_ARGS);
    return new FlutterShellArgs(
        flutterShellArgsArray != null ? flutterShellArgsArray : new String[] {});
  }

  @Nullable
  public String getCachedEngineId() {
    return getArguments().getString(ARG_CACHED_ENGINE_ID, null);
  }

  public boolean shouldDestroyEngineWithHost() {
    return false;
  }

  @NonNull
  public String getDartEntrypointFunctionName() {
    return getArguments().getString(ARG_DART_ENTRYPOINT, "main");
  }

  @NonNull
  public String getAppBundlePath() {
    return getArguments().getString(ARG_APP_BUNDLE_PATH, FlutterMain.findAppBundlePath());
  }

  @Nullable
  public String getInitialRoute() {
    return getArguments().getString(ARG_INITIAL_ROUTE);
  }

  @NonNull
  public RenderMode getRenderMode() {
    String renderModeName =
    getArguments().getString(ARG_FLUTTERVIEW_RENDER_MODE, RenderMode.surface.name());
    return RenderMode.valueOf(renderModeName);
  }

  @NonNull
  public TransparencyMode getTransparencyMode() {
    String transparencyModeName =
        getArguments()
            .getString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, TransparencyMode.transparent.name());
    return TransparencyMode.valueOf(transparencyModeName);
  }

  @Nullable
  public SplashScreen provideSplashScreen() {
    return null;
  }

  @Nullable
  public FlutterEngine provideFlutterEngine(@NonNull Context context) {
    FlutterEngine flutterEngine = null;
    Activity attachedActivity = getActivity();
    if (attachedActivity instanceof FlutterEngineProvider) {
      FlutterEngineProvider flutterEngineProvider = (FlutterEngineProvider) attachedActivity;
      flutterEngine = flutterEngineProvider.provideFlutterEngine(getContext());
    }

    return flutterEngine;
  }

  @Nullable
  public PlatformPlugin providePlatformPlugin(
      @Nullable Activity activity, @NonNull FlutterEngine flutterEngine) {
    if (activity != null) {
      return new PlatformPlugin(getActivity(), flutterEngine.getPlatformChannel());
    } else {
      return null;
    }
  }

  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

  }

  public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {

  }

  public boolean shouldAttachEngineToActivity() {
    return getArguments().getBoolean(ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY);
  }

  public void onFlutterSurfaceViewCreated(@NonNull FlutterSurfaceView flutterSurfaceView) {
    // Hook for subclasses.
  }

  public void onFlutterTextureViewCreated(@NonNull FlutterTextureView flutterTextureView) {
    // Hook for subclasses.
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

  public boolean shouldRestoreAndSaveState() {
    if (getArguments().containsKey(ARG_ENABLE_STATE_RESTORATION)) {
      return getArguments().getBoolean(ARG_ENABLE_STATE_RESTORATION);
    }
    if (getCachedEngineId() != null) {
      return false;
    }
    return true;
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
