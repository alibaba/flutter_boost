package com.taobao.idlefish.flutterboostexample;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import com.idlefish.flutterboost.containers.NewBoostFlutterActivity;

import java.util.HashMap;
import java.util.Map;

public class PageRouter {

    public static final String NATIVE_PAGE_URL = "sample://nativePage";
    public static final String FLUTTER_PAGE_URL = "sample://flutterPage";
    public static final String FLUTTER_FRAGMENT_PAGE_URL = "sample://flutterFragmentPage";

    public static boolean openPageByUrl(Context context, String url,Map params) {
        return openPageByUrl(context, url,params, 0);
    }

    public static boolean openPageByUrl(Context context, String url, Map params, int requestCode) {
        try {
            if (url.startsWith(FLUTTER_PAGE_URL)) {
                HashMap p=new HashMap();

                Intent intent= NewBoostFlutterActivity.withNewEngine().url("flutterPage").params(p)
                        .backgroundMode(NewBoostFlutterActivity.BackgroundMode.opaque).build(context);

                context.startActivity( intent);
                return true;
            } else if (url.startsWith(FLUTTER_FRAGMENT_PAGE_URL)) {
                context.startActivity(new Intent(context, FlutterFragmentPageActivity.class));
                return true;
            } else if (url.startsWith(NATIVE_PAGE_URL)) {
                context.startActivity(new Intent(context, NativePageActivity.class));
                return true;
            } else {
                return false;
            }
        } catch (Throwable t) {
            return false;
        }
    }
}
