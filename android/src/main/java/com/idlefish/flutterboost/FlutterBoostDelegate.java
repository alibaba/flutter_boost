package com.idlefish.flutterboost;

import java.util.Map;

public interface FlutterBoostDelegate {
    void pushNativeRoute(String pageName, Map<String, Object> arguments,int requestCode);
    void pushFlutterRoute(String pageName, String uniqueId, Map<String, Object> arguments);
}
