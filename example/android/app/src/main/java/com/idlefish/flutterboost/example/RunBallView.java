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

class RunBallView implements PlatformView {
   private final RunBall view;

   RunBallView(@NonNull Context context) {
        view = new RunBall(context);
    }

    @NonNull
    @Override
    public View getView() {
        return view;
    }


    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        PlatformView.super.onFlutterViewAttached(flutterView);
        view.start();
    }

    @Override
    public void onFlutterViewDetached() {
        PlatformView.super.onFlutterViewDetached();
        view.stop();
    }

    @Override
    public void dispose() {
       view.dispose();
    }
}
