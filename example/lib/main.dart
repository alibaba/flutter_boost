import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'simple_page_widgets.dart';
import 'flutter_to_flutter_sample.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FlutterBoost.singleton.registerPageBuilders({
      'embeded': (pageName, params, _)=>EmbededFirstRouteWidget(),
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

        return FlutterRouteWidget(params:params);
      },

      'f2f_first': (pageName, params, _) =>  F2FFirstPage(),
      'f2f_second': (pageName, params, _) => F2FSecondPage(),
    });
    FlutterBoost.singleton.addBoostNavigatorObserver(TestBoostNavigatorObserver());
    FlutterBoost.singleton.addContainerObserver((
        ContainerOperation operation, BoostContainerSettings settings){
      operation;
      settings;
    });

    FlutterBoostAPI.singleton.routeSettingsBuilder = (String url,
        {Map<String, dynamic> urlParams, Map<String, dynamic> exts}) => BoostRouteSettings(
      uniqueId: '${url}_${DateTime.now().millisecondsSinceEpoch}',
      name: url,
      params: urlParams,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Boost example',
        builder: FlutterBoost.init(postPush: _onRoutePushed),
        home: Container(
            color:Colors.white
        ));
  }

  void _onRoutePushed(
      String pageName, String uniqueId, Map params, Route route, Future _) {
  }
}

class TestBoostNavigatorObserver extends ContainerNavigatorObserver{
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    route.settings.name!="/";

    //1. 底下
    //新页面已经push完成
    print("flutterboost#didPush");
  }

  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    print("flutterboost#didPop");
  }

  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    print("flutterboost#didRemove");
  }

  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    print("flutterboost#didReplace");
  }
  void willPush(Route<dynamic> route, Route<dynamic> previousRoute) {

    print("flutterboost#willPush");
  }

}

