package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.arch.lifecycle.Lifecycle;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.idlefish.flutterboost.NewFlutterBoost;
import io.flutter.embedding.android.*;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.renderer.OnFirstFrameRenderedListener;
import io.flutter.plugin.platform.PlatformPlugin;
import io.flutter.view.FlutterMain;

import java.util.HashMap;
import java.util.Map;


public class FlutterFragment extends Fragment implements FlutterActivityAndFragmentDelegate.Host {

    private static final String TAG = "FlutterFragment";

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
     * {@code FlutterFragment}
     */
    protected static final String ARG_FLUTTERVIEW_RENDER_MODE = "flutterview_render_mode";
    /**
     * {@link FlutterView.TransparencyMode} to be used for the {@link FlutterView} in this
     * {@code FlutterFragment}
     */
    protected static final String ARG_FLUTTERVIEW_TRANSPARENCY_MODE = "flutterview_transparency_mode";
    /**
     * See {@link #shouldAttachEngineToActivity()}.
     */
    protected static final String ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY = "should_attach_engine_to_activity";
    /**
     * the created {@code FlutterFragment}.
     */
    protected static final String ARG_CACHED_ENGINE_ID = "cached_engine_id";
    /**
     * True if the {@link FlutterEngine} in the created {@code FlutterFragment} should be destroyed
     * when the {@code FlutterFragment} is destroyed, false if the {@link FlutterEngine} should
     * outlive the {@code FlutterFragment}.
     */
    protected static final String ARG_DESTROY_ENGINE_WITH_FRAGMENT = "destroy_engine_with_fragment";

    /**
     * Creates a {@code FlutterFragment} with a default configuration.
     * <p>
     * {@code FlutterFragment}'s default configuration creates a new {@link FlutterEngine} within
     * the {@code FlutterFragment} and uses the following settings:
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
     * Returns a {@link NewEngineFragmentBuilder} to create a {@code FlutterFragment} with a new
     * {@link FlutterEngine} and a desired engine configuration.
     */
    @NonNull
    public static NewEngineFragmentBuilder withNewEngine() {
        return new NewEngineFragmentBuilder();
    }

    /**
     * Builder that creates a new {@code FlutterFragment} with {@code arguments} that correspond
     * to the values set on this {@code NewEngineFragmentBuilder}.
     * <p>
     * To create a {@code FlutterFragment} with default {@code arguments}, invoke
     * {@link #createDefault()}.
     * <p>
     * Subclasses of {@code FlutterFragment} that do not introduce any new arguments can use this
     * {@code NewEngineFragmentBuilder} to construct instances of the subclass without subclassing
     * this {@code NewEngineFragmentBuilder}.
     * {@code
     * MyFlutterFragment f = new FlutterFragment.NewEngineFragmentBuilder(MyFlutterFragment.class)
     * .someProperty(...)
     * .someOtherProperty(...)
     * .build<MyFlutterFragment>();
     * }
     * <p>
     * Subclasses of {@code FlutterFragment} that introduce new arguments should subclass this
     * {@code NewEngineFragmentBuilder} to add the new properties:
     * <ol>
     * <li>Ensure the {@code FlutterFragment} subclass has a no-arg constructor.</li>
     * <li>Subclass this {@code NewEngineFragmentBuilder}.</li>
     * <li>Override the new {@code NewEngineFragmentBuilder}'s no-arg constructor and invoke the
     * super constructor to set the {@code FlutterFragment} subclass: {@code
     * public MyBuilder() {
     * super(MyFlutterFragment.class);
     * }
     * }</li>
     * <li>Add appropriate property methods for the new properties.</li>
     * <li>Override {@link NewEngineFragmentBuilder#createArgs()}, call through to the super method,
     * then add the new properties as arguments in the {@link Bundle}.</li>
     * </ol>
     * Once a {@code NewEngineFragmentBuilder} subclass is defined, the {@code FlutterFragment}
     * subclass can be instantiated as follows.
     * {@code
     * MyFlutterFragment f = new MyBuilder()
     * .someExistingProperty(...)
     * .someNewProperty(...)
     * .build<MyFlutterFragment>();
     * }
     */
    public static class NewEngineFragmentBuilder {
        private final Class<? extends FlutterFragment> fragmentClass;
        private String dartEntrypoint = "main";
        private String initialRoute = "/";
        private String appBundlePath = null;
        private FlutterShellArgs shellArgs = null;
        private FlutterView.RenderMode renderMode = FlutterView.RenderMode.surface;
        private FlutterView.TransparencyMode transparencyMode = FlutterView.TransparencyMode.transparent;
        private boolean shouldAttachEngineToActivity = true;

        /**
         * Constructs a {@code NewEngineFragmentBuilder} that is configured to construct an instance of
         * {@code FlutterFragment}.
         */
        public NewEngineFragmentBuilder() {
            fragmentClass = FlutterFragment.class;
        }

