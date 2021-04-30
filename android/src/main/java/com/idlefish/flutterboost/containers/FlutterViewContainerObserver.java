package com.idlefish.flutterboost.containers;

public interface FlutterViewContainerObserver {
    void onCreateView();
    void onAppear();
    void onDisappear();
    void onDestroyView();
}

