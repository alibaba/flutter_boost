package com.idlefish.flutterboost.invoke;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.renderer.RenderSurface;

/**
 * 通过动态代理的方式，拦截RenderSurface(FlutterTextureView、FlutterSurfaceView)的接口调用。
 *
 * @author : joechan-cq
 * @date : 2024/2/23 11:37
 */
public class RenderSurfaceHandler implements InvocationHandler {
    private final Object target;

    public RenderSurfaceHandler(Object target) {
        this.target = target;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        // fix issue {https://github.com/alibaba/flutter_boost/issues/1960} with flutter 3.19
        // 理想情况下，应该拦截resume方法，不过因为动态代理无法拦截内部调用，所以只能拦截attachToRender方法
        // 为了减少影响，选择在调用startRenderingToSurface前（而不是detach后），将isPaused变量通过反射，设置为false
        if ("attachToRenderer".equals(method.getName())) {
            reflectAndSetVarPaused(target, false);
        }
        Object result = method.invoke(target, args);
        return result;
    }

    private void reflectAndSetVarPaused(Object target, boolean value) {
        if (target != null) {
            try {
                Field isPausedF = target.getClass().getDeclaredField("isPaused");
                isPausedF.setAccessible(true);
                boolean paused = isPausedF.getBoolean(target);
                if (paused != value) {
                    isPausedF.setBoolean(target, value);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void inject(FlutterView flutterView) {
        if (flutterView != null) {
            try {
                Field renderSurfaceF = flutterView.getClass().getDeclaredField("renderSurface");
                renderSurfaceF.setAccessible(true);
                Object renderSurface = renderSurfaceF.get(flutterView);
                if (renderSurface != null) {
                    RenderSurfaceHandler handler = new RenderSurfaceHandler(renderSurface);

                    // 创建动态代理对象
                    RenderSurface proxy = (RenderSurface) Proxy.newProxyInstance(
                            renderSurface.getClass().getClassLoader(),
                            renderSurface.getClass().getInterfaces(),
                            handler
                    );
                    renderSurfaceF.set(flutterView, proxy);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
