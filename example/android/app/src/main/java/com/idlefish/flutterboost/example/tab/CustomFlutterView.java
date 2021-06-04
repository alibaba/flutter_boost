package com.idlefish.flutterboost.example.tab;

import androidx.activity.ComponentActivity;

import com.idlefish.flutterboost.containers.FlutterBoostViewBase;

import java.util.Map;

public class CustomFlutterView extends FlutterBoostViewBase {
    private String url;
    private Map<String, Object> params;
    public CustomFlutterView(ComponentActivity activity, String url, Map<String, Object> params) {
        super(activity);
        this.url = url;
        this.params = params;
    }

    @Override
    public String getUrl() {
        return url;
    }

    @Override
    public Map<String, Object> getUrlParams() {
        return params;
    }

    @Override
    public void finishContainer(Map<String, Object> result) {
        getContextActivity().finish();
    }
}
