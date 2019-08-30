package com.idlefish.flutterboost.interfaces;

import com.idlefish.flutterboost.BoostChannel;
import com.idlefish.flutterboost.BoostFlutterEngine;
import com.idlefish.flutterboost.BoostFlutterView;

import io.flutter.plugin.common.PluginRegistry;

public interface IStateListener {
    void onEngineCreated(BoostFlutterEngine engine);
    void onEngineStarted(BoostFlutterEngine engine);
    void onChannelRegistered(PluginRegistry.Registrar registrar, BoostChannel channel);
    void onFlutterViewInited(BoostFlutterEngine engine, BoostFlutterView flutterView);
    void beforeEngineAttach(BoostFlutterEngine engine, BoostFlutterView flutterView);
    void afterEngineAttached(BoostFlutterEngine engine, BoostFlutterView flutterView);
    void beforeEngineDetach(BoostFlutterEngine engine, BoostFlutterView flutterView);
    void afterEngineDetached(BoostFlutterEngine engine, BoostFlutterView flutterView);
}
