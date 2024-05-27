package com.idlefish.flutterboost.example;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs;


public class NativePageActivity extends AppCompatActivity implements View.OnClickListener {

    private TextView mOpenNative;
    private TextView mOpenFlutter;
    private TextView mOpenFlutterFragment;

    private TextView mOpenFlutterPlatformViewFragment;

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.native_page);

        mOpenNative = findViewById(R.id.open_native);
        mOpenFlutter = findViewById(R.id.open_flutter);
        mOpenFlutterFragment = findViewById(R.id.open_flutter_fragment);
        mOpenFlutterPlatformViewFragment = findViewById(R.id.open_flutter_platformview_fragment);

        mOpenNative.setOnClickListener(this);
        mOpenFlutter.setOnClickListener(this);
        mOpenFlutterFragment.setOnClickListener(this);
        mOpenFlutterPlatformViewFragment.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        Map<String, Object> params = new HashMap<>();
        params.put("string","a string");
        params.put("bool", true);
        params.put("int", 666);

        if (v == mOpenNative) {
            NativeRouter.openPageByUrl(this, NativeRouter.NATIVE_PAGE_URL,params);
        } else if (v == mOpenFlutter) {
            Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(FlutterBoostActivity.class)
                    .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
                    .destroyEngineWithActivity(false)
                    .url("flutterPage")
                    .urlParams(params)
                    .build(this);
            startActivity(intent);
        } else if (v == mOpenFlutterFragment) {
            NativeRouter.openPageByUrl(this, NativeRouter.FLUTTER_FRAGMENT_PAGE_URL,params);
        } else if (v == mOpenFlutterPlatformViewFragment) {
            NativeRouter.openPageByUrl(this, NativeRouter.FLUTTER_PLATFORMVIEW_FRAGMENT_PAGE_URL,params);
        }
    }

    @Override
    public void finish() {
        Intent intent = new Intent();
        intent.putExtra("msg","This message is from NativePageActivity!!!");
        intent.putExtra("bool", true);
        intent.putExtra("int", 666);
        intent.putExtra("time", Calendar.getInstance().getTime().toString());
        setResult(Activity.RESULT_OK, intent);
        super.finish();
    }
}