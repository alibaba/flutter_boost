package com.idlefish.flutterboost.interfaces;

import android.content.Intent;

import java.util.Map;

public interface IOperateSyncer {

    void onCreate();

    void onAppear();

    void onDisappear();

    void onDestroy();

    void onBackPressed();

    void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults);

    void onNewIntent(Intent intent);

    void onActivityResult(int requestCode, int resultCode, Intent data);

    void onContainerResult(int requestCode, int resultCode, Map<String,Object> result);

    void onUserLeaveHint();

    void onTrimMemory(int level);

    void onLowMemory();
}
