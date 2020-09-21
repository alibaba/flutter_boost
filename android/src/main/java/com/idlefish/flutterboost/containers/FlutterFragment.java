package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.graphics.Color;
import android.view.*;
import androidx.lifecycle.Lifecycle;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.XFlutterView;
import com.idlefish.flutterboost.XPlatformPlugin;
import io.flutter.embedding.android.*;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;

import java.util.HashMap;
import java.util.Map;


public class FlutterFragment extends Fragment implements FlutterActivityAndFragmentDelegate.Host {

    private static final String TAG = "NewFlutterFragment";

    /**
     * The Dart entrypoint method name that is executed upon initialization.
     */
    protected static final String ARG_DART_ENTRYPOINT = "dart_entrypoint";
    /**
     * Initial Flutter route that is rendered in a Navigator widget.
     */
    protected static final String ARG_INITIAL_ROUTE = "initial_route";
    /**
     * Path to Flutter's Dart code.
     */
    protected static final String ARG_APP_BUNDLE_PATH = "app_bundle_path";
    /**
     * Flutter shell arguments.
     */
    protected static final String ARG_FLUTTER_INITIALIZATION_ARGS = "initialization_args";
    /**
     * {@link FlutterView.RenderMode} to be used for the {@link FlutterView} in this
     * {@code NewFlutterFragment}
     */
    protected static final String ARG_FLUTTERVIEW_RENDER_MODE = "flutterview_render_mode";
    /**
     * {@link FlutterView.TransparencyMode} to be used for the {@link FlutterView} in this
     * {@code NewFlutterFragment}
     */
    protected static final String ARG_FLUTTERVIEW_TRANSPARENCY_MODE = "flutterview_transparency_mode";
    /**
     * See {@link #shouldAttachEngineToActivity()}.
     */
    protected static final String ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY = "should_attach_engine_to_activity";
    /**
     * the created {@code NewFlutterFragment}.
     */
    protected static final String ARG_CACHED_ENGINE_ID = "cached_engine_id";
    /**
     * True if the {@link FlutterEngine} in the created {@code NewFlutterFragment} should be destroyed
     * when the {@code NewFlutterFragment} is destroyed, false if the {@link FlutterEngine} should
     * outlive the {@code NewFlutterFragment}.
     */
    protected static final String ARG_DESTROY_ENGINE_WITH_FRAGMENT = "destroy_engine_with_fragment";


    protected static final String EXTRA_URL = "url";
    protected static final String EXTRA_PARAMS = "params";


    /**
     * Creates a {@code NewFlutterFragment} with a default configuration.
     * <p>
     * {@code NewFlutterFragment}'s default configuration creates a new {@link FlutterEngine} within
     * the {@code NewFlutterFragment} and uses the following settings:
     * <ul>
     * <li>Dart entrypoint: "main"</li>
     * <li>Initial route: "/"</li>
     * <li>Render mode: surface</li>
     * <li>Transparency mode: transparent</li>
     * </ul>
     * <p>
     * To use a new {@link FlutterEngine} with different settings, use {@link #withNewEngine()}.
     * <p>
     * To use a cached {@link FlutterEngine} instead of creating a new one, use
     */
    @NonNull
    public static FlutterFragment createDefault() {
        return new NewEngineFragmentBuilder().build();
    }

    /**
     * Returns a {@link NewEngineFragmentBuilder} to create a {@code NewFlutterFragment} with a new
     * {@link FlutterEngine} and a desired engine configuration.
     */
    @NonNull
    public static NewEngineFragmentBuilder withNewEngine() {
        return new NewEngineFragmentBuilder();
    }


    public static class NewEngineFragmentBuilder {
        private final Class<? extends FlutterFragment> fragmentClass;

        private FlutterShellArgs shellArgs = null;
        private FlutterView.RenderMode renderMode = FlutterView.RenderMode.surface;
        private FlutterView.TransparencyMode transparencyMode = FlutterView.TransparencyMode.transparent;
        private boolean shouldAttachEngineToActivity = true;
        private String url = "";
        private Map params = new HashMap();

