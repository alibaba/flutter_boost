import 'package:flutter/material.dart';
//import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost/flutter_boost_app.dart';

import 'simple_page_widgets.dart';
import 'flutter_to_flutter_sample.dart';

void main() {
  print("bbbb");
  runApp(MyApp());
  print("bbbb");
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, PageBuilder> routerMap={};
  @override
  void initState() {
    super.initState();

    routerMap=<String, PageBuilder>{
      '/': (pageName, params, _) => Container(),
      'embedded': (pageName, params, _) => EmbeddedFirstRouteWidget(),
      'first': (pageName, params, _) => FirstRouteWidget(),
      'firstFirst': (pageName, params, _) => FirstFirstRouteWidget(),
      'second': (pageName, params, _) => SecondRouteWidget(),
      'secondStateful': (pageName, params, _) => SecondStatefulRouteWidget(),
      'tab': (pageName, params, _) => TabRouteWidget(),
      'platformView': (pageName, params, _) => PlatformRouteWidget(),
      'flutterFragment': (pageName, params, _) => FragmentRouteWidget(params),

      ///可以在native层通过 getContainerParams 来传递参数
      'flutterPage': (pageName, params, _) {
        print("flutterPage params:$params");

        return FlutterRouteWidget(params: params);
      },

      'f2f_first': (pageName, params, _) => F2FFirstPage(),
      'f2f_second': (pageName, params, _) => F2FSecondPage(),
    };


  }

  @override
  Widget build(BuildContext context) {

    return FlutterBoostApp(routerMap);
  }

  void _onRoutePushed(
      String pageName, String uniqueId, Map params, Route route, Future _) {}
}

