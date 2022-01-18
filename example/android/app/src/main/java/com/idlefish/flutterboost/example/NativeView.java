package com.idlefish.flutterboost.example;

import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.platform.PlatformView;
import java.util.Map;
import java.util.Random;

class NativeView implements PlatformView {
   @NonNull private final TextView textView;

    NativeView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        textView = new TextView(context);
        textView.setTextSize(12);

        Random rnd = new Random();
        int color = Color.argb(255, rnd.nextInt(256), rnd.nextInt(256), rnd.nextInt(256));
        textView.setBackgroundColor(color);
        textView.setGravity(Gravity.CENTER_VERTICAL | Gravity.CENTER_HORIZONTAL);

        StringBuilder sb = new StringBuilder();
        sb.append("Native Android view (id: " + id + ")\n\n");
        for (Map.Entry<String, Object> entry : creationParams.entrySet()) {
            sb.append(entry.getKey() + ": " + entry.getValue().toString()).append("\n");
        }
        textView.setText(sb.toString());
        Log.e("xlog", "#NativeView: <ctor> " + sb.toString());
    }

    @NonNull
    @Override
    public View getView() {
        return textView;
    }

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        Log.e("xlog", "#NativeView#onFlutterViewAttached, " + flutterView);
    }

    @Override
    public void onFlutterViewDetached() {
        Log.e("xlog", "#NativeView#onFlutterViewDetached");
    }

    @Override
    public void dispose() {
        Log.e("xlog", "#NativeView#dispose~~");
    }
}