        /**
         * Constructs a {@code NewEngineFragmentBuilder} that is configured to construct an instance of
         * {@code subclass}, which extends {@code FlutterFragment}.
         */
        public NewEngineFragmentBuilder(@NonNull Class<? extends FlutterFragment> subclass) {
            fragmentClass = subclass;
        }

        /**
         * The name of the initial Dart method to invoke, defaults to "main".
         */
        @NonNull
        public NewEngineFragmentBuilder dartEntrypoint(@NonNull String dartEntrypoint) {
            this.dartEntrypoint = dartEntrypoint;
            return this;
        }

        /**
         * The initial route that a Flutter app will render in this {@link FlutterFragment},
         * defaults to "/".
         */
        @NonNull
        public NewEngineFragmentBuilder initialRoute(@NonNull String initialRoute) {
            this.initialRoute = initialRoute;
            return this;
        }

        /**
         * The path to the app bundle which contains the Dart app to execute, defaults
         * to {@link FlutterMain#findAppBundlePath()}
         */
        @NonNull
        public NewEngineFragmentBuilder appBundlePath(@NonNull String appBundlePath) {
            this.appBundlePath = appBundlePath;
            return this;
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
        public NewEngineFragmentBuilder shouldAttachEngineToActivity(boolean shouldAttachEngineToActivity) {
            this.shouldAttachEngineToActivity = shouldAttachEngineToActivity;
            return this;
        }


        @NonNull
        protected Bundle createArgs() {
            Bundle args = new Bundle();
            args.putString(ARG_INITIAL_ROUTE, initialRoute);
            args.putString(ARG_APP_BUNDLE_PATH, appBundlePath);
            args.putString(ARG_DART_ENTRYPOINT, dartEntrypoint);
            // TODO(mattcarroll): determine if we should have an explicit FlutterTestFragment instead of conflating.
            if (null != shellArgs) {
                args.putStringArray(ARG_FLUTTER_INITIALIZATION_ARGS, shellArgs.toArray());
            }
            args.putString(ARG_FLUTTERVIEW_RENDER_MODE, renderMode != null ? renderMode.name() : FlutterView.RenderMode.surface.name());
            args.putString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, transparencyMode != null ? transparencyMode.name() : FlutterView.TransparencyMode.transparent.name());
            args.putBoolean(ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY, shouldAttachEngineToActivity);
            args.putBoolean(ARG_DESTROY_ENGINE_WITH_FRAGMENT, true);
            return args;
        }

        /**
         * Constructs a new {@code FlutterFragment} (or a subclass) that is configured based on
         * properties set on this {@code Builder}.
         */
        @NonNull
        public <T extends FlutterFragment> T build() {
            try {
                @SuppressWarnings("unchecked")
                T frag = (T) fragmentClass.getDeclaredConstructor().newInstance();
                if (frag == null) {
                    throw new RuntimeException("The FlutterFragment subclass sent in the constructor ("
                            + fragmentClass.getCanonicalName() + ") does not match the expected return type.");
                }

                Bundle args = createArgs();
                frag.setArguments(args);

                return frag;
            } catch (Exception e) {
                throw new RuntimeException("Could not instantiate FlutterFragment subclass (" + fragmentClass.getName() + ")", e);
            }
        }
    }




    // Delegate that runs all lifecycle and OS hook logic that is common between
    // FlutterActivity and FlutterFragment. See the FlutterActivityAndFragmentDelegate
    // implementation for details about why it exists.
    private FlutterActivityAndFragmentDelegate delegate;

