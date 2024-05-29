package com.idlefish.flutterboost.example;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import java.util.HashMap;
import java.util.Map;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs;

import static com.idlefish.flutterboost.containers.FlutterActivityLaunchConfigs.ACTIVITY_RESULT_KEY;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    private final int REQUEST_CODE = 999;
    private TextView mOpenNative;
    private TextView mOpenFlutter;
    private TextView mOpenFlutterFragment;
    private TextView mOpenFlutterPlatformViewFragment;
    private TextView mOpenCustomViewTab;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0){
            finish();
            return;
        }

        setContentView(R.layout.native_page);

        mOpenNative = findViewById(R.id.open_native);
        mOpenFlutter = findViewById(R.id.open_flutter);
        mOpenFlutterFragment = findViewById(R.id.open_flutter_fragment);
        mOpenFlutterPlatformViewFragment = findViewById(R.id.open_flutter_platformview_fragment);
        mOpenCustomViewTab = findViewById(R.id.open_custom_view_tab);

        mOpenNative.setOnClickListener(this);
        mOpenFlutter.setOnClickListener(this);
        mOpenFlutterFragment.setOnClickListener(this);
        mOpenFlutterPlatformViewFragment.setOnClickListener(this);
        mOpenCustomViewTab.setOnClickListener(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onClick(View v) {
        Map<String, Object> params = new HashMap<>();
        params.put("string","a string");
        params.put("bool", true);
        params.put("int", 666);
        //Add some params if needed.
        if (v == mOpenNative) {
            NativeRouter.openPageByUrl(this, NativeRouter.NATIVE_PAGE_URL , params);
        } else if (v == mOpenFlutter) {
            Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(FlutterBoostActivity.class)
                    .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
                    .destroyEngineWithActivity(false)
                    .url("flutterPage")
                    .urlParams(params)
                    .build(this);
            startActivityForResult(intent, REQUEST_CODE);
        } else if (v == mOpenFlutterFragment) {
            NativeRouter.openPageByUrl(this, NativeRouter.FLUTTER_FRAGMENT_PAGE_URL,params);
        } else if (v == mOpenFlutterPlatformViewFragment) {
            NativeRouter.openPageByUrl(this, NativeRouter.FLUTTER_PLATFORMVIEW_FRAGMENT_PAGE_URL,params);
        } else if (v == mOpenCustomViewTab) {
            NativeRouter.openPageByUrl(this, NativeRouter.FLUTTER_CUSTOM_VIEW_URL, params);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d("xlog", "#onActivityResult, requestCode=" + requestCode + ", resultCode=" + resultCode + ", data=" + (data != null ? data.getSerializableExtra(ACTIVITY_RESULT_KEY) : ""));
        if (data != null) {
            Toast.makeText(getApplicationContext(), "#onActivityResult:" + data.getSerializableExtra(ACTIVITY_RESULT_KEY) , Toast.LENGTH_SHORT).show();
        }
    }
}
