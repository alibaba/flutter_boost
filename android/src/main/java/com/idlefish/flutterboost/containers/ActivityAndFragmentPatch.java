package com.idlefish.flutterboost.containers;


import android.app.Activity;
import android.os.Build;
import android.view.View;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterRouterApi;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.engine.FlutterEngine;

/**
 * 在官方ActivityAndFragment的基础上进行补充修复
 * 1.指定getRenderMode 为texture,不然页面切换时候会前后页面会重叠
 * 2.接管键盘回退事件
 * 3. 把 attachToFlutterEngine，调用时机放到onResume。
 * 4. onPause 时 flutterView.detachFromFlutterEngine()
 * <p>
 * 5. FlutterActivityAndFragmentDelegate 去除flutterEngine.getLifecycleChannel().appIsDetached
 * 6. FlutterActivityAndFragmentDelegate 去除flutterEngine.getLifecycleChannel().appIsPaused
 */
public class ActivityAndFragmentPatch {

    /**
     * 重写 getRenderMode ,boost指定texture
     *
     * @return
     */
    public static RenderMode getRenderMode() {
        return RenderMode.texture;
    }

    /**
     * 重写onBackPressed
     */
    public static void onBackPressed() {
        FlutterRouterApi.instance().popRoute(new FlutterRouterApi.Reply<Void>() {

            @Override
            public void reply(Void reply) {

            }
        });
    }

    /**
     * 添加 attachToFlutterEngine
     * 只有在栈顶的容器才能attachToFlutterEngine
     * 防止在android 10上，
     * 栈为 f1-n-f2 ，n 背景透明时候，
     * 打开f2 ，f2先执行onResume 同时f1 也执行了onResume 生命周期
     * flutterEngine 被f1 attach，导致f2页面卡死。
     *
     * @param
     * @param
     */
    public static void onResumeAttachToFlutterEngine(FlutterBoostFragment fragment) {
        FlutterView flutterView = fragment.delegate.getFlutterView();
        FlutterEngine flutterEngine = fragment.delegate.getFlutterEngine();
        Object object = FlutterBoost.instance().getContainerManager().getCurrentStackTop();

        if ((object == null) || (object == fragment)) {
            flutterView.attachToFlutterEngine(flutterEngine);
        }
        flutterEngine.getLifecycleChannel().appIsResumed();
    }

    public static void onResumeAttachToFlutterEngine(FlutterBoostActvity activity) {
        FlutterView flutterView = activity.delegate.getFlutterView();
        FlutterEngine flutterEngine = activity.delegate.getFlutterEngine();
        Object object = FlutterBoost.instance().getContainerManager().getCurrentStackTop();
        if ((object == null) || (object == activity)) {
            flutterView.attachToFlutterEngine(flutterEngine);
        }
        flutterEngine.getLifecycleChannel().appIsResumed();
    }

    /**
     * 添加 detachFromFlutterEngine
     *
     * @param flutterView
     */
    public static void onPauseDetachFromFlutterEngine(FlutterView flutterView, FlutterEngine flutterEngine) {
        flutterView.detachFromFlutterEngine();
        flutterEngine.getLifecycleChannel().appIsInactive();
    }

    public static void setStackTop(Object  object) {
        FlutterBoost.instance().getContainerManager().setStackTop(object);
    }

    public static void removeStackTop(Object  object) {
        FlutterBoost.instance().getContainerManager().removeStackTop(object);
    }
    public static void pushContainer(Activity  activity) {
        String uniqueId=activity.getIntent().getStringExtra(FlutterActivityLaunchConfigs.UNIQUE_ID);
        FlutterBoost.instance().getContainerManager().addContainer(uniqueId, activity);
    }

    public static void removeContainer(Activity  activity) {
        String uniqueId=activity.getIntent().getStringExtra(FlutterActivityLaunchConfigs.UNIQUE_ID);
        FlutterBoost.instance().getContainerManager().removeContainer(uniqueId);
    }
}
