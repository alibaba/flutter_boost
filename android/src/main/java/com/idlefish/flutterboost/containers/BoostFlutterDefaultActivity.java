package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import java.util.HashMap;
import java.util.Map;

public class BoostFlutterDefaultActivity extends BoostFlutterActivity {

    @Override
    public String getContainerUrl() {
        return getIntent().getStringExtra("url");
    }

    @Override
    public Map getContainerUrlParams() {
        return (Map)(getIntent().getSerializableExtra("params"));
    }

    private static Intent intent(Context context, String url, HashMap<String, Object> params) {
        final Intent intent = new Intent(context, BoostFlutterDefaultActivity.class);
        intent.putExtra("url", url);
        intent.putExtra("params", params);
        return intent;
    }

    public static void open(Context context, String url, HashMap<String, Object> params) {
        context.startActivity(intent(context, url, params));
    }

    public static void open(Activity activity, String url, HashMap<String, Object> params, int requestCode) {
        activity.startActivityForResult(intent(activity, url, params), requestCode);
    }
}