package com.idlefish.flutterboost;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.HashMap;

public abstract class NativeRouterApi {

    public abstract void pushNativeRoute(
            String pageName, HashMap<String, Object> arguments);

    public abstract void pushFlutterRoute(
            String pageName, String uniqueId, HashMap<String, Object> arguments);

    public void popRoute(String pageName, String uniqueId) {
        FlutterViewContainer container=FlutterBoost.instance().getContainerManager().findContainerById(uniqueId);
        if(container!=null){
            container.finishContainer(null);
        }
    }

}