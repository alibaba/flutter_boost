package com.idlefish.flutterboost.example;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostSetupOptions;

import java.util.ArrayList;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        ArrayList<String> args = new ArrayList<>();
        args.add("--trace-systrace");
        args.add("--user-authorization-code=QZvoUptODA+KDgeFUluhheYns7X7CnDu9YRv8YmU0GXQcKLzs4C2WgjblrAIhtkqqGg==");
        FlutterBoostSetupOptions options = new FlutterBoostSetupOptions.Builder().shellArgs(args.toArray(new String[0])).build();
        FlutterBoost.instance().setup(this, new MyFlutterBoostDelegate(), engine->{
            // Register the platform view
            engine.getPlatformViewsController().getRegistry().registerViewFactory("<simple-text-view>", new TextViewFactory());
            engine.getPlatformViewsController().getRegistry().registerViewFactory("<runball-surface>", new RunBallViewFactory());
            engine.getPlatformViewsController().getRegistry().registerViewFactory("<color-rectangle>", new GlSurfaceFactory());
            engine.getPlugins();
        }, options);
    }
}

