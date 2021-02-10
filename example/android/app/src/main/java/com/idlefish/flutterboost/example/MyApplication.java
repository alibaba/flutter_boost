package com.idlefish.flutterboost.example;

import android.content.Intent;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostDelegate;
import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import java.util.HashMap;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs;

public class MyApplication extends FlutterApplication {


    @Override
    public void onCreate() {
        super.onCreate();

        FlutterBoost.instance().setup(this, new MyFlutterBoostDelegate(),engine->{
            engine.getPlugins();
        } );


    }
}

