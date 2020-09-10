package com.idlefish.flutterboost.containers;


import android.annotation.SuppressLint;
import android.app.Activity;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;
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
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.view.*;
import android.widget.*;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.XFlutterView;
import com.idlefish.flutterboost.XPlatformPlugin;
import io.flutter.Log;
import io.flutter.embedding.android.DrawableSplashScreen;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.SplashScreen;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.plugin.platform.PlatformPlugin;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class BoostFlutterActivity extends Activity
        implements FlutterActivityAndFragmentDelegate.Host,
        LifecycleOwner {

    private static final String TAG = "NewBoostFlutterActivity";

    // Meta-data arguments, processed from manifest XML.
    protected static final String SPLASH_SCREEN_META_DATA_KEY = "io.flutter.embedding.android.SplashScreenDrawable";
    protected static final String NORMAL_THEME_META_DATA_KEY = "io.flutter.embedding.android.NormalTheme";

    // Intent extra arguments.
    protected static final String EXTRA_DART_ENTRYPOINT = "dart_entrypoint";
    protected static final String EXTRA_BACKGROUND_MODE = "background_mode";
    protected static final String EXTRA_DESTROY_ENGINE_WITH_ACTIVITY = "destroy_engine_with_activity";

    protected static final String EXTRA_URL = "url";
    protected static final String EXTRA_PARAMS = "params";


    // Default configuration.
    protected static final String DEFAULT_BACKGROUND_MODE = BackgroundMode.opaque.name();

    private static XPlatformPlugin sXPlatformPlugin;

    public static Intent createDefaultIntent(@NonNull Context launchContext) {
        return withNewEngine().build(launchContext);
    }


    public static NewEngineIntentBuilder withNewEngine() {
        return new NewEngineIntentBuilder(BoostFlutterActivity.class);
    }


    public static class NewEngineIntentBuilder {
        private final Class<? extends BoostFlutterActivity> activityClass;
        private String backgroundMode = DEFAULT_BACKGROUND_MODE;
        private String url = "";
        private Map params = new HashMap();


        public NewEngineIntentBuilder(@NonNull Class<? extends BoostFlutterActivity> activityClass) {
            this.activityClass = activityClass;
        }


        public NewEngineIntentBuilder url(@NonNull String url) {
            this.url = url;
            return this;
        }


        public NewEngineIntentBuilder params(@NonNull Map params) {
            this.params = params;
            return this;
        }


        public NewEngineIntentBuilder backgroundMode(@NonNull BackgroundMode backgroundMode) {
            this.backgroundMode = backgroundMode.name();
            return this;
        }


        public Intent build(@NonNull Context context) {

            SerializableMap serializableMap = new SerializableMap();
            serializableMap.setMap(params);

            return new Intent(context, activityClass)
                    .putExtra(EXTRA_BACKGROUND_MODE, backgroundMode)
                    .putExtra(EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, false)
                    .putExtra(EXTRA_URL, url)
                    .putExtra(EXTRA_PARAMS, serializableMap);
        }
    }

    public static class SerializableMap implements Serializable {

        private Map<String, Object> map;

        public Map<String, Object> getMap() {
            return map;
        }

        public void setMap(Map<String, Object> map) {
            this.map = map;
        }
    }

    private FlutterActivityAndFragmentDelegate delegate;

    @NonNull
    private LifecycleRegistry lifecycle;

    public BoostFlutterActivity() {
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
            return new DrawableSplashScreen(manifestSplashDrawable, ImageView.ScaleType.CENTER, 500L);
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
    @SuppressLint("WrongConstant")
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
    protected View createFlutterView() {
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


    }

    protected XFlutterView getFlutterView() {
        return delegate.getFlutterView();
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
        return FlutterBoost.instance().engineProvider();
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
    public XPlatformPlugin providePlatformPlugin(@NonNull FlutterEngine flutterEngine) {
        return BoostViewUtils.getPlatformPlugin(flutterEngine.getPlatformChannel());
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
    public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {

    }


    @Override
    public boolean shouldAttachEngineToActivity() {
        return true;
    }


    @Override
    public String getContainerUrl() {
        if (getIntent().hasExtra(EXTRA_URL)) {
            return getIntent().getStringExtra(EXTRA_URL);
        }
        return "";

    }

    @Override
    public Map getContainerUrlParams() {

        if (getIntent().hasExtra(EXTRA_PARAMS)) {
            SerializableMap serializableMap = (SerializableMap) getIntent().getSerializableExtra(EXTRA_PARAMS);
            return serializableMap.getMap();
        }

        Map<String, String> params = new HashMap<>();

        return params;
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
