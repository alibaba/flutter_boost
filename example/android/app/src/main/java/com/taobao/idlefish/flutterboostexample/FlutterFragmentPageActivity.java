package com.taobao.idlefish.flutterboostexample;

import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import io.flutter.plugin.platform.PlatformPlugin;

public class FlutterFragmentPageActivity extends AppCompatActivity implements View.OnClickListener {

    private FlutterFragment mFragment;

    private View mTab1;
    private View mTab2;
    private View mTab3;
    private View mTab4;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(0x40000000);
            window.getDecorView().setSystemUiVisibility(PlatformPlugin.DEFAULT_SYSTEM_UI);
        }
        super.onCreate(savedInstanceState);

        final ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.hide();
        }

        setContentView(R.layout.flutter_fragment_page);

        mTab1 = findViewById(R.id.tab1);
        mTab2 = findViewById(R.id.tab2);
        mTab3 = findViewById(R.id.tab3);
        mTab4 = findViewById(R.id.tab4);

        mTab1.setOnClickListener(this);
        mTab2.setOnClickListener(this);
        mTab3.setOnClickListener(this);
        mTab4.setOnClickListener(this);

    }

    @Override
    public void onClick(View v) {

        mTab1.setBackgroundColor(Color.WHITE);
        mTab2.setBackgroundColor(Color.WHITE);
        mTab3.setBackgroundColor(Color.WHITE);
        mTab4.setBackgroundColor(Color.WHITE);

        if (mTab1 == v) {
            mTab1.setBackgroundColor(Color.YELLOW);
            mFragment = FlutterFragment.instance("tab1");
        } else if (mTab2 == v) {
            mTab2.setBackgroundColor(Color.YELLOW);
            mFragment = FlutterFragment.instance("tab2");
        } else if (mTab3 == v) {
            mTab3.setBackgroundColor(Color.YELLOW);
            mFragment = FlutterFragment.instance("tab3");
        } else {
            mTab4.setBackgroundColor(Color.YELLOW);
            mFragment = FlutterFragment.instance("tab4");
        }

        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragment_stub, mFragment)
                .commit();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mTab1.performClick();
    }
}
