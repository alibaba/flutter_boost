package com.idlefish.flutterboost.example;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;


import com.idlefish.flutterboost.example.tab.TabCustomViewActivity;
import com.idlefish.flutterboost.example.tab.TabMainActivity;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;

public class NativeRouter {

    public final static Map<String, String> pageName = new HashMap<String, String>() {{

        put("first", "first");
        put("second", "second");
        put("tab", "tab");
        put("f2f_first", "f2f_first");
        put("f2f_second", "f2f_second");
        put("sample://flutterPage", "flutterPage");
    }};

    public static final String NATIVE_PAGE_URL = "sample://nativePage";
    public static final String FLUTTER_PAGE_URL = "sample://flutterPage";
    public static final String FLUTTER_FRAGMENT_PAGE_URL = "sample://flutterFragmentPage";
    public static final String FLUTTER_CUSTOM_VIEW_URL = "sample://FlutterCustomView";

    public static boolean openPageByUrl(Context context, String url, Map params) {
        return openPageByUrl(context, url, params, 0);
    }

    public static boolean openPageByUrl(Context context, String url, Map params, int requestCode) {

        String path = url.split("\\?")[0];

        Log.i("openPageByUrl",path);

        try {
            if (pageName.containsKey(path)) {
                Intent intent =FlutterActivity.createDefaultIntent(context);
                if(context instanceof Activity){
                    Activity activity=(Activity)context;
                    activity.startActivityForResult(intent,requestCode);
                }else{
                    context.startActivity(intent);
                }
                return true;
            } else if (url.startsWith(FLUTTER_FRAGMENT_PAGE_URL)) {
                context.startActivity(new Intent(context, TabMainActivity.class));
                return true;
            } else if (url.startsWith(NATIVE_PAGE_URL)) {
                context.startActivity(new Intent(context, NativePageActivity.class));
                return true;
            } else if (url.startsWith(FLUTTER_CUSTOM_VIEW_URL)) {
                context.startActivity(new Intent(context, TabCustomViewActivity.class));
                return  true;
            }

            return false;

        } catch (Throwable t) {
            return false;
        }
    }
}
