package io.flutter.embedding.android;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

import com.idlefish.flutterboost.FlutterBoostUtils;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.plugin.platform.PlatformPlugin;
import io.flutter.view.FlutterMain;

public class LifecycleView extends FrameLayout implements LifecycleOwner, FlutterActivityAndFragmentDelegate.Host {
  protected static final String ARG_DART_ENTRYPOINT = "dart_entrypoint";
  protected static final String ARG_INITIAL_ROUTE = "initial_route";
  protected static final String ARG_APP_BUNDLE_PATH = "app_bundle_path";
  protected static final String ARG_FLUTTER_INITIALIZATION_ARGS = "initialization_args";
  protected static final String ARG_FLUTTERVIEW_RENDER_MODE = "flutterview_render_mode";
  protected static final String ARG_FLUTTERVIEW_TRANSPARENCY_MODE = "flutterview_transparency_mode";
  protected static final String ARG_CACHED_ENGINE_ID = "cached_engine_id";

  private final Activity mActivty;
  private View mView;
  private FlutterView mFlutterView;
  private Bundle mArguments;
  private FlutterActivityAndFragmentDelegate mDelegate;
  private PlatformPlugin platformPlugin;
  private LifecycleRegistry mLifecycleRegistry = new LifecycleRegistry(this);

  public LifecycleView(Activity context) {
    super(context);
    mActivty = context;
  }

  public void setArguments(Bundle args) {
    mArguments = args;
  }

  public Bundle getArguments() {
    return mArguments;
  }

  public FlutterView flutterView() {
    return mFlutterView;
  }

  public void onCreate() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE);
    mDelegate = new FlutterActivityAndFragmentDelegate(this);
    mDelegate.onAttach(getContext());
    mView = mDelegate.onCreateView(null, null, null, 0, false);
    addView(mView);
    mFlutterView = FlutterBoostUtils.findFlutterView(mView);
  }

  public void onStart() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START);
    mDelegate.onStart();
  }

  public void onResume() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
    platformPlugin = new PlatformPlugin(getActivity(), getFlutterEngine().getPlatformChannel());
    mDelegate.onResume();
  }

  public void onPause() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE);
    platformPlugin = null;
    mDelegate.onPause();
  }

  public void onStop() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP);
    // delegate.onStop();
  }

  public void onDestroy() {
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY);
    mDelegate.onDestroyView();
    removeView(mView);
    mDelegate = null;
    mView = null;
  }

  @Nullable
  protected FlutterEngine getFlutterEngine() {
    return mDelegate.getFlutterEngine();
  }

  /**
   * /////////////////////////////////////////////
   * FlutterActivityAndFragmentDelegate.Host
   * /////////////////////////////////////////////
   */
  public void detachFromFlutterEngine() {
    // Do nothing
  }

  public boolean shouldHandleDeeplinking() { return false; }
  public boolean popSystemNavigator() { return false; }

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
    return null;
  }

  @Nullable
  public PlatformPlugin providePlatformPlugin(
      @Nullable Activity activity, @NonNull FlutterEngine flutterEngine) {
    return null;
  }

  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
  }

  public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {
  }

  public boolean shouldAttachEngineToActivity() {
    return true;
  }

  public boolean shouldRestoreAndSaveState() {
    return false;
  }

  public void onFlutterSurfaceViewCreated(@NonNull FlutterSurfaceView flutterSurfaceView) {
    // Hook for subclasses.
  }

  public void onFlutterTextureViewCreated(@NonNull FlutterTextureView flutterTextureView) {
    // Hook for subclasses.
  }

  public void onFlutterUiDisplayed() {
    // Hook for subclasses.
  }

  public void onFlutterUiNoLongerDisplayed() {
    // Hook for subclasses.
  }
}
