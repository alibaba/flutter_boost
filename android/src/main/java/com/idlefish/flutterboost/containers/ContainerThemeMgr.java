package com.idlefish.flutterboost.containers;

import com.idlefish.flutterboost.FlutterBoostUtils;

import java.util.HashMap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.UiThread;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;

/**
 * @author : Joe Chan
 * @date : 2024/3/8 11:30
 */
public class ContainerThemeMgr {
    private static final HashMap<Integer, PlatformChannel.SystemChromeStyle> themes =
            new HashMap<>();
    private static PlatformChannel.SystemChromeStyle finalStyle;

    @UiThread
    public static void onActivityPause(@NonNull FlutterBoostActivity activity, PlatformChannel.SystemChromeStyle restoreTheme) {
        finalStyle = null;
        if (activity.platformPlugin == null) {
            return;
        }
        int hash = activity.hashCode();
        PlatformChannel.SystemChromeStyle style =
                FlutterBoostUtils.getCurrentSystemUiOverlayTheme(activity.platformPlugin, true);
        PlatformChannel.SystemChromeStyle mergedStyle = FlutterBoostUtils.mergeSystemChromeStyle(restoreTheme, style);
        if (mergedStyle != null) {
            themes.put(hash, mergedStyle);
        }
    }

    @UiThread
    public static void onActivityDestroy(@NonNull FlutterBoostActivity activity) {
        PlatformChannel.SystemChromeStyle style = themes.remove(activity.hashCode());
        if (themes.isEmpty()) {
            finalStyle = style;
        }
    }

    @Nullable
    public static PlatformChannel.SystemChromeStyle findTheme(@NonNull FlutterBoostActivity activity) {
        return themes.get(activity.hashCode());
    }

    public static PlatformChannel.SystemChromeStyle getFinalStyle() {
        return FlutterBoostUtils.copySystemChromeStyle(finalStyle);
    }
}
