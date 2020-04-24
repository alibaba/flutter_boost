import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost/container/container_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'page_widgets.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FlutterBoost.singleton.registerPageBuilders(<String, PageBuilder>{
      'embeded': (String pageName, Map<String, dynamic> params, _) =>
          EmbededFirstRouteWidget(),
      'first': (String pageName, Map<String, dynamic> params, _) =>
          FirstRouteWidget(),
      'second': (String pageName, Map<String, dynamic> params, _) =>
          SecondRouteWidget(),
      'tab': (String pageName, Map<String, dynamic> params, _) =>
          TabRouteWidget(),
      'flutterFragment': (String pageName, Map<String, dynamic> params, _) =>
          FragmentRouteWidget(params),
      'flutterPage': (String pageName, Map<String, dynamic> params, _) {
        print('flutterPage params:$params');

        return FlutterRouteWidget(params: params);
      },
    });
    FlutterBoost.singleton
        .addBoostNavigatorObserver(TestBoostNavigatorObserver());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Boost example',
        builder: FlutterBoost.init(postPush: _onRoutePushed),
        home: Container());
  }

  void _onRoutePushed(
    String pageName,
    String uniqueId,
    Map<String, dynamic> params,
    Route<dynamic> route,
    Future<dynamic> _,
  ) {}
}

class TestBoostNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('flutterboost#didPush');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('flutterboost#didPop');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('flutterboost#didRemove');
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    print('flutterboost#didReplace');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('test iOS edge swipe then drop back at starting point works',
      (WidgetTester tester) async {
    //push app
    await tester.pumpWidget(
      MyApp(),
    );
    //open firt page
    ContainerCoordinator.singleton
        .nativeContainerDidShow('first', <String, dynamic>{}, '1000000');

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('First'), findsOneWidget);

    //open second page  firt(1000000)->second(2000000)
    ContainerCoordinator.singleton
        .nativeContainerDidShow('second', <String, dynamic>{}, '2000000');

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Second'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    //close sencod page  firt(1000000)
    FlutterBoost.containerManager?.remove('2000000');

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('First'), findsOneWidget);

    // second page ,but pageId is 2000001    firt(1000000)->second(2000001)
    ContainerCoordinator.singleton
        .nativeContainerDidShow('second', <String, dynamic>{}, '2000001');

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Second'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    //reopen firt page   second(2000001)->firt(1000000)
    ContainerCoordinator.singleton
        .nativeContainerDidShow('first', <String, dynamic>{}, '1000000');

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('First'), findsOneWidget);

    //reopen firt page   second(2000001)->firt(1000000)

    // reopen second page and  pageId is 2000001    firt(1000000)->second(2000001)
    ContainerCoordinator.singleton
        .nativeContainerDidShow('second', <String, dynamic>{}, '2000001');

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Second'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    //close firt(1000000) page  second(2000001)
    FlutterBoost.containerManager?.remove('1000000');

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Second'), findsOneWidget);

    // open  second(2000003)
    ContainerCoordinator.singleton
        .nativeContainerDidShow('second', <String, dynamic>{}, '2000003');

    await tester.idle();

    expect(find.text('Second'), findsOneWidget);
  });
}
