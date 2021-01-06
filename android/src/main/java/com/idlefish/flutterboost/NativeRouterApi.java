package com.idlefish.flutterboost;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.Map;

public abstract class NativeRouterApi {

    public abstract void pushNativeRoute(
            String pageName, Map arguments);

    public abstract void pushFlutterRoute(
            String pageName, String uniqueId, Map arguments);

    public void popRoute(String pageName, String uniqueId) {
        FlutterViewContainer container=FlutterBoost.instance().getContainerManager().findContainerById(uniqueId);
        if(container!=null){
            container.finishContainer(null);
        }
    }

}