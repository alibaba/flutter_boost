package com.idlefish.flutterboost;

import android.app.Activity;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.util.Map;

public class BoostNavigator {

    public static void pushRoute(String pageName, String uniqueId, Map arguments) {
        FlutterRouterApi.instance().pushRoute(pageName, uniqueId, arguments, null);
    }

    public static String generateUniqueId(String pageName) {
        return FlutterRouterApi.instance().generateUniqueId(pageName);
    }

    public static void showRoute(String groupName, String uniqueId, String pageName, Map arguments) {
        FlutterRouterApi.instance().showRoute(groupName, uniqueId, pageName, arguments);
    }

    public static void popRoute(String uniqueId) {
        FlutterRouterApi.instance().popRoute(uniqueId, null);
    }

    public static FlutterViewContainer findFlutterViewContainerById(String uniqueId) {
        return ContainerManager.instance().findContainerById(uniqueId);
    }

    public static FlutterViewContainer getTopFlutterViewContainer() {
        return ContainerManager.instance().getCurrentStackTop();
    }

    public static Activity getTopActivity() {
        return FlutterBoost.instance().getTopActivity();
    }

}