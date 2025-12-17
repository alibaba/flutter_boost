package com.idlefish.flutterboost.example;

import io.flutter.plugin.common.StandardMessageCodec;
// lijizhi: PluginRegistry.Registrar 在新版本 Flutter 中已被移除，使用新的插件注册方式
// import io.flutter.plugin.common.PluginRegistry;

public class TextPlatformViewPlugin {
    // lijizhi: 旧的插件注册方式已废弃，需要在 FlutterEngine 中注册
    // public static void register(PluginRegistry.Registrar registrar) {
    //     registrar.platformViewRegistry().registerViewFactory("plugins.test/view",
    //             new TextPlatformViewFactory(StandardMessageCodec.INSTANCE));
    // }
}
