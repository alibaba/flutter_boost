package com.idlefish.flutterboost;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.Surface;
import android.view.View;

import com.idlefish.flutterboost.interfaces.IContainerRecord;
import com.idlefish.flutterboost.interfaces.IStateListener;

import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.nio.ByteBuffer;

import io.flutter.app.FlutterPluginRegistry;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterJNI;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.renderer.FlutterRenderer;
import io.flutter.embedding.engine.renderer.OnFirstFrameRenderedListener;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.editing.TextInputPlugin;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterView;
import io.flutter.view.TextureRegistry;

public class BoostFlutterEngine extends FlutterEngine {
    protected final Context mContext;
    protected final BoostPluginRegistry mBoostPluginRegistry;
    protected final DartExecutor.DartEntrypoint mEntrypoint;
    protected final String mInitRoute;

    private final FakeRender mFakeRender;

    protected WeakReference<Activity> mCurrentActivityRef;

    public BoostFlutterEngine(@NonNull Context context) {
        this(context, null, null);
    }

    public BoostFlutterEngine(@NonNull Context context, DartExecutor.DartEntrypoint entrypoint, String initRoute) {
        super(context);
        mContext = context.getApplicationContext();
        mBoostPluginRegistry = new BoostPluginRegistry(this, context);

        if (entrypoint != null) {
            mEntrypoint = entrypoint;
        } else {
            mEntrypoint = defaultDartEntrypoint(context);
        }

        if (initRoute != null) {
            mInitRoute = initRoute;
        } else {
            mInitRoute = defaultInitialRoute(context);
        }

        FlutterJNI flutterJNI = null;
        try {
            Field field = FlutterEngine.class.getDeclaredField("flutterJNI");
            field.setAccessible(true);

            flutterJNI = (FlutterJNI) field.get(this);
        } catch (Throwable t) {
            try {
                for(Field field:FlutterEngine.class.getDeclaredFields()) {
                    field.setAccessible(true);
                    Object o = field.get(this);

                    if(o instanceof FlutterJNI) {
                        flutterJNI = (FlutterJNI)o;
                    }
                }

                if(flutterJNI == null) {
                    throw new RuntimeException("FlutterJNI not found");
                }
            }catch (Throwable it){
                Debuger.exception(it);
            }
        }
        mFakeRender = new FakeRender(flutterJNI);
    }

    public void startRun(@Nullable Activity activity) {
        mCurrentActivityRef = new WeakReference<>(activity);

        if (!getDartExecutor().isExecutingDart()) {

            Debuger.log("engine start running...");

            getNavigationChannel().setInitialRoute(mInitRoute);
            getDartExecutor().executeDartEntrypoint(mEntrypoint);

            final IStateListener stateListener = FlutterBoost.sInstance.mStateListener;
            if (stateListener != null) {
                stateListener.onEngineStarted(this);
            }

            FlutterBoost.singleton().platform().registerPlugins(mBoostPluginRegistry);

            if(activity != null) {
                FlutterRenderer.ViewportMetrics metrics = new FlutterRenderer.ViewportMetrics();
                metrics.devicePixelRatio = activity.getResources().getDisplayMetrics().density;
                final View decor = activity.getWindow().getDecorView();
                if(decor != null) {
                    metrics.width = decor.getWidth();
                    metrics.height = decor.getHeight();
                }

                if (metrics.width <= 0 || metrics.height <= 0) {
                    metrics.width = Utils.getMetricsWidth(activity);
                    metrics.height = Utils.getMetricsHeight(activity);
                }

                metrics.paddingTop = Utils.getStatusBarHeight(activity);
                metrics.paddingRight = 0;
                metrics.paddingBottom = 0;
                metrics.paddingLeft = 0;
                metrics.viewInsetTop = 0;
                metrics.viewInsetRight = 0;
                metrics.viewInsetBottom = 0;
                metrics.viewInsetLeft = 0;

                getRenderer().setViewportMetrics(metrics);
            }
        }
    }

    protected DartExecutor.DartEntrypoint defaultDartEntrypoint(Context context) {
        return new DartExecutor.DartEntrypoint(
                context.getResources().getAssets(),
                FlutterMain.findAppBundlePath(context),
                "main");
    }

    protected String defaultInitialRoute(Context context) {
        return "/";
    }

    public BoostPluginRegistry getBoostPluginRegistry() {
        return mBoostPluginRegistry;
    }

    public boolean isRunning() {
        return getDartExecutor().isExecutingDart();
    }

    @NonNull
    @Override
    public FlutterRenderer getRenderer() {
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();

        boolean hit = false;
        for (StackTraceElement st : stackTrace) {
            if (st.getMethodName().equals("sendViewportMetricsToFlutter")) {
                hit = true;
                break;
            }
        }

        if (hit) {
            return mFakeRender;
        } else {
            return super.getRenderer();
        }
    }

    public class BoostPluginRegistry extends FlutterPluginRegistry {
        private final FlutterEngine mEngine;

        public BoostPluginRegistry(FlutterEngine engine, Context context) {
            super(engine, context);
            mEngine = engine;
        }

        public PluginRegistry.Registrar registrarFor(String pluginKey) {
            return new BoostRegistrar(mEngine, super.registrarFor(pluginKey));
        }
    }

    public class BoostRegistrar implements PluginRegistry.Registrar {

        private final PluginRegistry.Registrar mRegistrar;
        private final FlutterEngine mEngine;

        BoostRegistrar(FlutterEngine engine, PluginRegistry.Registrar registrar) {
            mRegistrar = registrar;
            mEngine = engine;
        }

