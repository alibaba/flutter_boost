package com.idlefish.flutterboost;

import com.idlefish.flutterboost.interfaces.IStateListener;

import io.flutter.plugin.common.PluginRegistry;

public class StateListener implements IStateListener {
    @Override
    public void onEngineCreated(BoostFlutterEngine engine) {
        Debuger.log(">>onEngineCreated");
    }

    @Override
    public void onEngineStarted(BoostFlutterEngine engine) {
        Debuger.log(">>onEngineStarted");
    }

    @Override
    public void onChannelRegistered(PluginRegistry.Registrar registrar, BoostChannel channel) {
        Debuger.log(">>onFlutterViewInited");
    }

    @Override
    public void onFlutterViewInited(BoostFlutterEngine engine, BoostFlutterView flutterView) {
        Debuger.log(">>onFlutterViewInited");
    }

    @Override
    public void beforeEngineAttach(BoostFlutterEngine engine, BoostFlutterView flutterView) {
        Debuger.log(">>beforeEngineAttach");
    }

    @Override
    public void afterEngineAttached(BoostFlutterEngine engine, BoostFlutterView flutterView) {
        Debuger.log(">>afterEngineAttached");
    }

    @Override
    public void beforeEngineDetach(BoostFlutterEngine engine, BoostFlutterView flutterView) {
        Debuger.log(">>beforeEngineDetach");
    }

    @Override
    public void afterEngineDetached(BoostFlutterEngine engine, BoostFlutterView flutterView) {
        Debuger.log(">>afterEngineDetached");
    }
}
