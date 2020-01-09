package com.idlefish.flutterboost.containers;


import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import io.flutter.embedding.android.FlutterFragment;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterShellArgs;

import java.util.HashMap;
import java.util.Map;

public class BoostFlutterFragment extends FlutterFragment {

    public static final String EXTRA_URL = "url";
    public static final String EXTRA_PARAMS = "params";
    private FlutterViewContainerDelegate containerDelegate;


    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

    }


    @Override
    public void onStart() {
        super.onStart();
        if (containerDelegate == null) {
            containerDelegate = new FlutterViewContainerDelegate(this);
            containerDelegate.onCreateView();
        }

        containerDelegate.onStart();
    }


    @Override
    public void onBackPressed() {
        super.onBackPressed();
        containerDelegate.onBackPressed();
    }

    @Override
    public void onPause() {
        super.onPause();
        containerDelegate.onPause();
    }


    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        containerDelegate.onNewIntent(intent);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        containerDelegate.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        containerDelegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        containerDelegate.onDestroyView();
    }


    public static class BoostEngineFragmentBuilder extends NewEngineFragmentBuilder {


        private FlutterShellArgs shellArgs = null;
        private FlutterView.RenderMode renderMode = FlutterView.RenderMode.surface;
        private FlutterView.TransparencyMode transparencyMode = FlutterView.TransparencyMode.transparent;
        private boolean shouldAttachEngineToActivity = true;
        private String url = "";
        private Map params = new HashMap();

        public BoostEngineFragmentBuilder() {
           this(BoostFlutterFragment.class);
        }


        public BoostEngineFragmentBuilder(@NonNull Class<? extends FlutterFragment> subclass) {
            super(subclass);
        }
        /**
         * Any special configuration arguments for the Flutter engine
         */
        @NonNull
        public BoostEngineFragmentBuilder flutterShellArgs(@NonNull FlutterShellArgs shellArgs) {
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
        public BoostEngineFragmentBuilder renderMode(@NonNull FlutterView.RenderMode renderMode) {
            this.renderMode = renderMode;
            return this;
        }

        public BoostEngineFragmentBuilder url(@NonNull String url) {
            this.url = url;
            return this;
        }


        public BoostEngineFragmentBuilder params(@NonNull Map params) {
            this.params = params;
            return this;
        }


        @NonNull
        public BoostEngineFragmentBuilder transparencyMode(@NonNull FlutterView.TransparencyMode transparencyMode) {
            this.transparencyMode = transparencyMode;
            return this;
        }

        @NonNull
        protected Bundle createArgs() {
            Bundle args = new Bundle();

            if (null != shellArgs) {
                args.putStringArray(ARG_FLUTTER_INITIALIZATION_ARGS, shellArgs.toArray());
            }

           FlutterViewContainerDelegate.SerializableMap serializableMap = new FlutterViewContainerDelegate.SerializableMap();
            serializableMap.setMap(params);

            args.putString(EXTRA_URL, url);
            args.putSerializable(EXTRA_PARAMS, serializableMap);
            args.putString(ARG_FLUTTERVIEW_RENDER_MODE, renderMode != null ? renderMode.name() : FlutterView.RenderMode.surface.name());
            args.putString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, transparencyMode != null ? transparencyMode.name() : FlutterView.TransparencyMode.transparent.name());
            args.putBoolean(ARG_DESTROY_ENGINE_WITH_FRAGMENT, true);


            return args;
        }


    }

}