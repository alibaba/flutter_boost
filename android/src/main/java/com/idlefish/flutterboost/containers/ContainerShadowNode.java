package com.idlefish.flutterboost.containers;

import com.idlefish.flutterboost.FlutterBoost;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

public class ContainerShadowNode implements FlutterViewContainerObserver {
    private WeakReference<FlutterViewContainer> container;

    public static FlutterViewContainerObserver create(FlutterViewContainer container) {
        return new ContainerShadowNode(container);
    }

    private ContainerShadowNode(FlutterViewContainer container) {
        assert container != null;
        this.container = new WeakReference<FlutterViewContainer>(container);
    }

    @Override
    public void onCreateView() {
        // todo:
        android.util.Log.e("xlog", "## FlutterViewContainerObserver#onCreateView: " + container.get().getUniqueId());
    }

    @Override
    public void onAppear() {
        // todo:
        assert container.get() != null;
        FlutterBoost.instance().getPlugin().pushRoute(container.get().getUniqueId(), container.get().getUrl(), container.get().getUrlParams(),null);
        android.util.Log.e("xlog", "## FlutterViewContainerObserver#onAppear: " + container.get().getUniqueId());
    }

    @Override
    public void onDisappear() {
        // todo:
        android.util.Log.e("xlog", "## FlutterViewContainerObserver#onDisappear: " + container.get().getUniqueId());
    }

    @Override
    public void onDestroyView() {
        FlutterBoost.instance().getPlugin().popRoute(container.get().getUniqueId(), null);
        android.util.Log.e("xlog", "## FlutterViewContainerObserver#onDestroyView: " + container.get().getUniqueId());
    }
}
