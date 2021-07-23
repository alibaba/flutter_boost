package com.idlefish.flutterboost;

import android.content.Intent;

import java.util.Map;

public interface FlutterBoostDelegate {
    void pushNativeRoute(FlutterBoostRouteOptions options);
    void pushFlutterRoute(FlutterBoostRouteOptions options);
    Map<Object, Object> handleActivityResult(Intent intent);
}
