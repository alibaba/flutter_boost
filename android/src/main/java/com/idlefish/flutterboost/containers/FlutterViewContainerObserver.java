package com.idlefish.flutterboost.containers;

public interface FlutterViewContainerObserver {
    public void onCreateView();

    public void onResume();

    public void onPause();

    public void onStop();

    public void onDestroyView();
}

