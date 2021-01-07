package com.idlefish.flutterboost;

import android.app.Activity;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.Map;

public class BoostNavigator {

    public static void pushRoute(String pageName, Map arguments) {
        FlutterBoost.instance().getFlutterRouterApi().pushRoute(pageName, arguments, null);
    }

    public static String generateUniqueId(String pageName) {
        return FlutterBoost.instance().getFlutterRouterApi().generateUniqueId(pageName);
    }

    public static void showTabRoute(String groupName, String uniqueId, String pageName, Map arguments) {
        FlutterBoost.instance().getFlutterRouterApi().showTabRoute(groupName, uniqueId, pageName, arguments);
    }

    public static void popRoute(String uniqueId) {
        FlutterBoost.instance().getFlutterRouterApi().popRoute(uniqueId, null);
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