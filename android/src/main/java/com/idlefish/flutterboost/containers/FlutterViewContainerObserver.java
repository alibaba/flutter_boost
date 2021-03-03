package com.idlefish.flutterboost.containers;

public interface FlutterViewContainerObserver {
    void onCreateView();
    void onAppear(InitiatorLocation location);
    void onDisappear(InitiatorLocation location);
    void onDestroyView();
}

