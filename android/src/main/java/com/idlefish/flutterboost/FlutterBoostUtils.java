// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.idlefish.flutterboost;

import android.app.Activity;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.WindowInsetsControllerCompat;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.platform.PlatformPlugin;

/**
 * Helper methods to deal with common tasks.
 */
public class FlutterBoostUtils {
    // Control whether the internal debugging logs are turned on.
    private static boolean sEnableDebugLogging = false;

    public static void setDebugLoggingEnabled(boolean enable) {
        sEnableDebugLogging = enable;
    }

    public static boolean isDebugLoggingEnabled() {
        return sEnableDebugLogging;
    }

    public static String createUniqueId(String name) {
        return UUID.randomUUID().toString() + "_" + name;
    }

    public static FlutterBoostPlugin getPlugin(FlutterEngine engine) {
        if (engine != null) {
            try {
                Class<? extends FlutterPlugin> pluginClass =
                        (Class<? extends FlutterPlugin>) Class.forName("com.idlefish.flutterboost.FlutterBoostPlugin");
                return (FlutterBoostPlugin) engine.getPlugins().get(pluginClass);
            } catch (Throwable t) {
                t.printStackTrace();
            }
        }
        return null;
    }

    public static Map<String, Object> bundleToMap(Bundle bundle) {
        Map<String, Object> map = new HashMap<>();
        if (bundle == null || bundle.keySet().isEmpty()) {
            return map;
        }
        Set<String> keys = bundle.keySet();
        for (String key : keys) {
            Object value = bundle.get(key);
            if (value instanceof Bundle) {
                map.put(key, bundleToMap(bundle.getBundle(key)));
            } else if (value != null) {
                map.put(key, value);
            }
        }
        return map;
    }

    public static FlutterView findFlutterView(View view) {
        if (view instanceof FlutterView) {
            return (FlutterView) view;
        }
        if (view instanceof ViewGroup) {
            ViewGroup vp = (ViewGroup) view;
            for (int i = 0; i < vp.getChildCount(); i++) {
                View child = vp.getChildAt(i);
                FlutterView fv = findFlutterView(child);
                if (fv != null) {
                    return fv;
                }
            }
        }
        return null;
    }

    @Nullable
    public static PlatformChannel.SystemChromeStyle getCurrentSystemUiOverlayTheme(PlatformPlugin platformPlugin, boolean copy) {
        if (platformPlugin != null) {
            try {
                Field field = platformPlugin.getClass().getDeclaredField("currentTheme");
                field.setAccessible(true);
                PlatformChannel.SystemChromeStyle style =
                        (PlatformChannel.SystemChromeStyle) field.get(platformPlugin);
                if (!copy || style == null) {
                    return style;
                } else {
                    return copySystemChromeStyle(style);
                }
            } catch (NoSuchFieldException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public static PlatformChannel.SystemChromeStyle copySystemChromeStyle(PlatformChannel.SystemChromeStyle style) {
        if (style == null) {
            return null;
        }
        return new PlatformChannel.SystemChromeStyle(
                style.statusBarColor,
                style.statusBarIconBrightness,
                style.systemStatusBarContrastEnforced,
                style.systemNavigationBarColor,
                style.systemNavigationBarIconBrightness,
                style.systemNavigationBarDividerColor,
                style.systemNavigationBarContrastEnforced
        );
    }

    public static PlatformChannel.SystemChromeStyle mergeSystemChromeStyle(PlatformChannel.SystemChromeStyle old, PlatformChannel.SystemChromeStyle ne_w) {
        if (ne_w == null) {
            return copySystemChromeStyle(old);
        }
        if (old == null) {
            return copySystemChromeStyle(ne_w);
        }
        return new PlatformChannel.SystemChromeStyle(
                ne_w.statusBarColor != null ? ne_w.statusBarColor : old.statusBarColor,
                ne_w.statusBarIconBrightness != null ? ne_w.statusBarIconBrightness : old.statusBarIconBrightness,
                ne_w.systemStatusBarContrastEnforced != null ? ne_w.systemStatusBarContrastEnforced : old.systemStatusBarContrastEnforced,
                ne_w.systemNavigationBarColor != null ? ne_w.systemNavigationBarColor : old.systemNavigationBarColor,
                ne_w.systemNavigationBarIconBrightness != null ? ne_w.systemNavigationBarIconBrightness : old.systemNavigationBarIconBrightness,
                ne_w.systemNavigationBarDividerColor != null ? ne_w.systemNavigationBarDividerColor : old.systemNavigationBarDividerColor,
                ne_w.systemNavigationBarContrastEnforced != null ? ne_w.systemNavigationBarContrastEnforced : old.systemNavigationBarContrastEnforced
        );
    }

    public static void setSystemChromeSystemUIOverlayStyle(@NonNull PlatformPlugin platformPlugin,
                                                           @NonNull PlatformChannel.SystemChromeStyle systemChromeStyle) {
        try {
            Method mth = platformPlugin.getClass().getDeclaredMethod(
                    "setSystemChromeSystemUIOverlayStyle", PlatformChannel.SystemChromeStyle.class);
            mth.setAccessible(true);
            mth.invoke(platformPlugin, systemChromeStyle);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            throw new RuntimeException(e);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }
    }
}