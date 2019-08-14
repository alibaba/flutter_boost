package com.taobao.idlefish.flutterboostexample;

import android.os.Build;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import io.flutter.plugin.platform.PlatformPlugin;

public class FlutterFragmentPageActivity extends AppCompatActivity {

    private FlutterFragment mFragment;

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
        if(actionBar != null) {
            actionBar.hide();
        }

        setContentView(R.layout.flutter_fragment_page);

        mFragment = FlutterFragment.instance("hello");

        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragment_stub,mFragment)
                .commit();
    }
}
