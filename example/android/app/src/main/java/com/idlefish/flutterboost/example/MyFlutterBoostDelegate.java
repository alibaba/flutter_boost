package com.idlefish.flutterboost.example;

import android.content.Intent;
import android.widget.Toast;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostDelegate;
import com.idlefish.flutterboost.FlutterBoostRouteOptions;
import com.idlefish.flutterboost.containers.FlutterBoostActivity;

import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;

public class MyFlutterBoostDelegate implements FlutterBoostDelegate {

    @Override
    public void pushNativeRoute(FlutterBoostRouteOptions options) {
        Intent intent = new Intent(FlutterBoost.instance().currentActivity(), NativePageActivity.class);
        FlutterBoost.instance().currentActivity().startActivityForResult(intent, options.requestCode());
    }

    @Override
    public void pushFlutterRoute(FlutterBoostRouteOptions options) {
        Class<? extends FlutterBoostActivity> activityClass = options.opaque() ? FlutterBoostActivity.class : TransparencyPageActivity.class;
        Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(activityClass)
                .destroyEngineWithActivity(false)
                // 注意：这里需要回传dart带过来的uniqueId，否则页面退出时传参可能失败。
                // 但，如果是从Native打开Flutter页面，请不要给uniqueId赋*任何值*！！！
                .uniqueId(options.uniqueId())
                .backgroundMode(options.opaque() ? BackgroundMode.opaque : BackgroundMode.transparent)
                .url(options.pageName())
                .urlParams(options.arguments())
                .build(FlutterBoost.instance().currentActivity());
        FlutterBoost.instance().currentActivity().startActivity(intent);
    }

    @Override
    public boolean popRoute(FlutterBoostRouteOptions options) {
        //自定义popRoute处理逻辑,如果不想走默认处理逻辑返回true进行拦截
        Toast.makeText(FlutterBoost.instance().currentActivity().getApplicationContext(), "自定义popRoute处理逻辑", Toast.LENGTH_SHORT).show();
        return false;
    }
}