        @Override
        public Activity activity() {
            Activity activity;
            IContainerRecord record;

            record = FlutterBoost.singleton().containerManager().getCurrentTopRecord();
            if (record == null) {
                record = FlutterBoost.singleton().containerManager().getLastGenerateRecord();
            }

            if (record == null) {
                activity = FlutterBoost.singleton().currentActivity();
            } else {
                activity = record.getContainer().getContextActivity();
            }

            if (activity == null && mCurrentActivityRef != null) {
                activity = mCurrentActivityRef.get();
            }

            if (activity == null) {
                throw new RuntimeException("current has no valid Activity yet");
            }

            return activity;
        }

        @Override
        public Context context() {
            return mRegistrar.context();
        }

        @Override
        public Context activeContext() {
            return mRegistrar.activeContext();
        }

        @Override
        public BinaryMessenger messenger() {
            return mEngine.getDartExecutor();
        }

        @Override
        public TextureRegistry textures() {
            return mEngine.getRenderer();
        }

        @Override
        public PlatformViewRegistry platformViewRegistry() {
            return mRegistrar.platformViewRegistry();
        }

        @Override
        public FlutterView view() {
            throw new RuntimeException("should not use!!!");
        }

        @Override
        public String lookupKeyForAsset(String s) {
            return mRegistrar.lookupKeyForAsset(s);
        }

        @Override
        public String lookupKeyForAsset(String s, String s1) {
            return mRegistrar.lookupKeyForAsset(s, s1);
        }

        @Override
        public PluginRegistry.Registrar publish(Object o) {
            return mRegistrar.publish(o);
        }

        @Override
        public PluginRegistry.Registrar addRequestPermissionsResultListener(PluginRegistry.RequestPermissionsResultListener requestPermissionsResultListener) {
            return mRegistrar.addRequestPermissionsResultListener(requestPermissionsResultListener);
        }

        @Override
        public PluginRegistry.Registrar addActivityResultListener(PluginRegistry.ActivityResultListener activityResultListener) {
            return mRegistrar.addActivityResultListener(activityResultListener);
        }

        @Override
        public PluginRegistry.Registrar addNewIntentListener(PluginRegistry.NewIntentListener newIntentListener) {
            return mRegistrar.addNewIntentListener(newIntentListener);
        }

        @Override
        public PluginRegistry.Registrar addUserLeaveHintListener(PluginRegistry.UserLeaveHintListener userLeaveHintListener) {
            return mRegistrar.addUserLeaveHintListener(userLeaveHintListener);
        }

        @Override
        public PluginRegistry.Registrar addViewDestroyListener(PluginRegistry.ViewDestroyListener viewDestroyListener) {
            return mRegistrar.addViewDestroyListener(viewDestroyListener);
        }
    }

    private boolean viewportMetricsEqual(FlutterRenderer.ViewportMetrics a, FlutterRenderer.ViewportMetrics b) {
        return a != null && b != null &&
                a.height == b.height &&
                a.width == b.width &&
                a.devicePixelRatio == b.devicePixelRatio &&
                a.paddingBottom == b.paddingBottom &&
                a.paddingLeft == b.paddingLeft &&
                a.paddingRight == b.paddingRight &&
                a.paddingTop == b.paddingTop &&
                a.viewInsetLeft == b.viewInsetLeft &&
                a.viewInsetRight == b.viewInsetRight &&
                a.viewInsetTop == b.viewInsetTop &&
                a.viewInsetBottom == b.viewInsetBottom;
    }

    class FakeRender extends FlutterRenderer {

        private ViewportMetrics last;

        public FakeRender(FlutterJNI flutterJNI) {
            super(flutterJNI);
        }

        @Override
        public void setViewportMetrics(@NonNull ViewportMetrics viewportMetrics) {
            if (viewportMetrics.width > 0 && viewportMetrics.height > 0 /*&& !viewportMetricsEqual(last, viewportMetrics)*/) {
                last = viewportMetrics;
                Debuger.log("setViewportMetrics w:" + viewportMetrics.width + " h:" + viewportMetrics.height);
                super.setViewportMetrics(viewportMetrics);
            }
        }

        @Override
        public void attachToRenderSurface(@NonNull RenderSurface renderSurface) {
            Debuger.exception("should never called!");
        }

        @Override
        public void detachFromRenderSurface() {
            Debuger.exception("should never called!");
        }

        @Override
        public void addOnFirstFrameRenderedListener(@NonNull OnFirstFrameRenderedListener listener) {
            Debuger.exception("should never called!");
        }

        @Override
        public void removeOnFirstFrameRenderedListener(@NonNull OnFirstFrameRenderedListener listener) {
            Debuger.exception("should never called!");
        }

        @Override
        public SurfaceTextureEntry createSurfaceTexture() {
            Debuger.exception("should never called!");
            return null;
        }

        @Override
        public void surfaceCreated(Surface surface) {
            Debuger.exception("should never called!");
        }

        @Override
        public void surfaceChanged(int width, int height) {
            Debuger.exception("should never called!");
        }

        @Override
        public void surfaceDestroyed() {
            Debuger.exception("should never called!");
        }

        @Override
        public Bitmap getBitmap() {
            Debuger.exception("should never called!");
            return null;
        }

        @Override
        public void dispatchPointerDataPacket(ByteBuffer buffer, int position) {
            Debuger.exception("should never called!");
        }

        @Override
        public boolean isSoftwareRenderingEnabled() {
            Debuger.exception("should never called!");
            return false;
        }

        @Override
        public void setAccessibilityFeatures(int flags) {
            Debuger.exception("should never called!");
        }

        @Override
        public void setSemanticsEnabled(boolean enabled) {
            Debuger.exception("should never called!");
        }

        @Override
        public void dispatchSemanticsAction(int id, int action, ByteBuffer args, int argsPosition) {
            Debuger.exception("should never called!");
        }
    }
}
