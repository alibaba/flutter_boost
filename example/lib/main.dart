import 'package:flutter/material.dart';
//import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost/flutter_boost_app.dart';
import 'tab/friend.dart';
import 'tab/message.dart';

import 'simple_page_widgets.dart';
import 'flutter_to_flutter_sample.dart';
import 'image_pick.dart';
void main() {
  runApp(MyApp());
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
      'imagepick': (pageName, params, _) => ImagePickerPage(title: "xxx",),
      // 'first': (pageName, params, _) => FlutterRouteWidget(params: params),
      'firstFirst': (pageName, params, _) => FirstFirstRouteWidget(),
      'second': (pageName, params, _) => SecondRouteWidget(),
      'secondStateful': (pageName, params, _) => SecondStatefulRouteWidget(),
      'platformView': (pageName, params, _) => PlatformRouteWidget(),
      ///可以在native层通过 getContainerParams 来传递参数
      'flutterPage': (pageName, params, _) {
        print("flutterPage params:$params");

        return FlutterRouteWidget(params: params);
      },
      'tab_friend': (pageName, params, _) => FriendWidget(params),
      'tab_message': (pageName, params, _) => MessageWidget(params),
      'f2f_first': (pageName, params, _) => F2FFirstPage(),
      'f2f_second': (pageName, params, _) => F2FSecondPage(),
    };


  }

  @override
  Widget build(BuildContext context) {

    return FlutterBoostApp(routerMap,appBuilder:appBuilder);
  }
  static Widget appBuilder(Widget home) {
    return MaterialApp(home: home,);
  }



  void _onRoutePushed(
      String pageName, String uniqueId, Map params, Route route, Future _) {}
}

class BoostNavigatorObserver extends NavigatorObserver{
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didPush'+route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didPop'+route.settings.name);
  }


  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didRemove'+route.settings.name);
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didStartUserGesture'+route.settings.name);


  }

}