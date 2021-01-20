package com.idlefish.flutterboost;

import java.util.HashMap;

public interface FlutterBoostDelegate {
    void pushNativeRoute(String pageName, HashMap<String, String> arguments);
    void pushFlutterRoute(String pageName, HashMap<String, String> arguments);
}
