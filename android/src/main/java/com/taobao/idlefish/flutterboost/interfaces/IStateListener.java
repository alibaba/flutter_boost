package com.taobao.idlefish.flutterboost.interfaces;

import com.taobao.idlefish.flutterboost.BoostFlutterEngine;
import com.taobao.idlefish.flutterboost.BoostFlutterView;

public interface IStateListener {
    void onEngineCreated(BoostFlutterEngine engine);
    void onEngineStarted(BoostFlutterEngine engine);
    void onFlutterViewInited(BoostFlutterEngine engine, BoostFlutterView flutterView);
    void beforeEngineAttach(BoostFlutterEngine engine, BoostFlutterView flutterView);
    void afterEngineAttached(BoostFlutterEngine engine, BoostFlutterView flutterView);
    void beforeEngineDetach(BoostFlutterEngine engine, BoostFlutterView flutterView);
    void afterEngineDetached(BoostFlutterEngine engine, BoostFlutterView flutterView);
}
