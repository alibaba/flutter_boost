import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

import 'pages/dialog_page.dart';
import 'pages/lifecycle_test_page.dart';
import 'pages/main_page.dart';
import 'pages/replacement_page.dart';
import 'pages/simple_page.dart';

void main() {
  ///添加全局生命周期监听类
  PageVisibilityBinding.instance.addGlobalObserver(AppLifecycleObserver());

  ///这里的CustomFlutterBinding调用务必不可缺少，用于控制Boost状态的resume和pause
  CustomFlutterBinding();
  runApp(const MyApp());
}

///创建一个自定义的Binding，继承和with的关系如下，里面什么都不用写
class CustomFlutterBinding extends WidgetsFlutterBinding
    with BoostFlutterBinding {}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 由于很多同学说没有跳转动画，这里是因为之前exmaple里面用的是 [PageRouteBuilder]，
  /// 其实这里是可以自定义的，和Boost没太多关系，比如我想用类似iOS平台的动画，
  /// 那么只需要像下面这样写成 [CupertinoPageRoute] 即可
  /// (这里全写成[MaterialPageRoute]也行，这里只不过用[CupertinoPageRoute]举例子)
  ///
  /// 注意，如果需要push的时候，两个页面都需要动的话，
  /// （就是像iOS native那样，在push的时候，前面一个页面也会向左推一段距离）
  /// 那么前后两个页面都必须是遵循CupertinoRouteTransitionMixin的路由
  /// 简单来说，就两个页面都是CupertinoPageRoute就好
  /// 如果用MaterialPageRoute的话同理

  static Map<String, FlutterBoostRouteFactory> routerMap = {
    'mainPage': (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings,
          builder: (_) {
            Map<String, Object> map = settings.arguments ?? {};
            String data = map['data'] ?? '';
            return MainPage(
              data: data,
            );
          });
    },

    'simplePage': (settings, uniqueId) {
      Map<String, Object> map = settings.arguments ?? {};
      String data = map['data'] ?? '';
      return CupertinoPageRoute(
        settings: settings,
        builder: (_) => SimplePage(
          data: data,
        ),
      );
    },
    'tab1': (settings, uniqueId) {
      return CupertinoPageRoute(
        settings: settings,
        builder: (_) => const TabPage(
          color: Colors.blue,
          title: 'Tab1',
        ),
      );
    },
    'tab2': (settings, uniqueId) {
      return CupertinoPageRoute(
        settings: settings,
        builder: (_) => const TabPage(
          color: Colors.red,
          title: 'Tab2',
        ),
      );
    },
    'tab3': (settings, uniqueId) {
      return CupertinoPageRoute(
        settings: settings,
        builder: (_) => const TabPage(
          color: Colors.orange,
          title: 'Tab3',
        ),
      );
    },

    ///生命周期例子页面
    'lifecyclePage': (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings,
          builder: (ctx) {
            return const LifecycleTestPage();
          });
    },
    'replacementPage': (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings,
          builder: (ctx) {
            return const ReplacementPage();
          });
    },

    ///透明弹窗页面
    'dialogPage': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(

          ///透明弹窗页面这个需要是false
          opaque: false,

          ///背景蒙版颜色
          barrierColor: Colors.black12,
          settings: settings,
          pageBuilder: (_, __, ___) => const DialogPage());
    },
  };

  Route<dynamic> routeFactory(RouteSettings settings, String uniqueId) {
    FlutterBoostRouteFactory func = routerMap[settings.name];
    if (func == null) {
      return null;
    }
    return func(settings, uniqueId);
  }

  Widget appBuilder(Widget home) {
    return MaterialApp(
      home: home,
      debugShowCheckedModeBanner: true,

      ///必须加上builder参数，否则showDialog等会出问题
      builder: (_, __) {
        return home;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(
      routeFactory,
      appBuilder: appBuilder,
    );
  }
}

class TabPage extends StatelessWidget {
  final String title;
  final Color color;
  const TabPage({Key key, this.title, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: Center(
        child: Text(title ?? '', style: const TextStyle(fontSize: 25)),
      ),
    );
  }
}
