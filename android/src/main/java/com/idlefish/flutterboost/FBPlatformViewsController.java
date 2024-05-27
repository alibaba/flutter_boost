package com.idlefish.flutterboost;

import android.content.Context;
import android.view.View;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.mutatorsstack.FlutterMutatorView;
import io.flutter.plugin.platform.PlatformViewsController;
import io.flutter.view.TextureRegistry;

/**
 *
 * fix issues:
 * <a href="https://github.com/alibaba/flutter_boost/issues/1755"/>
 * <a href="https://github.com/alibaba/flutter_boost/issues/1834"/>
 *
 * @author : Joe Chan
 * @date : 2024/5/22 13:35
 */
public class FBPlatformViewsController extends PlatformViewsController {

    private Context appCtx;

    /**
     * 记录PlatformViewsController绑定使用的FlutterView
     */
    private FlutterView curFlutterView = null;

    /**
     * 占位FlutterView，用于防止不执行完整detach后，内部channelHandler继续响应时，出现空指针异常。
     */
    private FlutterView dummyFlutterView = null;

    public FBPlatformViewsController() {
        super();
    }

    @Override
    public void attach(@Nullable Context context, @NonNull TextureRegistry textureRegistry,
                       @NonNull DartExecutor dartExecutor) {
        if (appCtx == null && context != null) {
            appCtx = context.getApplicationContext();
            dummyFlutterView = new FlutterView(appCtx);
        }
        super.attach(context, textureRegistry, dartExecutor);
    }

    @Override
    public void detach() {
        // 不执行完整的detach，这样就使内部channelHandler正确响应，同时避免platformView触摸事件无法响应
        // super.detach();
        // 使用反射将内部context变量设置为null，一方面解决重新attach时的异常，另一方面解决内存泄漏
        try {
            Field contextF = getClass().getSuperclass().getDeclaredField("context");
            contextF.setAccessible(true);
            contextF.set(this, null);
        } catch (Exception ignore) {
        }
        destroyOverlaySurfaces();
    }

    @Override
    public void attachToView(@NonNull FlutterView newFlutterView) {
        if (curFlutterView == null) {
            super.attachToView(newFlutterView);
            curFlutterView = newFlutterView;
        } else if (newFlutterView != curFlutterView) {
            removePlatformWrapperOrParents();
            super.attachToView(newFlutterView);
            curFlutterView = newFlutterView;
        }
    }


    @Override
    public void detachFromView() {
        if (curFlutterView != null) {
            super.detachFromView();
            curFlutterView = null;
            //将占位FlutterView绑定上去
            attachToView(dummyFlutterView);
        }
    }

    public void removePlatformWrapperOrParents() {
        if (curFlutterView != null) {
            List<View> needRemoveViews = new ArrayList<>();
            int childCount = curFlutterView.getChildCount();
            for (int i = 0; i < childCount; i++) {
                View view = curFlutterView.getChildAt(i);
                if (view.getClass().getName().contains("PlatformViewWrapper") || view instanceof FlutterMutatorView) {
                    needRemoveViews.add(view);
                }
            }
            if (!needRemoveViews.isEmpty()) {
                for (View needRemoveView : needRemoveViews) {
                    curFlutterView.removeView(needRemoveView);
                }
            }
        }
    }
}
