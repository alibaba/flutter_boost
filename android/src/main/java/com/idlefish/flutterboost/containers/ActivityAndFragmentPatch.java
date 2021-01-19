package com.idlefish.flutterboost.containers;

import com.idlefish.flutterboost.FlutterBoost;

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
        FlutterBoost.instance().getPlugin().popRoute(null, null);
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
    public static void onResumeAttachToFlutterEngine(FlutterView flutterView, FlutterEngine flutterEngine, FlutterViewContainer container) {
        Object object = FlutterBoost.instance().getContainerManager().getCurrentStackTop();
        if ((object == null) || (object == container)) {
            if(!flutterView.isAttachedToFlutterEngine()){
                flutterView.attachToFlutterEngine(flutterEngine);
            }
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

    public static void setStackTop(FlutterViewContainer object) {
        FlutterBoost.instance().getContainerManager().setStackTop(object);
    }

    public static void removeStackTop(FlutterViewContainer object) {
        FlutterBoost.instance().getContainerManager().removeStackTop(object);
    }

    public static void pushContainer(FlutterViewContainer container) {
        FlutterBoost.instance().getContainerManager().addContainer(container);
    }

    public static void removeContainer(FlutterViewContainer container) {
        FlutterBoost.instance().getContainerManager().removeContainer(container.getUniqueId());
    }
}
