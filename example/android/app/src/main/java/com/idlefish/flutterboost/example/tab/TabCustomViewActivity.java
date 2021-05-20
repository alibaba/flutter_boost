package com.idlefish.flutterboost.example.tab;

import android.os.Bundle;
import android.util.SparseArray;
import android.view.MenuItem;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.containers.FlutterBoostView;
import com.idlefish.flutterboost.example.R;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.android.TransparencyMode;

public class TabCustomViewActivity extends AppCompatActivity implements BottomNavigationView.OnNavigationItemSelectedListener, FlutterBoostView.Callback {
    SparseArray<FlutterBoostView> mTabs = new SparseArray<>();
    TabView mTabView;
    private int lastId = -1;

    private  FlutterBoostView createFlutterBoostView(String url) {
        Map<String, Object> params = new HashMap<>();
        params.put("url", url);
        // #1. create FlutterBoostView
        return FlutterBoostView.withCachedEngine()
                .transparencyMode(TransparencyMode.transparent)
                .renderMode(RenderMode.texture)
                .url(url)
                .urlParams(params)
                .build(this, this);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tab_custom_view);

        BottomNavigationView bottomNavigation = findViewById(R.id.navigation);
        bottomNavigation.setOnNavigationItemSelectedListener(this);

        FrameLayout container = findViewById(R.id.container);

        mTabs.put(R.id.navigation_flutter1, createFlutterBoostView("tab_flutter1"));
        mTabs.put(R.id.navigation_flutter2, createFlutterBoostView("tab_flutter2"));
        mTabView = new TabView(this);

        container.addView(mTabView, -1, -1);
        mTabView.setVisibility(View.INVISIBLE);

        for (int i = 0; i < mTabs.size(); i++) {
            FlutterBoostView tabContainer = mTabs.valueAt(i);
            container.addView(tabContainer, -1, -1);
        }

        lastId = R.id.navigation_flutter1;
        bottomNavigation.setSelectedItemId(lastId);
    }

    // #2. override these onResume/onPause/onStop lifecycle callbacks
    @Override
    protected void onStop() {
        super.onStop();
        if (lastId != R.id.navigation_native) {
            mTabs.get(lastId).onStop();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (lastId != R.id.navigation_native) {
            mTabs.get(lastId).onPause();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (lastId != R.id.navigation_native) {
            mTabs.get(lastId).onResume();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        for (int i = 0; i < mTabs.size(); i++) {
            FlutterBoostView tabContainer = mTabs.valueAt(i);
            tabContainer.onDestroy();
        }
        mTabView.onDestroy();
    }

    // #3. handle view visibility via setVisibility
    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        switch (id) {
            case R.id.navigation_flutter1:
            case R.id.navigation_flutter2: {
                if (lastId == R.id.navigation_native) {
                    mTabView.setVisibility(View.GONE);
                } else {
                    mTabs.get(lastId).setVisibility(View.GONE);
                }

                FlutterBoostView selectedTab = mTabs.get(id);
                selectedTab.setVisibility(View.VISIBLE);
                break;
            }
            case R.id.navigation_native:{
                mTabView.setVisibility(View.VISIBLE);
                if (lastId != R.id.navigation_native) {
                    mTabs.get(lastId).setVisibility(View.GONE);
                }
                break;
            }
        }
        lastId = id;
        return true;
    }

    // #4. handle back event
    @Override
    public void onBackPressed() {
        if (lastId == R.id.navigation_native) {
            finish();
        } else {
            FlutterBoostView currentTab = mTabs.get(lastId);
            currentTab.onBackPressed();
        }
    }

    // #5. handle view close event and other callback
    @Override
    public void finishContainer(Map<String, Object> result) {
        finish();
    }

    @Override
    public void onFlutterUiDisplayed() {
        // Todo:
    }

    @Override
    public void onFlutterUiNoLongerDisplayed() {
        // Todo:
    }
}
