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
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.fragment.app.FragmentActivity;

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
    public static PlatformChannel.SystemChromeStyle getCurrentSystemUiOverlayTheme(PlatformPlugin platformPlugin) {
        if (platformPlugin != null) {
            try {
                Field field = platformPlugin.getClass().getDeclaredField("currentTheme");
                field.setAccessible(true);
                return (PlatformChannel.SystemChromeStyle) field.get(platformPlugin);
            } catch (NoSuchFieldException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public static void setCurrentSystemUiOverlayTheme(PlatformPlugin platformPlugin, PlatformChannel.SystemChromeStyle currentTheme) {
        if (platformPlugin != null) {
            try {
                Field field = platformPlugin.getClass().getDeclaredField("currentTheme");
                field.setAccessible(true);
                field.set(platformPlugin, currentTheme);
            } catch (NoSuchFieldException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }
    }

    public static void setSystemChromeSystemUIOverlayStyle(@NonNull Activity activity,
                                                           PlatformChannel.SystemChromeStyle systemChromeStyle) {
        Window window = activity.getWindow();
        View view = window.getDecorView();
        WindowInsetsControllerCompat windowInsetsControllerCompat =
                new WindowInsetsControllerCompat(window, view);

        if (Build.VERSION.SDK_INT < 30) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.clearFlags(
                    WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                            | WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        }
        if (Build.VERSION.SDK_INT >= 23) {
            if (systemChromeStyle.statusBarIconBrightness != null) {
                switch (systemChromeStyle.statusBarIconBrightness) {
                    case DARK:
                        windowInsetsControllerCompat.setAppearanceLightStatusBars(true);
                        break;
                    case LIGHT:
                        windowInsetsControllerCompat.setAppearanceLightStatusBars(false);
                        break;
                }
            }

            if (systemChromeStyle.statusBarColor != null) {
                window.setStatusBarColor(systemChromeStyle.statusBarColor);
            }
        }
        if (systemChromeStyle.systemStatusBarContrastEnforced != null && Build.VERSION.SDK_INT >= 29) {
            window.setStatusBarContrastEnforced(systemChromeStyle.systemStatusBarContrastEnforced);
        }

        if (Build.VERSION.SDK_INT >= 26) {
            if (systemChromeStyle.systemNavigationBarIconBrightness != null) {
                switch (systemChromeStyle.systemNavigationBarIconBrightness) {
                    case DARK:
                        windowInsetsControllerCompat.setAppearanceLightNavigationBars(true);
                        break;
                    case LIGHT:
                        windowInsetsControllerCompat.setAppearanceLightNavigationBars(false);
                        break;
                }
            }

            if (systemChromeStyle.systemNavigationBarColor != null) {
                window.setNavigationBarColor(systemChromeStyle.systemNavigationBarColor);
            }
        }
        if (systemChromeStyle.systemNavigationBarDividerColor != null && Build.VERSION.SDK_INT >= 28) {
            window.setNavigationBarDividerColor(systemChromeStyle.systemNavigationBarDividerColor);
        }
        if (systemChromeStyle.systemNavigationBarContrastEnforced != null
                && Build.VERSION.SDK_INT >= 29) {
            window.setNavigationBarContrastEnforced(
                    systemChromeStyle.systemNavigationBarContrastEnforced);
        }
    }
}