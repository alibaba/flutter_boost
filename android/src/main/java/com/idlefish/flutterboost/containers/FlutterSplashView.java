package com.idlefish.flutterboost.containers;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Parcel;
import android.os.Parcelable;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import com.idlefish.flutterboost.*;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.SplashScreen;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener;


/**
 * {@code View} that displays a {@link SplashScreen} until a given {@link FlutterView}
 * renders its first frame.
 */
public class FlutterSplashView extends FrameLayout {
    private static String TAG = "FlutterSplashView";
    private FlutterEngine mFlutterEngine;

    @Nullable
    private SplashScreen splashScreen;
    @Nullable
    private XFlutterView flutterView;
    @Nullable
    private View splashScreenView;
    @Nullable
    private Bundle splashScreenState;
    @Nullable
    private String transitioningIsolateId;
    @Nullable
    private String previousCompletedSplashIsolate;

    private Handler handler = new Handler();

    @NonNull
    private final FlutterView.FlutterEngineAttachmentListener flutterEngineAttachmentListener = new FlutterView.FlutterEngineAttachmentListener() {
        @Override
        public void onFlutterEngineAttachedToFlutterView(@NonNull FlutterEngine engine) {
            flutterView.removeFlutterEngineAttachmentListener(this);
        }

        @Override
        public void onFlutterEngineDetachedFromFlutterView() {
        }
    };

    @NonNull
    private final FlutterUiDisplayListener onFirstFrameRenderedListener = new FlutterUiDisplayListener() {
        @Override
        public void onFlutterUiDisplayed() {
            if (splashScreen != null) {
                transitionToFlutter();
            }
        }

        @Override
        public void onFlutterUiNoLongerDisplayed() {

        }


    };

    @NonNull
    private final Runnable onTransitionComplete = new Runnable() {
        @Override
        public void run() {
            removeView(splashScreenView);
            previousCompletedSplashIsolate = transitioningIsolateId;
        }
    };

    public FlutterSplashView(@NonNull Context context) {
        this(context, null, 0);
    }

    public FlutterSplashView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FlutterSplashView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        setSaveEnabled(true);
        if (mFlutterEngine == null) {
            mFlutterEngine = FlutterBoost.instance().engineProvider();
        }
    }

    /**
     * Displays the given {@code splashScreen} on top of the given {@code flutterView} until
     * Flutter has rendered its first frame, then the {@code splashScreen} is transitioned away.
     * <p>
     * If no {@code splashScreen} is provided, this {@code FlutterSplashView} displays the
     * given {@code flutterView} on its own.
     */
    public void displayFlutterViewWithSplash(@NonNull XFlutterView flutterView, @Nullable SplashScreen splashScreen) {
        // If we were displaying a previous FlutterView, remove it.
        if (this.flutterView != null) {
            this.flutterView.removeOnFirstFrameRenderedListener(onFirstFrameRenderedListener);
            removeView(this.flutterView);
        }
        // If we were displaying a previous splash screen View, remove it.
        if (splashScreenView != null) {
            removeView(splashScreenView);
        }

        // Display the new FlutterView.
        this.flutterView = flutterView;
        addView(flutterView);

        this.splashScreen = splashScreen;

        // Display the new splash screen, if needed.
        if (splashScreen != null) {


            splashScreenView = splashScreen.createSplashView(getContext(), splashScreenState);
            splashScreenView.setBackgroundColor(Color.WHITE);
            addView(this.splashScreenView);
            flutterView.addOnFirstFrameRenderedListener(onFirstFrameRenderedListener);
        }
    }


    /**
     * Returns true if a splash UI for a specific Flutter experience has already completed.
     * <p>
     * A "specific Flutter experience" is defined as any experience with the same Dart isolate
     * ID. The purpose of this distinction is to prevent a situation where a user gets past a
     * splash UI, rotates the device (or otherwise triggers a recreation) and the splash screen
     * reappears.
     * <p>
     * An isolate ID is deemed reasonable as a key for a completion event because a Dart isolate
     * cannot be entered twice. Therefore, a single Dart isolate cannot return to an "un-rendered"
     * state after having previously rendered content.
     */
    private boolean hasSplashCompleted() {
        if (flutterView == null) {
            throw new IllegalStateException("Cannot determine if splash has completed when no FlutterView "
                    + "is set.");
        }
        if (!flutterView.isAttachedToFlutterEngine()) {
            throw new IllegalStateException("Cannot determine if splash has completed when no "
                    + "FlutterEngine is attached to our FlutterView. This question depends on an isolate ID "
                    + "to differentiate Flutter experiences.");
        }

        // A null isolate ID on a non-null FlutterEngine indicates that the Dart isolate has not
        // been initialized. Therefore, no frame has been rendered for this engine, which means
        // no splash screen could have completed yet.
        return flutterView.getAttachedFlutterEngine().getDartExecutor().getIsolateServiceId() != null
                && flutterView.getAttachedFlutterEngine().getDartExecutor().getIsolateServiceId().equals(previousCompletedSplashIsolate);
    }

    /**
     * Transitions a splash screen to the Flutter UI.
     * <p>
     * This method requires that our FlutterView be attached to an engine, and that engine have
     * a Dart isolate ID. It also requires that a {@code splashScreen} exist.
     */
    private void transitionToFlutter() {
        transitioningIsolateId = flutterView.getAttachedFlutterEngine().getDartExecutor().getIsolateServiceId();
        Log.v(TAG, "Transitioning splash screen to a Flutter UI. Isolate: " + transitioningIsolateId);
        splashScreen.transitionToFlutter(onTransitionComplete);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        handler.removeCallbacksAndMessages(null);
    }

    public void onAttach() {
        Debuger.log("BoostFlutterView onAttach");

        flutterView.attachToFlutterEngine(mFlutterEngine);

    }


    public void onDetach() {
        Debuger.log("BoostFlutterView onDetach");

        flutterView.detachFromFlutterEngine();

    }

}