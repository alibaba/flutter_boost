package com.idlefish.flutterboost.example;

import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

import com.idlefish.flutterboost.FlutterBoost;
import com.idlefish.flutterboost.FlutterBoostDelegate;
import com.idlefish.flutterboost.FlutterBoostRouteOptions;
import com.idlefish.flutterboost.containers.FlutterBoostActivity;
import com.idlefish.flutterboost.containers.FlutterViewContainer;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;
import io.flutter.embedding.android.FlutterFragment;

public class MyFlutterBoostDelegate implements FlutterBoostDelegate {

    private Context getCurrentContext() {
        FlutterViewContainer topContainer = FlutterBoost.instance().getTopContainer();
        Context context = null;
        if (topContainer != null) {
            context = topContainer.getContextActivity();
        }
        if (context == null) {
            context = FlutterBoost.instance().currentActivity();
        }
        return context;
    }

    private void startActivityForResult(Intent intent, int requestCode) {
        FlutterViewContainer topContainer = FlutterBoost.instance().getTopContainer();
        if (topContainer instanceof FlutterFragment) {
            //如果是从FlutterBoostFragment唤起的新页面，只有使用FlutterFragment进行start，才能收到result
            ((FlutterFragment) topContainer).startActivityForResult(intent, requestCode);
        } else if (topContainer instanceof FlutterActivity) {
            ((FlutterActivity) topContainer).startActivityForResult(intent, requestCode);
        } else {
            FlutterBoost.instance().currentActivity().startActivityForResult(intent,
                    requestCode);
        }
    }

    @Override
    public void pushNativeRoute(FlutterBoostRouteOptions options) {
        Context context = getCurrentContext();
        Intent intent = new Intent(context, NativePageActivity.class);
        startActivityForResult(intent, options.requestCode());
    }

    @Override
    public void pushFlutterRoute(FlutterBoostRouteOptions options) {
        Class<? extends FlutterBoostActivity> activityClass = options.opaque() ?
                FlutterBoostActivity.class : TransparencyPageActivity.class;
        Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(activityClass)
                .destroyEngineWithActivity(false)
                // 注意：这里需要回传dart带过来的uniqueId，否则页面退出时传参可能失败。
                // 但，如果是从Native打开Flutter页面，请不要给uniqueId赋*任何值*！！！
                .uniqueId(options.uniqueId())
                .backgroundMode(options.opaque() ? BackgroundMode.opaque :
                        BackgroundMode.transparent)
                .url(options.pageName())
                .urlParams(options.arguments())
                .build(getCurrentContext());
        startActivityForResult(intent, options.requestCode());
    }

    @Override
    public boolean popRoute(FlutterBoostRouteOptions options) {
        //自定义popRoute处理逻辑,如果不想走默认处理逻辑返回true进行拦截
        Toast.makeText(FlutterBoost.instance().currentActivity().getApplicationContext(), "Add " +
                "customized popRoute handler here", Toast.LENGTH_SHORT).show();
        return false;
    }
}
