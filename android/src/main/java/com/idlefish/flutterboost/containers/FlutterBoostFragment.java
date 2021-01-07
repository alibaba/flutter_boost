package com.idlefish.flutterboost.containers;


import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.android.TransparencyMode;
import io.flutter.embedding.engine.FlutterEngine;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.PAGE_NAME;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.UNIQUE_ID;

public class FlutterBoostFragment extends CopyFlutterFragment implements FlutterViewContainer {
    private  String uniqueId;
    private  String pageName;
    public void setContainerInfo( String uniqueId,String pageName){
        this.uniqueId=uniqueId;
        this.pageName=pageName;
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        ActivityAndFragmentPatch.setStackTop(this);
        ActivityAndFragmentPatch.pushContainer(this);
        if(getArguments().getString(UNIQUE_ID)!=null){
            uniqueId=getArguments().getString(UNIQUE_ID);
        }
        if(getArguments().getString(PAGE_NAME)!=null){
            pageName=getArguments().getString(PAGE_NAME);
        }
        return super.onCreateView(inflater, container, savedInstanceState);

    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        if (hidden) {
            ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(delegate.getFlutterView(), delegate.getFlutterEngine());
        } else {
            ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(delegate.getFlutterView(), delegate.getFlutterEngine(), this);
        }
        super.onHiddenChanged(hidden);
    }

    public void setTabSelected() {
        ActivityAndFragmentPatch.setStackTop(this);
    }
    @Override
    public void onResume() {
        super.onResume();
        ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(delegate.getFlutterView(), delegate.getFlutterEngine(), this);

    }

    @Override
    public RenderMode getRenderMode() {
        return ActivityAndFragmentPatch.getRenderMode();
    }

    @Override
    public void onPause() {
        super.onPause();
        ActivityAndFragmentPatch.removeStackTop(this);
        ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(delegate.getFlutterView(), delegate.getFlutterEngine());
    }

    @Override
    public void onDestroyView() {
        ActivityAndFragmentPatch.removeContainer(this);
        super.onDestroyView();
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
    public String getContainerUrl() {

        return this.pageName;
    }

    @Override
    public String getUniqueId() {
//        getArguments().getString(UNIQUE_ID, null)==null
        return this.uniqueId;
    }



    public static class CachedEngineFragmentBuilder {
        private final Class<? extends FlutterBoostFragment> fragmentClass;
        private final String engineId;
        private boolean destroyEngineWithFragment = false;
        private RenderMode renderMode = RenderMode.surface;
        private TransparencyMode transparencyMode = TransparencyMode.transparent;
        private boolean shouldAttachEngineToActivity = true;
        private  String pageName;
        private  String uniqueId;
        public CachedEngineFragmentBuilder(@NonNull String engineId) {
            this(FlutterBoostFragment.class, engineId);
        }

        public CachedEngineFragmentBuilder(
                 Class<? extends FlutterBoostFragment> subclass, @NonNull String engineId) {
            this.fragmentClass = subclass;
            this.engineId = engineId;
        }

        public FlutterBoostFragment.CachedEngineFragmentBuilder pageName(String pageName) {
            this.pageName =pageName;
            return this;
        }
        public FlutterBoostFragment.CachedEngineFragmentBuilder uniqueId(String uniqueId) {
            this.uniqueId = uniqueId;
            return this;
        }

        public FlutterBoostFragment.CachedEngineFragmentBuilder destroyEngineWithFragment(
                boolean destroyEngineWithFragment) {
            this.destroyEngineWithFragment = destroyEngineWithFragment;
            return this;
        }


        public FlutterBoostFragment.CachedEngineFragmentBuilder renderMode(@NonNull RenderMode renderMode) {
            this.renderMode = renderMode;
            return this;
        }


        public FlutterBoostFragment.CachedEngineFragmentBuilder transparencyMode(
                @NonNull TransparencyMode transparencyMode) {
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
        @NonNull
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
            args.putString(PAGE_NAME, pageName);
            args.putString(UNIQUE_ID, uniqueId);
            return args;
        }

        /**
         * Constructs a new {@code FlutterFragment} (or a subclass) that is configured based on
         * properties set on this {@code CachedEngineFragmentBuilder}.
         */
        @NonNull
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