        /**
         * Constructs a {@code NewEngineFragmentBuilder} that is configured to construct an instance of
         * {@code NewFlutterFragment}.
         */
        public NewEngineFragmentBuilder() {
            fragmentClass = FlutterFragment.class;
        }

        /**
         * Constructs a {@code NewEngineFragmentBuilder} that is configured to construct an instance of
         * {@code subclass}, which extends {@code NewFlutterFragment}.
         */
        public NewEngineFragmentBuilder(@NonNull Class<? extends FlutterFragment> subclass) {
            fragmentClass = subclass;
        }


        /**
         * Any special configuration arguments for the Flutter engine
         */
        @NonNull
        public NewEngineFragmentBuilder flutterShellArgs(@NonNull FlutterShellArgs shellArgs) {
            this.shellArgs = shellArgs;
            return this;
        }

        /**
         * Render Flutter either as a {@link FlutterView.RenderMode#surface} or a
         * {@link FlutterView.RenderMode#texture}. You should use {@code surface} unless
         * you have a specific reason to use {@code texture}. {@code texture} comes with
         * a significant performance impact, but {@code texture} can be displayed
         * beneath other Android {@code View}s and animated, whereas {@code surface}
         * cannot.
         */
        @NonNull
        public NewEngineFragmentBuilder renderMode(@NonNull FlutterView.RenderMode renderMode) {
            this.renderMode = renderMode;
            return this;
        }

        public NewEngineFragmentBuilder url(@NonNull String url) {
            this.url = url;
            return this;
        }


        public NewEngineFragmentBuilder params(@NonNull Map params) {
            this.params = params;
            return this;
        }

        /**
         * Support a {@link FlutterView.TransparencyMode#transparent} background within {@link FlutterView},
         * or force an {@link FlutterView.TransparencyMode#opaque} background.
         * <p>
         * See {@link FlutterView.TransparencyMode} for implications of this selection.
         */
        @NonNull
        public NewEngineFragmentBuilder transparencyMode(@NonNull FlutterView.TransparencyMode transparencyMode) {
            this.transparencyMode = transparencyMode;
            return this;
        }


        @NonNull
        protected Bundle createArgs() {
            Bundle args = new Bundle();

            // TODO(mattcarroll): determine if we should have an explicit FlutterTestFragment instead of conflating.
            if (null != shellArgs) {
                args.putStringArray(ARG_FLUTTER_INITIALIZATION_ARGS, shellArgs.toArray());
            }

            BoostFlutterActivity.SerializableMap serializableMap = new BoostFlutterActivity.SerializableMap();
            serializableMap.setMap(params);

            args.putString(EXTRA_URL, url);
            args.putSerializable(EXTRA_PARAMS, serializableMap);
            args.putString(ARG_FLUTTERVIEW_RENDER_MODE, renderMode != null ? renderMode.name() : FlutterView.RenderMode.surface.name());
            args.putString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, transparencyMode != null ? transparencyMode.name() : FlutterView.TransparencyMode.transparent.name());
            args.putBoolean(ARG_DESTROY_ENGINE_WITH_FRAGMENT, true);


            return args;
        }

