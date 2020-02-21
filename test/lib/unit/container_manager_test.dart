import 'package:flutter_boost/container/container_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_boost/flutter_boost.dart';

final GlobalKey scaffoldKey = GlobalKey();

class FirstRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('First'),
              onPressed: () {
                print("open second page!");
                FlutterBoost.singleton.open("second").then((Map value) {
                  print(
                      "call me when page is finished. did recieve second route result $value");
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SecondRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Route'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Second'),
              onPressed: () {
                print("open second page!");
                FlutterBoost.singleton.open("second").then((Map value) {
                  print(
                      "call me when page is finished. did recieve second route result $value");
                });
              },
            ),
          ],
        ),
      ),
    );
  }
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
      'first': (pageName, params, _) => FirstRouteWidget(),
      'second': (pageName, params, _) => SecondRouteWidget(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Boost example',
        key: scaffoldKey,
        builder: (BuildContext context, Widget child) {
          assert(child is Navigator, 'child must be Navigator, what is wrong?');

          final BoostContainerManager manager = BoostContainerManager(
            initNavigator: child,
          );

          return manager;
        },
        home: Container());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('test iOS edge swipe then drop back at starting point works',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('First'), findsNothing);
  });

  group(
    'Try to get the ContainerManagerState in the ancestor node',
    () {
      testWidgets(
        'through the `BoostContainerManager.of(context)` method',
        (WidgetTester tester) async {
          var findBoostContainerManagerByOfMethod;

          await tester.pumpWidget(
            MaterialApp(
              builder: (BuildContext context, Widget child) {
                final BoostContainerManager manager = BoostContainerManager(
                  initNavigator: child,
                );

                return manager;
              },
              home: Builder(
                builder: (BuildContext context) {
                  return FloatingActionButton(onPressed: () {
                    findBoostContainerManagerByOfMethod = context;
                  });
                },
              ),
            ),
          );

          await tester.tap(find.byType(FloatingActionButton));

          expect(
            BoostContainerManager.of(findBoostContainerManagerByOfMethod),
            const TypeMatcher<ContainerManagerState>(),
          );
        },
      );

      testWidgets(
        'through the `BoostContainerManager.tryOf(context)` method',
        (WidgetTester tester) async {
          var findBoostContainerManagerByOfMethod;

          await tester.pumpWidget(
            MaterialApp(
              builder: (BuildContext context, Widget child) {
                final BoostContainerManager manager = BoostContainerManager(
                  initNavigator: child,
                );

                return manager;
              },
              home: Builder(
                builder: (BuildContext context) {
                  return FloatingActionButton(onPressed: () {
                    findBoostContainerManagerByOfMethod = context;
                  });
                },
              ),
            ),
          );

          await tester.tap(find.byType(FloatingActionButton));

          expect(
            BoostContainerManager.tryOf(findBoostContainerManagerByOfMethod),
            const TypeMatcher<ContainerManagerState>(),
          );
        },
      );
    },
  );
}
