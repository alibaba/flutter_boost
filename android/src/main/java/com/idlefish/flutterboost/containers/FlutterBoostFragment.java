package com.idlefish.flutterboost.containers;


import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostPlugin;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterFragment;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.android.TransparencyMode;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_UNIQUE_ID;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.EXTRA_URL_PARAM;

public class FlutterBoostFragment extends FlutterFragment implements FlutterViewContainer {
    private FlutterView flutterView;
    private FlutterViewContainerObserver observer;

    private void findFlutterView(View view) {
        if (view instanceof ViewGroup) {
            ViewGroup vp = (ViewGroup) view;
            for (int i = 0; i < vp.getChildCount(); i++) {
                View child = vp.getChildAt(i);
                if (child instanceof FlutterView) {
                    flutterView = (FlutterView) child;
                    return;
                } else {
                    findFlutterView(child);
                }
            }
        }
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        observer = FlutterBoostPlugin.ContainerShadowNode.create(this, FlutterBoost.getFlutterBoostPlugin(getFlutterEngine()));
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        observer.onCreateView();
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        if (hidden) {
            ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(flutterView, this.getFlutterEngine());
            observer.onDisappear();
        } else {
            ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(flutterView, this.getFlutterEngine(), this);
            observer.onAppear();
        }
        super.onHiddenChanged(hidden);
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        if (isVisibleToUser) {
            ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(flutterView, this.getFlutterEngine(), this);
            observer.onAppear();
        } else {
            ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(flutterView, this.getFlutterEngine());
            observer.onDisappear();
        }
        super.setUserVisibleHint(isVisibleToUser);
    }

    @Override
    public void onResume() {
        if (flutterView == null) {
            findFlutterView(this.getView().getRootView());
        }
        super.onResume();
        ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(flutterView, this.getFlutterEngine(), this);
        this.getFlutterEngine().getLifecycleChannel().appIsResumed();

        if (!isHidden()) {
            observer.onAppear();
        }
    }

    @Override
    public RenderMode getRenderMode() {
        return ActivityAndFragmentPatch.getRenderMode();
    }

    @Override
    public void onPause() {
        super.onPause();
        ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(flutterView, this.getFlutterEngine());
        if( this.getFlutterEngine()!=null){
            this.getFlutterEngine().getLifecycleChannel().appIsResumed();
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        if( this.getFlutterEngine()!=null){
            this.getFlutterEngine().getLifecycleChannel().appIsResumed();
        }
        observer.onDisappear();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        observer.onDestroyView();
    }

    @Override
    public void onDetach() {
        super.onDetach();
    }

    @Override
    public void onBackPressed() {
        ActivityAndFragmentPatch.onBackPressed();
    }

    @Override
    public Activity getContextActivity() {
        return this.getActivity();
    }

    @Override
    public void finishContainer(Map<String, Object> result) {
        this.getActivity().finish();
    }

    @Override
    public String getUrl() {
        return getArguments().getString(EXTRA_URL);
    }

    @Override
    public HashMap<String, String> getUrlParams() {
        return (HashMap<String, String>)getArguments().getSerializable(EXTRA_URL_PARAM);
    }

    @Override
    public String getUniqueId() {
        return getArguments().getString(EXTRA_UNIQUE_ID);
    }

    public static class CachedEngineFragmentBuilder {
        private final Class<? extends FlutterBoostFragment> fragmentClass;
        private final String engineId;
        private boolean destroyEngineWithFragment = false;
        private RenderMode renderMode = RenderMode.surface;
        private TransparencyMode transparencyMode = TransparencyMode.transparent;
        private boolean shouldAttachEngineToActivity = true;
        private String url = "/";
        private HashMap<String, String> params;

        public CachedEngineFragmentBuilder( String engineId) {
            this(FlutterBoostFragment.class, engineId);
        }

        public CachedEngineFragmentBuilder(
                 Class<? extends FlutterBoostFragment> subclass,  String engineId) {
            this.fragmentClass = subclass;
            this.engineId = engineId;
        }

        public FlutterBoostFragment.CachedEngineFragmentBuilder url(String url) {
            this.url = url;
            return this;
        }

        public FlutterBoostFragment.CachedEngineFragmentBuilder urlParams(HashMap<String, String> param) {
            this.params = params;
            return this;
        }

        public FlutterBoostFragment.CachedEngineFragmentBuilder destroyEngineWithFragment(
                boolean destroyEngineWithFragment) {
            this.destroyEngineWithFragment = destroyEngineWithFragment;
            return this;
        }


        public FlutterBoostFragment.CachedEngineFragmentBuilder renderMode( RenderMode renderMode) {
            this.renderMode = renderMode;
            return this;
        }


        public FlutterBoostFragment.CachedEngineFragmentBuilder transparencyMode(
                 TransparencyMode transparencyMode) {
            this.transparencyMode = transparencyMode;
            return this;
        }

        public FlutterBoostFragment.CachedEngineFragmentBuilder shouldAttachEngineToActivity(
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
            args.putString(ARG_CACHED_ENGINE_ID, engineId);
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
            args.putString(EXTRA_UNIQUE_ID, FlutterBoost.generateUniqueId(url));
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
