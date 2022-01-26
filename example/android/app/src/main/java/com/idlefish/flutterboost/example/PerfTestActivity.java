package com.idlefish.flutterboost.example;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import com.idlefish.flutterboost.containers.FlutterBoostActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;

public class PerfTestActivity extends FlutterBoostActivity {
    private static final String TAG = "PerfTestActivity";
    private String url = "platformview/listview";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Intent intent = getIntent();
        Uri uri = intent.getData();
        if(uri != null) {
           url = uri.getHost() + uri.getPath();
           Log.e(TAG, "Test Page: " + url);
       }
        super.onCreate(savedInstanceState);
    }

    @Override
    public String getUrl() {
        return url;
    }
}