        /**
         * Constructs a new {@code NewFlutterFragment} (or a subclass) that is configured based on
         * properties set on this {@code Builder}.
         */
        @NonNull
        public <T extends FlutterFragment> T build() {
            try {
                @SuppressWarnings("unchecked")
                T frag = (T) fragmentClass.getDeclaredConstructor().newInstance();
                if (frag == null) {
                    throw new RuntimeException("The NewFlutterFragment subclass sent in the constructor ("
                            + fragmentClass.getCanonicalName() + ") does not match the expected return type.");
                }

                Bundle args = createArgs();
                frag.setArguments(args);

                return frag;
            } catch (Exception e) {
                throw new RuntimeException("Could not instantiate NewFlutterFragment subclass (" + fragmentClass.getName() + ")", e);
            }
        }
    }


    // Delegate that runs all lifecycle and OS hook logic that is common between
    // FlutterActivity and NewFlutterFragment. See the FlutterActivityAndFragmentDelegate
    // implementation for details about why it exists.
    private FlutterActivityAndFragmentDelegate delegate;


    protected XFlutterView getFlutterView() {
        return delegate.getFlutterView();
    }

    public FlutterFragment() {
        // Ensure that we at least have an empty Bundle of arguments so that we don't
        // need to continually check for null arguments before grabbing one.
        setArguments(new Bundle());
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        delegate = new FlutterActivityAndFragmentDelegate(this);
        delegate.onAttach(context);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return delegate.onCreateView(inflater, container, savedInstanceState);
    }


    @Override
    public void onStart() {
        super.onStart();
        if (!isHidden()) {
            delegate.onStart();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (!isHidden()) {
            delegate.onResume();
        }

    }

    // TODO(mattcarroll): determine why this can't be in onResume(). Comment reason, or move if possible.
    @ActivityCallThrough
    public void onPostResume() {
        delegate.onPostResume();
    }

    @Override
    public void onPause() {
        super.onPause();
        if (!isHidden()) {
            delegate.onPause();
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        if (!isHidden()) {
            delegate.onStop();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        delegate.onDestroyView();
    }

    @Override
    public void onDetach() {
        super.onDetach();
        delegate.onDetach();
        delegate.release();
        delegate = null;
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        if (hidden) {
            delegate.onPause();
        } else {
            delegate.onResume();
        }
    }

    @ActivityCallThrough
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        delegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @ActivityCallThrough
    public void onNewIntent(@NonNull Intent intent) {
        delegate.onNewIntent(intent);
    }


    @ActivityCallThrough
    public void onBackPressed() {
        delegate.onBackPressed();
    }

    /**
     * A result has been returned after an invocation of {@link Fragment#startActivityForResult(Intent, int)}.
     * <p>
     *
     * @param requestCode request code sent with {@link Fragment#startActivityForResult(Intent, int)}
     * @param resultCode  code representing the result of the {@code Activity} that was launched
     * @param data        any corresponding return data, held within an {@code Intent}
     */
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        delegate.onActivityResult(requestCode, resultCode, data);
    }


    @ActivityCallThrough
    public void onUserLeaveHint() {
        delegate.onUserLeaveHint();
    }

    /**
     * Callback invoked when memory is low.
     * <p>
     * This implementation forwards a memory pressure warning to the running Flutter app.
     * <p>
     *
     * @param level level
     */
    @ActivityCallThrough
    public void onTrimMemory(int level) {
        delegate.onTrimMemory(level);
    }

    /**
     * Callback invoked when memory is low.
     * <p>
     * This implementation forwards a memory pressure warning to the running Flutter app.
     */
    @Override
    public void onLowMemory() {
        super.onLowMemory();
        delegate.onLowMemory();
    }

    @NonNull
    private Context getContextCompat() {
        return Build.VERSION.SDK_INT >= 23
                ? getContext()
                : getActivity();
    }

    /**
     * {@link FlutterActivityAndFragmentDelegate.Host} method that is used by
     * {@link FlutterActivityAndFragmentDelegate} to obtain Flutter shell arguments when
     * initializing Flutter.
     */
    @Override
    @NonNull
    public FlutterShellArgs getFlutterShellArgs() {
        String[] flutterShellArgsArray = getArguments().getStringArray(ARG_FLUTTER_INITIALIZATION_ARGS);
        return new FlutterShellArgs(
                flutterShellArgsArray != null ? flutterShellArgsArray : new String[]{}
        );
    }

    /**
     * Returns the desired {@link FlutterView.RenderMode} for the {@link FlutterView} displayed in
     * this {@code NewFlutterFragment}.
     * <p>
     * Defaults to {@link FlutterView.RenderMode#surface}.
     * <p>
     * Used by this {@code NewFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @NonNull
    public FlutterView.RenderMode getRenderMode() {
        String renderModeName = getArguments().getString(
                ARG_FLUTTERVIEW_RENDER_MODE,
                FlutterView.RenderMode.surface.name()
        );
        return FlutterView.RenderMode.valueOf(renderModeName);
    }

    /**
     * Returns the desired {@link FlutterView.TransparencyMode} for the {@link FlutterView} displayed in
     * this {@code NewFlutterFragment}.
     * <p>
     * Defaults to {@link FlutterView.TransparencyMode#transparent}.
     * <p>
     * Used by this {@code NewFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @NonNull
    public FlutterView.TransparencyMode getTransparencyMode() {
        String transparencyModeName = getArguments().getString(
                ARG_FLUTTERVIEW_TRANSPARENCY_MODE,
                FlutterView.TransparencyMode.transparent.name()
        );
        return FlutterView.TransparencyMode.valueOf(transparencyModeName);
    }

    @Override
    @Nullable
    public SplashScreen provideSplashScreen() {
        FragmentActivity parentActivity = getActivity();
        if (parentActivity instanceof SplashScreenProvider) {
            SplashScreenProvider splashScreenProvider = (SplashScreenProvider) parentActivity;
            return splashScreenProvider.provideSplashScreen();
        }

        return null;
    }


    @Override
    @Nullable
    public FlutterEngine provideFlutterEngine(@NonNull Context context) {

        return FlutterBoost.instance().engineProvider();
    }

    /**
     * Hook for subclasses to obtain a reference to the {@link FlutterEngine} that is owned
     * by this {@code FlutterActivity}.
     */
    @Nullable
    public FlutterEngine getFlutterEngine() {
        return delegate.getFlutterEngine();
    }

    @Nullable
    @Override
    public XPlatformPlugin providePlatformPlugin( @NonNull FlutterEngine flutterEngine) {
        return BoostViewUtils.getPlatformPlugin(flutterEngine.getPlatformChannel());
    }

    /**
     * Configures a {@link FlutterEngine} after its creation.
     * <p>
     * This method is called after {@link #provideFlutterEngine(Context)}, and after the given
     * {@link FlutterEngine} has been attached to the owning {@code FragmentActivity}. See
     * {@link io.flutter.embedding.engine.plugins.activity.ActivityControlSurface#attachToActivity(Activity, Lifecycle)}.
     * <p>
     * It is possible that the owning {@code FragmentActivity} opted not to connect itself as
     * an {@link io.flutter.embedding.engine.plugins.activity.ActivityControlSurface}. In that
     * case, any configuration, e.g., plugins, must not expect or depend upon an available
     * {@code Activity} at the time that this method is invoked.
     * <p>
     * The default behavior of this method is to defer to the owning {@code FragmentActivity}
     * as a {@link FlutterEngineConfigurator}. Subclasses can override this method if the
     * subclass needs to override the {@code FragmentActivity}'s behavior, or add to it.
     * <p>
     * Used by this {@code NewFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        FragmentActivity attachedActivity = getActivity();
        if (attachedActivity instanceof FlutterEngineConfigurator) {
            ((FlutterEngineConfigurator) attachedActivity).configureFlutterEngine(flutterEngine);
        }
    }

    @Override
    public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {

    }

    /**
     * See {@link NewEngineFragmentBuilder#shouldAttachEngineToActivity()} and
     * <p>
     * Used by this {@code NewFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate}
     */
    @Override
    public boolean shouldAttachEngineToActivity() {
        return true;
    }


    @Override
    public String getContainerUrl() {

        return getArguments().getString(EXTRA_URL);


    }

    @Override
    public Map getContainerUrlParams() {

        BoostFlutterActivity.SerializableMap serializableMap = (BoostFlutterActivity.SerializableMap) getArguments().getSerializable(EXTRA_PARAMS);

        return serializableMap.getMap();
    }

    /**
     * Annotates methods in {@code NewFlutterFragment} that must be called by the containing
     * {@code Activity}.
     */
    @interface ActivityCallThrough {
    }

}