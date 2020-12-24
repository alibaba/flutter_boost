package com.idlefish.flutterboost;

import android.content.Context;

import io.flutter.embedding.engine.plugins.FlutterPlugin;


public class FlutterBoostPlugin implements FlutterPlugin {

    private Context context;

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        RouterApiChannel.setup(binding.getBinaryMessenger());
        FlutterRouterApi.setup(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {

    }
}