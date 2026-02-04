package com.idlefish.flutterboost.example;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.StandardMessageCodec;

public class TextPlatformViewPlugin implements FlutterPlugin {
    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        binding.getFlutterEngine().getPlatformViewsController().getRegistry().registerViewFactory("plugins.test/view",
                new TextPlatformViewFactory(StandardMessageCodec.INSTANCE));
    }

    @Override
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
    }
}
