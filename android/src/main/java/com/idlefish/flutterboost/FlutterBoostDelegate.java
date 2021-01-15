package com.idlefish.flutterboost;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.HashMap;

public abstract class FlutterBoostDelegate {

    public abstract void pushNativeRoute(
            String pageName, HashMap<String, String> arguments);

    public abstract void pushFlutterRoute(
            String pageName, HashMap<String, String> arguments);

    public void popRoute(String pageName, String uniqueId) {
        FlutterViewContainer container=FlutterBoost.instance().getContainerManager().findContainerById(uniqueId);
        if(container!=null){
            container.finishContainer(null);
        }
    }

}
