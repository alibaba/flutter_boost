package com.idlefish.flutterboost.containers;


import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;


import java.util.Map;

import io.flutter.embedding.android.FlutterFragment;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.android.TransparencyMode;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.PAGE_NAME;
import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.UNIQUE_ID;

public class FlutterBoostFragment extends FlutterFragment implements FlutterViewContainer {
    private FlutterView flutterView;
    private  String uniqueId;
    private  String pageName;
    boolean isTabSelect=true;
    public void setContainerInfo( String uniqueId,String pageName){
        this.uniqueId=uniqueId;
        this.pageName=pageName;
    }

    private void findFlutterView(View view) {
        if (view instanceof ViewGroup) {
            ViewGroup vp = (ViewGroup) view;
            for (int i = 0; i < vp.getChildCount(); i++) {
                View viewchild = vp.getChildAt(i);
                if (viewchild instanceof FlutterView) {
                    flutterView = (FlutterView) viewchild;
                    return;
                } else {
                    findFlutterView(viewchild);
                }

            }
        }
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        ActivityAndFragmentPatch.pushContainer(this);
//        ActivityAndFragmentPatch.setStackTop(this);

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
            ActivityAndFragmentPatch.removeStackTop(this);
            ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(flutterView, this.getFlutterEngine());
        } else {
            ActivityAndFragmentPatch.setStackTop(this);
            ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(flutterView, this.getFlutterEngine(), this);
        }
        super.onHiddenChanged(hidden);
    }



    public void setTabSelected(boolean isTabSelect) {
        this.isTabSelect=isTabSelect;
//        ActivityAndFragmentPatch.setStackTop(this);
    }
    @Override
    public void onResume() {
        if (flutterView == null) {
            findFlutterView(this.getView().getRootView());
        }
        if(isTabSelect){
            ActivityAndFragmentPatch.setStackTop(this);
        }
        super.onResume();
        ActivityAndFragmentPatch.onResumeAttachToFlutterEngine(flutterView, this.getFlutterEngine(), this);
        this.getFlutterEngine().getLifecycleChannel().appIsResumed();

    }

    @Override
    public RenderMode getRenderMode() {
        return ActivityAndFragmentPatch.getRenderMode();
    }

    @Override
    public void onPause() {
        super.onPause();
        ActivityAndFragmentPatch.removeStackTop(this);
        ActivityAndFragmentPatch.onPauseDetachFromFlutterEngine(flutterView, this.getFlutterEngine());
        this.getFlutterEngine().getLifecycleChannel().appIsResumed();

    }

    @Override
    public void onStop() {
        super.onStop();
        if( this.getFlutterEngine()!=null){
            this.getFlutterEngine().getLifecycleChannel().appIsResumed();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();

    }

    @Override
    public void onDetach() {
        super.onDetach();
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
        public CachedEngineFragmentBuilder( String engineId) {
            this(FlutterBoostFragment.class, engineId);
        }

        public CachedEngineFragmentBuilder(
                 Class<? extends FlutterBoostFragment> subclass,  String engineId) {
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
            args.putString(PAGE_NAME, pageName);
            args.putString(UNIQUE_ID, uniqueId);
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
