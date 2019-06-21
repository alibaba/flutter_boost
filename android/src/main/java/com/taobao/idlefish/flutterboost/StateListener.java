package com.taobao.idlefish.flutterboost;

import com.taobao.idlefish.flutterboost.interfaces.IStateListener;

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
