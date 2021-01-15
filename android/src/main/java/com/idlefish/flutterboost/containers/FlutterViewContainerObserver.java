package com.idlefish.flutterboost.containers;

public interface FlutterViewContainerObserver {
    public void onCreateView();

    public void onAppear();

    public void onDisappear();

    public void onDestroyView();
}

