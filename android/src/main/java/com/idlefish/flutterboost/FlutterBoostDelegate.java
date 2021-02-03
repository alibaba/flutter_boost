package com.idlefish.flutterboost;

import java.util.HashMap;

public abstract class FlutterBoostDelegate {

    public String initialRoute(){
        return "/";
    }
    public String dartEntrypointFunctionName(){
        return  "main";
    }
    public abstract void  pushNativeRoute(String pageName, HashMap<String, String> arguments);
    public  abstract void pushFlutterRoute(String pageName, HashMap<String, String> arguments);

}
