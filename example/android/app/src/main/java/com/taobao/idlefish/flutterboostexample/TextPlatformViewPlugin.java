package com.taobao.idlefish.flutterboostexample;

import io.flutter.app.FlutterPluginRegistry;
import io.flutter.plugin.common.StandardMessageCodec;

public class TextPlatformViewPlugin {
    public static void register(FlutterPluginRegistry registry) {
        registry.getPlatformViewsController().getRegistry().registerViewFactory("plugins.test/view",
                new TextPlatformViewFactory(StandardMessageCodec.INSTANCE));
    }
}
