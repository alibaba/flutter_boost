package com.idlefish.flutterboost;

import android.app.Activity;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.HashMap;

public class BoostNavigator {

    public static void pushRoute(String pageName, HashMap<String, Object> arguments) {
        FlutterBoost.instance().getPlugin().pushRoute(pageName, arguments, null);
    }

    public static String generateUniqueId(String pageName) {
        return FlutterBoost.instance().getPlugin().generateUniqueId(pageName);
    }

    public static void showTabRoute(String groupName, String uniqueId, String pageName, HashMap<String, Object> arguments) {
        FlutterBoost.instance().getPlugin().showTabRoute(groupName, uniqueId, pageName, arguments);
    }

    public static void popRoute(String uniqueId) {
        FlutterBoost.instance().getPlugin().popRoute(uniqueId, null);
        FlutterViewContainer container=FlutterBoost.instance().getContainerManager().findContainerById(uniqueId);
        if(container!=null){
            container.finishContainer(null);
        }
    }

    public static FlutterViewContainer findFlutterViewContainerById(String uniqueId) {
        return FlutterBoost.instance().getContainerManager().findContainerById(uniqueId);
    }

    public static FlutterViewContainer getTopFlutterViewContainer() {
        return FlutterBoost.instance().getContainerManager().getCurrentStackTop();
    }

    public static Activity getTopActivity() {
        return FlutterBoost.instance().getTopActivity();
    }

}