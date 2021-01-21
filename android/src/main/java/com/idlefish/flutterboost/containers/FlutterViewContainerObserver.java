package com.idlefish.flutterboost.containers;

public interface FlutterViewContainerObserver {
    void onCreateView();
    void onAppear(@ChangeReason int reason);
    void onDisappear(@ChangeReason int reason);
    void onDestroyView();
}

