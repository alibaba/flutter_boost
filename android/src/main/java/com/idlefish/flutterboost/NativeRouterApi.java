package com.idlefish.flutterboost;

import java.util.Map;

public abstract class  NativeRouterApi {

    public abstract void pushNativeRoute(
            String pageName,  Map arguments);

    public abstract void pushFlutterRoute(
            String pageName, String uniqueId, Map arguments);

    public void popRoute(String pageName, String uniqueId){
        FlutterBoost.instance().getTopActivity().finish();
    }

}