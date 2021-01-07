package com.idlefish.flutterboost.example;

import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import android.view.View;
import android.widget.TextView;

import com.idlefish.flutterboost.BoostNavigator;
import com.idlefish.flutterboost.FlutterRouterApi;

import java.util.HashMap;
import java.util.Map;

public class NativePageActivity extends AppCompatActivity implements View.OnClickListener {

    private TextView mOpenNative;
    private TextView mOpenFlutter;
    private TextView mOpenFlutterFragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.native_page);

        mOpenNative = findViewById(R.id.open_native);
        mOpenFlutter = findViewById(R.id.open_flutter);
//        mOpenFlutterFragment = findViewById(R.id.open_flutter_fragment);

        mOpenNative.setOnClickListener(this);
        mOpenFlutter.setOnClickListener(this);
//        mOpenFlutterFragment.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        Map params = new HashMap();
        params.put("test1","v_test1");
        params.put("test2","v_test2");

        if (v == mOpenNative) {
            NativeRouter.openPageByUrl(this, NativeRouter.NATIVE_PAGE_URL,params);
        } else if (v == mOpenFlutter) {
            BoostNavigator.pushRoute("flutterPage",null);
        } else if (v == mOpenFlutterFragment) {
            NativeRouter.openPageByUrl(this, NativeRouter.FLUTTER_FRAGMENT_PAGE_URL,params);
        }
    }
}