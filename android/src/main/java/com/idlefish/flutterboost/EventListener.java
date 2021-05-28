package com.idlefish.flutterboost;

import java.util.Map;

public interface EventListener {
    void onEvent(String key, Map<Object, Object> args);
}