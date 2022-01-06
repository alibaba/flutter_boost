package com.idlefish.flutterboost;

public interface FlutterBoostDelegate {
    void pushNativeRoute(FlutterBoostRouteOptions options);
    void pushFlutterRoute(FlutterBoostRouteOptions options);
    default boolean popRoute(FlutterBoostRouteOptions options){
        return  false;
    }
}
