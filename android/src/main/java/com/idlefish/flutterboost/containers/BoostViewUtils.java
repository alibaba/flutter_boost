package com.idlefish.flutterboost.containers;

import com.idlefish.flutterboost.XPlatformPlugin;

import io.flutter.embedding.engine.systemchannels.PlatformChannel;

class BoostViewUtils {

    private static volatile XPlatformPlugin mInstance;

    private BoostViewUtils() {
    }

    public static XPlatformPlugin getPlatformPlugin(PlatformChannel channel) {
        if (mInstance == null) {
            synchronized (BoostViewUtils.class) {
                if (mInstance == null) {
                    mInstance = new XPlatformPlugin(channel);
                }
            }
        }
        return mInstance;
    }
}
