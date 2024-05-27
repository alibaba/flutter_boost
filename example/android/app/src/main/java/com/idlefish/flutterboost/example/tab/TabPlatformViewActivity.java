package com.idlefish.flutterboost.example.tab;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.idlefish.flutterboost.containers.FlutterBoostFragment;
import com.idlefish.flutterboost.example.R;

import java.util.ArrayList;
import java.util.List;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

public class TabPlatformViewActivity extends FragmentActivity implements View.OnClickListener {
    private LinearLayout tab1;
    private LinearLayout tab2;

    private ImageView tab1Img;
    private ImageView tab2Img;

    private MsgFlutterFragment tab1Fragment;
    private FriendFlutterFragment tab2Fragment;

    private List<Fragment> fragmentList;
    Fragment currentFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tab_platformview_page);

        init();
        initClick();
        //默认选中第1个
        setSelect(0);
    }


    @Override
    public void onBackPressed() {
        if (currentFragment instanceof FlutterBoostFragment) {
            ((FlutterBoostFragment)currentFragment).onBackPressed();
        } else {
            finish();
        }
    }

    //初始化元素
    private void init() {
        tab1 = (LinearLayout) findViewById(R.id.platform1Tab);
        tab2 = (LinearLayout) findViewById(R.id.platform2Tab);

        tab1Img = (ImageView) findViewById(R.id.tab1_img);
        tab2Img = (ImageView) findViewById(R.id.tab2_img);


        fragmentList = new ArrayList<>();
        tab1Fragment = new MsgFlutterFragment
                .CachedEngineFragmentBuilder(MsgFlutterFragment.class)
                .url("platformview/listview")
                .build();

        tab2Fragment = new FriendFlutterFragment
                .CachedEngineFragmentBuilder(FriendFlutterFragment.class)
                .url("platformview/animation")
                .build();
    }

    //初始化监听
    private void initClick() {
        tab1.setOnClickListener(this);
        tab2.setOnClickListener(this);
    }

    private void showFragment(Fragment fragment) {
        FragmentManager fm = getSupportFragmentManager();
        if (currentFragment != fragment) {
            // 判断传入的fragment是不是当前的currentFragment
            FragmentTransaction transaction = fm.beginTransaction();
            if (currentFragment != null) {
                // 不是则隐藏
                transaction.hide(currentFragment);
            }
            // 然后将传入的fragment赋值给currentFragment
            currentFragment = fragment;

            // 判断传入的fragment是否已经被add()过
            if (!fragment.isAdded()) {
                transaction.add(R.id.fragment_stub, fragment).show(fragment).commit();
            } else {
                transaction.show(fragment).commit();
            }
        }
    }

    @Override
    public void onClick(View view) {
        resetImages();
        switch (view.getId()) {
            case R.id.platform1Tab:
                setSelect(0);
                break;
            case R.id.platform2Tab:
                setSelect(1);
                break;
        }

    }

    //全部图片设为暗色
    private void resetImages() {
        tab1Img.setImageResource(android.R.drawable.checkbox_off_background);
        tab2Img.setImageResource(android.R.drawable.checkbox_off_background);
    }

    //点亮选中图片
    private void setSelect(int i) {
        resetImages();
        switch (i) {
            case 0:
                tab1Img.setImageResource(android.R.drawable.checkbox_on_background);
                showFragment(tab1Fragment);
                break;
            case 1:
                tab2Img.setImageResource(android.R.drawable.checkbox_on_background);
                showFragment(tab2Fragment);
                break;
        }
    }
}