package com.idlefish.flutterboost;

import java.util.Map;

public interface NativeRouterApi {

    void pushNativeRoute(
            String pageName, String uniqueId, Map arguments);

    void pushFlutterRoute(
            String pageName, String uniqueId, Map arguments);

    void popRoute(String pageName, String uniqueId);


}