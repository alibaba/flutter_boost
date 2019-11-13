package com.idlefish.flutterboost.interfaces;

import android.content.Context;

import java.util.Map;

public interface INativeRouter {

    void openContainer(Context context, String url, Map<String,Object> urlParams, int requestCode, Map<String,Object> exts);


}
