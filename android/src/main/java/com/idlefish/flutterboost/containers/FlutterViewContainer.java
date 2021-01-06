package com.idlefish.flutterboost.containers;

import android.app.Activity;

import java.util.Map;

public interface FlutterViewContainer {

    Activity getContextActivity();

    void finishContainer(Map<String, Object> result);

    String getContainerUrl();

    String getUniqueId();

}
