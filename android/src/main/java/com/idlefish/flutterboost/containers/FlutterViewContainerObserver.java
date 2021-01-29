package com.idlefish.flutterboost.containers;

public interface FlutterViewContainerObserver {
    void onCreateView();
    void onAppear(ChangeReason reason);
    void onDisappear(ChangeReason reason);
    void onDestroyView();
}

