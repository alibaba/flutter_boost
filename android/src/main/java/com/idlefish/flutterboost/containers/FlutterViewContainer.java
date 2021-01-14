package com.idlefish.flutterboost.containers;

import android.app.Activity;

import java.util.HashMap;
import java.util.Map;

/**
 * A container which contains the FlutterView
 */

public interface FlutterViewContainer {

    Activity getContextActivity();

    void finishContainer(Map<String, Object> result);

    String getUrl();
    HashMap<String, String> getUrlParams();

    String getUniqueId();

}