    private final OnFirstFrameRenderedListener onFirstFrameRenderedListener = new OnFirstFrameRenderedListener() {
        @Override
        public void onFirstFrameRendered() {
            // Notify our subclasses that the first frame has been rendered.
            FlutterFragment.this.onFirstFrameRendered();

            // Notify our owning Activity that the first frame has been rendered.
            FragmentActivity fragmentActivity = getActivity();
            if (fragmentActivity instanceof OnFirstFrameRenderedListener) {
                OnFirstFrameRenderedListener activityAsListener = (OnFirstFrameRenderedListener) fragmentActivity;
                activityAsListener.onFirstFrameRendered();
            }
        }
    };

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
        delegate.onStart();
    }

    @Override
    public void onResume() {
        super.onResume();
        delegate.onResume();
    }

    // TODO(mattcarroll): determine why this can't be in onResume(). Comment reason, or move if possible.
    @ActivityCallThrough
    public void onPostResume() {
        delegate.onPostResume();
    }

    @Override
    public void onPause() {
        super.onPause();
        delegate.onPause();
    }

    @Override
    public void onStop() {
        super.onStop();
        delegate.onStop();
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
     * Returns the ID of a statically cached {@link FlutterEngine} to use within this
     * {@code FlutterFragment}, or {@code null} if this {@code FlutterFragment} does not want to
     * use a cached {@link FlutterEngine}.
     */
    @Nullable
    @Override
    public String getCachedEngineId() {
        return getArguments().getString(ARG_CACHED_ENGINE_ID, null);
    }

    /**
     * Returns false if the {@link FlutterEngine} within this {@code FlutterFragment} should outlive
     * the {@code FlutterFragment}, itself.
     * <p>
     * Defaults to true if no custom {@link FlutterEngine is provided}, false if a custom
     * {@link FlutterEngine} is provided.
     */
    @Override
    public boolean shouldDestroyEngineWithHost() {
        return getArguments().getBoolean(ARG_DESTROY_ENGINE_WITH_FRAGMENT, false);
    }

    /**
     * Returns the name of the Dart method that this {@code FlutterFragment} should execute to
     * start a Flutter app.
     * <p>
     * Defaults to "main".
     * <p>
     * Used by this {@code FlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @NonNull
    public String getDartEntrypointFunctionName() {
        return getArguments().getString(ARG_DART_ENTRYPOINT, "main");
    }

    /**
     * Returns the file path to the desired Flutter app's bundle of code.
     * <p>
     * Defaults to {@link FlutterMain#findAppBundlePath()}.
     * <p>
     * Used by this {@code FlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @NonNull
    public String getAppBundlePath() {
        return getArguments().getString(ARG_APP_BUNDLE_PATH, FlutterMain.findAppBundlePath());
    }

    /**
     * Returns the initial route that should be rendered within Flutter, once the Flutter app starts.
     * <p>
     * Defaults to {@code null}, which signifies a route of "/" in Flutter.
     * <p>
     * Used by this {@code FlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @Nullable
    public String getInitialRoute() {
        return getArguments().getString(ARG_INITIAL_ROUTE);
    }

    /**
     * Returns the desired {@link FlutterView.RenderMode} for the {@link FlutterView} displayed in
     * this {@code FlutterFragment}.
     * <p>
     * Defaults to {@link FlutterView.RenderMode#surface}.
     * <p>
     * Used by this {@code FlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
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
     * this {@code FlutterFragment}.
     * <p>
     * Defaults to {@link FlutterView.TransparencyMode#transparent}.
     * <p>
     * Used by this {@code FlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
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

        return NewFlutterBoost.instance().engineProvider();
//        // Defer to the FragmentActivity that owns us to see if it wants to provide a
//        // FlutterEngine.
//        FlutterEngine flutterEngine = null;
//        FragmentActivity attachedActivity = getActivity();
//        if (attachedActivity instanceof FlutterEngineProvider) {
//            // Defer to the Activity that owns us to provide a FlutterEngine.
//            Log.d(TAG, "Deferring to attached Activity to provide a FlutterEngine.");
//            FlutterEngineProvider flutterEngineProvider = (FlutterEngineProvider) attachedActivity;
//            flutterEngine = flutterEngineProvider.provideFlutterEngine(getContext());
//        }
//
//        return flutterEngine;
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
    public PlatformPlugin providePlatformPlugin(@Nullable Activity activity, @NonNull FlutterEngine flutterEngine) {
        if (activity != null) {
            return new PlatformPlugin(getActivity(), flutterEngine.getPlatformChannel());
        } else {
            return null;
        }
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
     * Used by this {@code FlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        FragmentActivity attachedActivity = getActivity();
        if (attachedActivity instanceof FlutterEngineConfigurator) {
            ((FlutterEngineConfigurator) attachedActivity).configureFlutterEngine(flutterEngine);
        }
    }

    /**
     * See {@link NewEngineFragmentBuilder#shouldAttachEngineToActivity()} and
     * <p>
     * Used by this {@code FlutterFragment}'s {@link FlutterActivityAndFragmentDelegate}
     */
    @Override
    public boolean shouldAttachEngineToActivity() {
        return getArguments().getBoolean(ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY);
    }

    /**
     * Invoked after the {@link FlutterView} within this {@code FlutterFragment} renders its first
     * frame.
     * <p>
     * This method forwards {@code onFirstFrameRendered()} to its attached {@code Activity}, if
     * the attached {@code Activity} implements {@link OnFirstFrameRenderedListener}.
     * <p>
     * Subclasses that override this method must call through to the {@code super} method.
     * <p>
     * Used by this {@code FlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    public void onFirstFrameRendered() {
        FragmentActivity attachedActivity = getActivity();
        if (attachedActivity instanceof OnFirstFrameRenderedListener) {
            ((OnFirstFrameRenderedListener) attachedActivity).onFirstFrameRendered();
        }
    }

    @Override
    public void finishContainer(Map<String, Object> result) {
        Activity activity= this.getActivity();

        activity.finish();
    }

    @Override
    public String getContainerUrl() {
        return "flutterFragment";
    }

    @Override
    public Map getContainerUrlParams() {
        Map<String,String> params = new HashMap<>();
        params.put("aaa","bbb");
        return params;
    }

    /**
     * Annotates methods in {@code FlutterFragment} that must be called by the containing
     * {@code Activity}.
     */
    @interface ActivityCallThrough {
    }

}