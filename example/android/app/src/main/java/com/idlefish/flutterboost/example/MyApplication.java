package com.idlefish.flutterboost.example;

import com.idlefish.flutterboost.FlutterBoost;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        FlutterBoost.withDefaultEngine().setup(this, new MyFlutterBoostDelegate(),engine->{
            engine.getPlugins();
        });
    }
}

