package com.idlefish.flutterboost.containers;


import android.app.Activity;
import android.arch.lifecycle.Lifecycle;
import android.arch.lifecycle.LifecycleOwner;
import android.arch.lifecycle.Lifecycle;
import android.arch.lifecycle.LifecycleOwner;
import android.arch.lifecycle.LifecycleRegistry;
import android.arch.lifecycle.Lifecycle.Event;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.NewFlutterBoost;
import com.idlefish.flutterboost.Utils;
import io.flutter.Log;
import io.flutter.embedding.android.DrawableSplashScreen;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.SplashScreen;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.plugin.platform.PlatformPlugin;
import io.flutter.view.FlutterMain;

import java.util.HashMap;
import java.util.Map;

public class NewBoostFlutterActivity extends Activity
        implements FlutterActivityAndFragmentDelegate.Host,
        LifecycleOwner {

    private static final String TAG = "NewBoostFlutterActivity";

    // Meta-data arguments, processed from manifest XML.
    protected static final String DART_ENTRYPOINT_META_DATA_KEY = "io.flutter.Entrypoint";
    protected static final String INITIAL_ROUTE_META_DATA_KEY = "io.flutter.InitialRoute";
    protected static final String SPLASH_SCREEN_META_DATA_KEY = "io.flutter.embedding.android.SplashScreenDrawable";
    protected static final String NORMAL_THEME_META_DATA_KEY = "io.flutter.embedding.android.NormalTheme";

    // Intent extra arguments.
    protected static final String EXTRA_DART_ENTRYPOINT = "dart_entrypoint";
    protected static final String EXTRA_INITIAL_ROUTE = "initial_route";
    protected static final String EXTRA_BACKGROUND_MODE = "background_mode";
    protected static final String EXTRA_CACHED_ENGINE_ID = "cached_engine_id";
    protected static final String EXTRA_DESTROY_ENGINE_WITH_ACTIVITY = "destroy_engine_with_activity";

    // Default configuration.
    protected static final String DEFAULT_DART_ENTRYPOINT = "main";
    protected static final String DEFAULT_INITIAL_ROUTE = "/";
    protected static final String DEFAULT_BACKGROUND_MODE = BackgroundMode.opaque.name();


    public static Intent createDefaultIntent(@NonNull Context launchContext) {
        return withNewEngine().build(launchContext);
    }


    public static NewEngineIntentBuilder withNewEngine() {
        return new NewEngineIntentBuilder(NewBoostFlutterActivity.class);
    }


    public static class NewEngineIntentBuilder {
        private final Class<? extends NewBoostFlutterActivity> activityClass;
        private String dartEntrypoint = DEFAULT_DART_ENTRYPOINT;
        private String initialRoute = DEFAULT_INITIAL_ROUTE;
        private String backgroundMode = DEFAULT_BACKGROUND_MODE;
        private String url = "";
        private Map params = null;



        protected NewEngineIntentBuilder(@NonNull Class<? extends NewBoostFlutterActivity> activityClass) {
            this.activityClass = activityClass;
        }


        public NewEngineIntentBuilder dartEntrypoint(@NonNull String dartEntrypoint) {
            this.dartEntrypoint = dartEntrypoint;
            return this;
        }

        public NewEngineIntentBuilder url (@NonNull String url) {
            this.url = url;
            return this;
        }


        public NewEngineIntentBuilder params (@NonNull Map params) {
            this.params = params;
            return this;
        }

        public NewEngineIntentBuilder initialRoute(@NonNull String initialRoute) {
            this.initialRoute = initialRoute;
            return this;
        }


        public NewEngineIntentBuilder backgroundMode(@NonNull BackgroundMode backgroundMode) {
            this.backgroundMode = backgroundMode.name();
            return this;
        }


        public Intent build(@NonNull Context context) {
            return new Intent(context, activityClass)
                    .putExtra(EXTRA_DART_ENTRYPOINT, dartEntrypoint)
                    .putExtra(EXTRA_INITIAL_ROUTE, initialRoute)
                    .putExtra(EXTRA_BACKGROUND_MODE, backgroundMode)
                    .putExtra(EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, false)
                    .putExtra("url", url)
                    .putExtra("params", (HashMap)params);
        }
    }



    private FlutterActivityAndFragmentDelegate delegate;

    @NonNull
    private LifecycleRegistry lifecycle;

    public NewBoostFlutterActivity() {
        lifecycle = new LifecycleRegistry(this);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        switchLaunchThemeForNormalTheme();

        super.onCreate(savedInstanceState);

        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_CREATE);

        delegate = new FlutterActivityAndFragmentDelegate(this);
        delegate.onAttach(this);

        configureWindowForTransparency();
        setContentView(createFlutterView());
        configureStatusBarForFullscreenFlutterExperience();
    }


    private void switchLaunchThemeForNormalTheme() {
        try {
            ActivityInfo activityInfo = getPackageManager().getActivityInfo(getComponentName(), PackageManager.GET_META_DATA);
            if (activityInfo.metaData != null) {
                int normalThemeRID = activityInfo.metaData.getInt(NORMAL_THEME_META_DATA_KEY, -1);
                if (normalThemeRID != -1) {
                    setTheme(normalThemeRID);
                }
            } else {
                Log.d(TAG, "Using the launch theme as normal theme.");
            }
        } catch (PackageManager.NameNotFoundException exception) {
            Log.e(TAG, "Could not read meta-data for FlutterActivity. Using the launch theme as normal theme.");
        }
    }

    @Nullable
    @Override
    public SplashScreen provideSplashScreen() {
        Drawable manifestSplashDrawable = getSplashScreenFromManifest();
        if (manifestSplashDrawable != null) {
            return new DrawableSplashScreen(manifestSplashDrawable);
        } else {
            return null;
        }
    }

    /**
     * Returns a {@link Drawable} to be used as a splash screen as requested by meta-data in the
     * {@code AndroidManifest.xml} file, or null if no such splash screen is requested.
     * <p>
     * See {@link #SPLASH_SCREEN_META_DATA_KEY} for the meta-data key to be used in a
     * manifest file.
     */
    @Nullable
    @SuppressWarnings("deprecation")
    private Drawable getSplashScreenFromManifest() {
        try {
            ActivityInfo activityInfo = getPackageManager().getActivityInfo(
                    getComponentName(),
                    PackageManager.GET_META_DATA | PackageManager.GET_ACTIVITIES
            );
            Bundle metadata = activityInfo.metaData;
            Integer splashScreenId = metadata != null ? metadata.getInt(SPLASH_SCREEN_META_DATA_KEY) : null;
            return splashScreenId != null
                    ? Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP
                    ? getResources().getDrawable(splashScreenId, getTheme())
                    : getResources().getDrawable(splashScreenId)
                    : null;
        } catch (PackageManager.NameNotFoundException e) {
            // This is never expected to happen.
            return null;
        }
    }

    /**
     * Sets this {@code Activity}'s {@code Window} background to be transparent, and hides the status
     * bar, if this {@code Activity}'s desired {@link BackgroundMode} is {@link BackgroundMode#transparent}.
     * <p>
     * For {@code Activity} transparency to work as expected, the theme applied to this {@code Activity}
     * must include {@code <item name="android:windowIsTranslucent">true</item>}.
     */
    private void configureWindowForTransparency() {
        BackgroundMode backgroundMode = getBackgroundMode();
        if (backgroundMode == BackgroundMode.transparent) {
            getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
            getWindow().setFlags(
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            );
        }
    }

    @NonNull
    private View createFlutterView() {
        return delegate.onCreateView(
                null /* inflater */,
                null /* container */,
                null /* savedInstanceState */);
    }

    private void configureStatusBarForFullscreenFlutterExperience() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
            window.getDecorView().setSystemUiVisibility(PlatformPlugin.DEFAULT_SYSTEM_UI);
        }
        Utils.setStatusBarLightMode(this,true);

    }

    @Override
    protected void onStart() {
        super.onStart();
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_START);
        delegate.onStart();
    }

    @Override
    protected void onResume() {
        super.onResume();
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
        delegate.onResume();
    }

    @Override
    public void onPostResume() {
        super.onPostResume();
        delegate.onPostResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        delegate.onPause();
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE);
    }

    @Override
    protected void onStop() {
        super.onStop();
        delegate.onStop();
//        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_STOP);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        delegate.onDestroyView();
        delegate.onDetach();
//        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        delegate.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        // TODO(mattcarroll): change G3 lint rule that forces us to call super
        super.onNewIntent(intent);
        delegate.onNewIntent(intent);
    }

    @Override
    public void onBackPressed() {
        delegate.onBackPressed();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        delegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public void onUserLeaveHint() {
        delegate.onUserLeaveHint();
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        delegate.onTrimMemory(level);
    }

    /**
     * {@link FlutterActivityAndFragmentDelegate.Host} method that is used by
     * {@link FlutterActivityAndFragmentDelegate} to obtain a {@code Context} reference as
     * needed.
     */
    @Override
    @NonNull
    public Context getContext() {
        return this;
    }

    /**
     * {@link FlutterActivityAndFragmentDelegate.Host} method that is used by
     * {@link FlutterActivityAndFragmentDelegate} to obtain an {@code Activity} reference as
     * needed. This reference is used by the delegate to instantiate a {@link FlutterView},
     * a {@link PlatformPlugin}, and to determine if the {@code Activity} is changing
     * configurations.
     */
    @Override
    @NonNull
    public Activity getActivity() {
        return this;
    }

    /**
     * {@link FlutterActivityAndFragmentDelegate.Host} method that is used by
     * {@link FlutterActivityAndFragmentDelegate} to obtain a {@code Lifecycle} reference as
     * needed. This reference is used by the delegate to provide Flutter plugins with access
     * to lifecycle events.
     */
    @Override
    @NonNull
    public Lifecycle getLifecycle() {
        return lifecycle;
    }

    /**
     * {@link FlutterActivityAndFragmentDelegate.Host} method that is used by
     * {@link FlutterActivityAndFragmentDelegate} to obtain Flutter shell arguments when
     * initializing Flutter.
     */
    @NonNull
    @Override
    public FlutterShellArgs getFlutterShellArgs() {
        return FlutterShellArgs.fromIntent(getIntent());
    }

    /**
     * Returns the ID of a statically cached {@link FlutterEngine} to use within this
     * {@code FlutterActivity}, or {@code null} if this {@code FlutterActivity} does not want to
     * use a cached {@link FlutterEngine}.
     */
    @Override
    @Nullable
    public String getCachedEngineId() {
        return getIntent().getStringExtra(EXTRA_CACHED_ENGINE_ID);
    }

    /**
     * Returns false if the {@link FlutterEngine} backing this {@code FlutterActivity} should
     * outlive this {@code FlutterActivity}, or true to be destroyed when the {@code FlutterActivity}
     * is destroyed.
     * <p>
     * The default value is {@code true} in cases where {@code FlutterActivity} created its own
     * {@link FlutterEngine}, and {@code false} in cases where a cached {@link FlutterEngine} was
     * provided.
     */
    @Override
    public boolean shouldDestroyEngineWithHost() {
        return getIntent().getBooleanExtra(EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, false);
    }

    /**
     * The Dart entrypoint that will be executed as soon as the Dart snapshot is loaded.
     * <p>
     * This preference can be controlled with 2 methods:
     * <ol>
     * <li>Pass a {@code String} as {@link #EXTRA_DART_ENTRYPOINT} with the launching {@code Intent}, or</li>
     * <li>Set a {@code <meta-data>} called {@link #DART_ENTRYPOINT_META_DATA_KEY} for this
     * {@code Activity} in the Android manifest.</li>
     * </ol>
     * If both preferences are set, the {@code Intent} preference takes priority.
     * <p>
     * The reason that a {@code <meta-data>} preference is supported is because this {@code Activity}
     * might be the very first {@code Activity} launched, which means the developer won't have
     * control over the incoming {@code Intent}.
     * <p>
     * Subclasses may override this method to directly control the Dart entrypoint.
     */
    @NonNull
    public String getDartEntrypointFunctionName() {
        if (getIntent().hasExtra(EXTRA_DART_ENTRYPOINT)) {
            return getIntent().getStringExtra(EXTRA_DART_ENTRYPOINT);
        }

        try {
            ActivityInfo activityInfo = getPackageManager().getActivityInfo(
                    getComponentName(),
                    PackageManager.GET_META_DATA | PackageManager.GET_ACTIVITIES
            );
            Bundle metadata = activityInfo.metaData;
            String desiredDartEntrypoint = metadata != null ? metadata.getString(DART_ENTRYPOINT_META_DATA_KEY) : null;
            return desiredDartEntrypoint != null ? desiredDartEntrypoint : DEFAULT_DART_ENTRYPOINT;
        } catch (PackageManager.NameNotFoundException e) {
            return DEFAULT_DART_ENTRYPOINT;
        }
    }

    /**
     * The initial route that a Flutter app will render upon loading and executing its Dart code.
     * <p>
     * This preference can be controlled with 2 methods:
     * <ol>
     * <li>Pass a boolean as {@link #EXTRA_INITIAL_ROUTE} with the launching {@code Intent}, or</li>
     * <li>Set a {@code <meta-data>} called {@link #INITIAL_ROUTE_META_DATA_KEY} for this
     * {@code Activity} in the Android manifest.</li>
     * </ol>
     * If both preferences are set, the {@code Intent} preference takes priority.
     * <p>
     * The reason that a {@code <meta-data>} preference is supported is because this {@code Activity}
     * might be the very first {@code Activity} launched, which means the developer won't have
     * control over the incoming {@code Intent}.
     * <p>
     * Subclasses may override this method to directly control the initial route.
     */
    @NonNull
    public String getInitialRoute() {
        if (getIntent().hasExtra(EXTRA_INITIAL_ROUTE)) {
            return getIntent().getStringExtra(EXTRA_INITIAL_ROUTE);
        }

        try {
            ActivityInfo activityInfo = getPackageManager().getActivityInfo(
                    getComponentName(),
                    PackageManager.GET_META_DATA | PackageManager.GET_ACTIVITIES
            );
            Bundle metadata = activityInfo.metaData;
            String desiredInitialRoute = metadata != null ? metadata.getString(INITIAL_ROUTE_META_DATA_KEY) : null;
            return desiredInitialRoute != null ? desiredInitialRoute : DEFAULT_INITIAL_ROUTE;
        } catch (PackageManager.NameNotFoundException e) {
            return DEFAULT_INITIAL_ROUTE;
        }
    }

    /**
     * The path to the bundle that contains this Flutter app's resources, e.g., Dart code snapshots.
     * <p>
     * When this {@code FlutterActivity} is run by Flutter tooling and a data String is included
     * in the launching {@code Intent}, that data String is interpreted as an app bundle path.
     * <p>
     * By default, the app bundle path is obtained from {@link FlutterMain#findAppBundlePath()}.
     * <p>
     * Subclasses may override this method to return a custom app bundle path.
     */
    @NonNull
    public String getAppBundlePath() {
        // If this Activity was launched from tooling, and the incoming Intent contains
        // a custom app bundle path, return that path.
        // TODO(mattcarroll): determine if we should have an explicit FlutterTestActivity instead of conflating.
        if (isDebuggable() && Intent.ACTION_RUN.equals(getIntent().getAction())) {
            String appBundlePath = getIntent().getDataString();
            if (appBundlePath != null) {
                return appBundlePath;
            }
        }

        // Return the default app bundle path.
        // TODO(mattcarroll): move app bundle resolution into an appropriately named class.
        return FlutterMain.findAppBundlePath();
    }

    /**
     * Returns true if Flutter is running in "debug mode", and false otherwise.
     * <p>
     * Debug mode allows Flutter to operate with hot reload and hot restart. Release mode does not.
     */
    private boolean isDebuggable() {
        return (getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
    }

    /**
     * {@link FlutterActivityAndFragmentDelegate.Host} method that is used by
     * {@link FlutterActivityAndFragmentDelegate} to obtain the desired {@link FlutterView.RenderMode}
     * that should be used when instantiating a {@link FlutterView}.
     */
    @NonNull
    @Override
    public FlutterView.RenderMode getRenderMode() {
        return getBackgroundMode() == BackgroundMode.opaque
                ? FlutterView.RenderMode.surface
                : FlutterView.RenderMode.texture;
    }

    /**
     * {@link FlutterActivityAndFragmentDelegate.Host} method that is used by
     * {@link FlutterActivityAndFragmentDelegate} to obtain the desired
     * {@link FlutterView.TransparencyMode} that should be used when instantiating a
     * {@link FlutterView}.
     */
    @NonNull
    @Override
    public FlutterView.TransparencyMode getTransparencyMode() {
        return getBackgroundMode() == BackgroundMode.opaque
                ? FlutterView.TransparencyMode.opaque
                : FlutterView.TransparencyMode.transparent;
    }

    /**
     * The desired window background mode of this {@code Activity}, which defaults to
     * {@link BackgroundMode#opaque}.
     */
    @NonNull
    protected BackgroundMode getBackgroundMode() {
        if (getIntent().hasExtra(EXTRA_BACKGROUND_MODE)) {
            return BackgroundMode.valueOf(getIntent().getStringExtra(EXTRA_BACKGROUND_MODE));
        } else {
            return BackgroundMode.opaque;
        }
    }

    /**
     * Hook for subclasses to easily provide a custom {@link FlutterEngine}.
     * <p>
     * This hook is where a cached {@link FlutterEngine} should be provided, if a cached
     * {@link FlutterEngine} is desired.
     */
    @Nullable
    @Override
    public FlutterEngine provideFlutterEngine(@NonNull Context context) {
        // No-op. Hook for subclasses.
        return NewFlutterBoost.instance().engineProvider().provideEngine(this);
    }

    /**
     * Hook for subclasses to obtain a reference to the {@link FlutterEngine} that is owned
     * by this {@code FlutterActivity}.
     */
    @Nullable
    protected FlutterEngine getFlutterEngine() {
        return delegate.getFlutterEngine();
    }

    @Nullable
    @Override
    public PlatformPlugin providePlatformPlugin(@Nullable Activity activity, @NonNull FlutterEngine flutterEngine) {
        if (activity != null) {
            return new PlatformPlugin(getActivity(), flutterEngine.getPlatformChannel());
        } else {
            return null;
        }
    }

    /**
     * Hook for subclasses to easily configure a {@code FlutterEngine}, e.g., register
     * plugins.
     * <p>
     * This method is called after {@link #provideFlutterEngine(Context)}.
     */
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // No-op. Hook for subclasses.
    }


    @Override
    public boolean shouldAttachEngineToActivity() {
        return true;
    }

    @Override
    public void onFirstFrameRendered() {
    }

    /**
     * The mode of the background of a {@code FlutterActivity}, either opaque or transparent.
     */
    public enum BackgroundMode {
        /**
         * Indicates a FlutterActivity with an opaque background. This is the default.
         */
        opaque,
        /**
         * Indicates a FlutterActivity with a transparent background.
         */
        transparent
    }


}
