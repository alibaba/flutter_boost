package com.idlefish.flutterboost;

import java.util.HashMap;

public interface FlutterBoostDelegate {
    default String initialRoute(){
        return "/";
    }
    default String dartEntrypointFunctionName(){
        return  "main";
    }
    void pushNativeRoute(String pageName, HashMap<String, String> arguments);
    void pushFlutterRoute(String pageName, String uniqueId, HashMap<String, String> arguments);
}
