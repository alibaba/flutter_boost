package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.os.PersistableBundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.idlefish.flutterboost.FlutterBoost;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.SplashScreen;
import io.flutter.embedding.engine.FlutterEngine;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;



public class BoostFlutterActivity extends FlutterActivity {
    protected static final String EXTRA_URL = "url";
    protected static final String EXTRA_PARAMS = "params";
    protected static final String DEFAULT_BACKGROUND_MODE = BackgroundMode.opaque.name();
    static final String EXTRA_BACKGROUND_MODE = "background_mode";
    static final String EXTRA_DESTROY_ENGINE_WITH_ACTIVITY = "destroy_engine_with_activity";
    static final String SPLASH_SCREEN_META_DATA_KEY = "io.flutter.embedding.android.SplashScreenDrawable";

    private FlutterViewContainerDelegate containerDelegate;

    public FlutterEngine provideFlutterEngine(Context context) {
        return FlutterBoost.instance().engineProvider();
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState,
                         @Nullable PersistableBundle persistentState) {
        super.onCreate(savedInstanceState, persistentState);

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
    public void onPause() {
        super.onPause();
        containerDelegate.onPause();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        containerDelegate.onDestroyView();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        containerDelegate.onBackPressed();
    }

    @Override
    public void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        containerDelegate.onNewIntent(intent);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        containerDelegate.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        containerDelegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }



    public static BoostEngineIntentBuilder withNewEngine() {
        return new BoostEngineIntentBuilder(BoostFlutterActivity.class);
    }


    public static class BoostEngineIntentBuilder extends NewEngineIntentBuilder {
        private String backgroundMode = DEFAULT_BACKGROUND_MODE;

        private String url = "";
        private Map params = new HashMap();

        protected BoostEngineIntentBuilder(@NonNull Class<? extends FlutterActivity> activityClass) {
            super(activityClass);
        }


        public BoostEngineIntentBuilder url(@NonNull String url) {
            this.url = url;
            return this;
        }


        public BoostEngineIntentBuilder params(@NonNull Map params) {
            this.params = params;
            return this;
        }
        public BoostEngineIntentBuilder backgroundMode(@NonNull BackgroundMode backgroundMode) {
            this.backgroundMode = backgroundMode.name();
            return this;
        }

        public Intent build(@NonNull Context context) {
            Intent intent = super.build(context);
            FlutterViewContainerDelegate.SerializableMap serializableMap = new FlutterViewContainerDelegate.SerializableMap();
            serializableMap.setMap(params);
            intent.putExtra(EXTRA_BACKGROUND_MODE, backgroundMode);
            intent.putExtra(EXTRA_URL, url);
            intent.putExtra(EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, false);
            intent.putExtra(EXTRA_PARAMS, serializableMap);
            return intent;
        }
    }

    public SplashScreen provideSplashScreen() {
        Drawable manifestSplashDrawable =getSplashScreenFromManifest();
        if (manifestSplashDrawable != null) {
            return new BoostDrawableSplashScreen(manifestSplashDrawable);
        } else {
            return null;
        }
    }
    private Drawable getSplashScreenFromManifest() {
        try {
            ActivityInfo activityInfo = getPackageManager().getActivityInfo(
                    getComponentName(),
                    PackageManager.GET_META_DATA
            );
            Bundle metadata = activityInfo.metaData;
            int splashScreenId = metadata != null ? metadata.getInt(SPLASH_SCREEN_META_DATA_KEY) : 0;
            return splashScreenId != 0
                    ? Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP
                    ? getResources().getDrawable(splashScreenId, getTheme())
                    : getResources().getDrawable(splashScreenId)
                    : null;
        } catch (PackageManager.NameNotFoundException e) {
            // This is never expected to happen.
            return null;
        }
    }

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
