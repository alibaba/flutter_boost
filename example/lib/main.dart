import 'package:flutter/material.dart';

import 'package:flutter_boost/flutter_boost_app.dart';
import 'package:flutter_boost_example/tab/friend.dart';
import 'package:flutter_boost_example/tab/message.dart';
import 'package:flutter_boost_example/simple_page_widgets.dart';
import 'package:flutter_boost_example/case/flutter_to_flutter_sample.dart';
import 'package:flutter_boost_example/case/image_pick.dart';
import 'package:flutter_boost_example/case/willpop.dart';
import 'package:flutter_boost_example/flutter_page.dart';
import 'package:flutter_boost_example/case/media_query.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Map<String, PageBuilder> routerMap = {};
  Map<String, BoostPageRouteBuilder> routerMap =
      <String, BoostPageRouteBuilder>{};

  @override
  void initState() {
    super.initState();

    routerMap = <String, BoostPageRouteBuilder>{
      '/': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, uniqueId) => Container()),
      'embedded': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, _) => EmbeddedFirstRouteWidget()),
      'imagepick': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, uniqueId) => ImagePickerPage(
                title: "xxx",uniqueId:uniqueId
              )),
      'firstFirst': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, _) => FirstFirstRouteWidget()),
      'willPop': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, _) => WillPopRouteWidget()),
      'secondStateful': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, _) => SecondStatefulRouteWidget()),
      'platformView': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, _) => PlatformRouteWidget()),

      ///可以在native层通过 getContainerParams 来传递参数
      'flutterPage': BoostPageRouteBuilder(widgetBuild: (pageName, params, uniqueId) {
        print("flutterPage params:$params");
        return FlutterRouteWidget(params: params,uniqueId:uniqueId);
      }),
      'tab_friend': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, _) => FriendWidget(params)),
      'tab_message': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, _) => MessageWidget(params)),
      'f2f_first': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, _) => F2FFirstPage()),
      'f2f_second': BoostPageRouteBuilder(
          widgetBuild: (pageName, params, _) => F2FSecondPage()),
      'mediaquery': BoostPageRouteBuilder(
          widgetBuild: (pageName, params,uniqueId) => MediaQueryRouteWidget(params: params,uniqueId:uniqueId)),

    };
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(routerMap);
  }

  static Widget appBuilder(Widget home) {
    return MaterialApp(
      home: home,
    );
  }

  void _onRoutePushed(
      String pageName, String uniqueId, Map params, Route route, Future _) {}
}

class BoostNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didPush' + route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didPop' + route.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didRemove' + route.settings.name);
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didStartUserGesture' + route.settings.name);
  }
}
