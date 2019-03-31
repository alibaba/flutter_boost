package com.taobao.idlefish.flutterboostexample;

import com.taobao.idlefish.flutterboost.containers.BoostFlutterActivity;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class FlutterPageActivity extends BoostFlutterActivity {

    @Override
    public void onRegisterPlugins(PluginRegistry registry) {
        GeneratedPluginRegistrant.registerWith(registry);
    }

    /**
     * 该方法返回当前Activity在Flutter层对应的name，
     * 混合栈将会在flutter层根据这个名字，在注册的Route表中查找对应的Widget
     *
     * 在flutter层有注册函数：
     *     FlutterBoost.singleton.registerPageBuilders({
     *       'first': (pageName, params, _) => FirstRouteWidget(),
     *       'second': (pageName, params, _) => SecondRouteWidget(),
     *       ...
     *     });
     *
     * 该方法中返回的就是注册的key：first , second
     *
     * @return
     */
    @Override
    public String getContainerName() {
        return "flutterPage";
    }

    /**
     * 该方法返回的参数将会传递给上层的flutter对应的Widget
     *
     * 在flutter层有注册函数：
     *    FlutterBoost.singleton.registerPageBuilders({
     *       'first': (pageName, params, _) => FirstRouteWidget(),
     *       'second': (pageName, params, _) => SecondRouteWidget(),
     *        ...
     *     });
     *
     * 该方法返回的参数就会封装成上面的params
     *
     * @return
     */
    @Override
    public Map getContainerParams() {
        Map<String,String> params = new HashMap<>();
        params.put("aaa","bbb");
        return params;
    }
}
