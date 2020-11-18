package com.taobao.idlefish.flutterboostexample;

import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import android.view.View;
import android.widget.TextView;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    public static WeakReference<MainActivity> sRef;

    private TextView mOpenNative;
    private TextView mOpenFlutter;
    private TextView mOpenFlutterFragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        sRef = new WeakReference<>(this);

        setContentView(R.layout.native_page);

        mOpenNative = findViewById(R.id.open_native);
        mOpenFlutter = findViewById(R.id.open_flutter);
        mOpenFlutterFragment = findViewById(R.id.open_flutter_fragment);

        mOpenNative.setOnClickListener(this);
        mOpenFlutter.setOnClickListener(this);
        mOpenFlutterFragment.setOnClickListener(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        sRef.clear();
        sRef = null;
    }

    @Override
    public void onClick(View v) {
        Map params = new HashMap();
        params.put("test1","v_test1");
        params.put("test2","v_test2");
        //Add some params if needed.
        if (v == mOpenNative) {
            PageRouter.openPageByUrl(this, PageRouter.NATIVE_PAGE_URL , params);
        } else if (v == mOpenFlutter) {
            PageRouter.openPageByUrl(this, PageRouter.FLUTTER_PAGE_URL,params);
        } else if (v == mOpenFlutterFragment) {
            PageRouter.openPageByUrl(this, PageRouter.FLUTTER_FRAGMENT_PAGE_URL,params);
        }
    }
}
