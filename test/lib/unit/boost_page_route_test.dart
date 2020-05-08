import 'package:flutter_boost/container/boost_page_route.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('test iOS edge swipe then drop back at starting point works',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        onGenerateRoute: (RouteSettings settings) {
          return BoostPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) {
              final String pageNumber = settings.name == '/' ? '1' : '2';
              return Center(child: Text('Page $pageNumber'));
            },
          );
        },
      ),
    );

    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/next');

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Page 1'), findsNothing);
    expect(find.text('Page 2'), isOnstage);

    final TestGesture gesture = await tester.startGesture(const Offset(5, 200));
    await gesture.moveBy(const Offset(300, 0));
    await tester.pump();
    // Bring it exactly back such that there's nothing to animate when releasing.
    await gesture.moveBy(const Offset(-300, 0));
    await gesture.up();
    await tester.pump();

    expect(find.text('Page 1'), findsNothing);
    expect(find.text('Page 2'), isOnstage);
  });

  group('Try to get the BoostPageRoute in the ancestor node', () {
    testWidgets(
        'obtain BoostPageRoute through the BoostPageRoute.of(context) method',
        (WidgetTester tester) async {
      BoostPageRoute<dynamic> boostPageRoute;
      BoostPageRoute<dynamic> boostPageRouteFindByOfMethod;

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (RouteSettings settings) {
            boostPageRoute = BoostPageRoute<void>(
              settings: settings,
              builder: (BuildContext context) => Builder(
                builder: (BuildContext context) {
                  return FloatingActionButton(
                    onPressed: () {
                      boostPageRouteFindByOfMethod =
                          BoostPageRoute.of<dynamic>(context);
                    },
                  );
                },
              ),
            );
            return boostPageRoute;
          },
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));

      await tester.pump(const Duration(seconds: 1));

      // The route obtained from the ancestor node through the `of` method should be the same BoostPageRoute
      // as the originally created BoostPageRoute
      expect(boostPageRoute, boostPageRouteFindByOfMethod);
    });

    testWidgets(
        'try to find BoostPageRoute through the BoostPageRoute.of(context) method, '
        'but it doesn\'t exist, the method should throw an Exception',
        (WidgetTester tester) async {
      BuildContext contextCache;

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (BuildContext context) => Builder(
                builder: (BuildContext context) => FloatingActionButton(
                  onPressed: () {
                    contextCache = context;
                  },
                ),
              ),
            );
          },
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(const Duration(seconds: 1));

      expect(() => BoostPageRoute.of<dynamic>(contextCache), throwsException);
    });

    testWidgets(
        'obtain BoostPageRoute through the BoostPageRoute.tryOf(context) method',
        (WidgetTester tester) async {
      BoostPageRoute<dynamic> boostPageRoute;
      BoostPageRoute<dynamic> boostPageRouteFindByOfMethod;

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (RouteSettings settings) {
            boostPageRoute = BoostPageRoute<void>(
              settings: settings,
              builder: (BuildContext context) => Builder(
                builder: (BuildContext context) {
                  return FloatingActionButton(
                    onPressed: () {
                      boostPageRouteFindByOfMethod =
                          BoostPageRoute.tryOf<dynamic>(context);
                    },
                  );
                },
              ),
            );
            return boostPageRoute;
          },
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(const Duration(seconds: 1));

      // The route obtained from the ancestor node through the `tryOf` method should be the same BoostPageRoute
      // as the originally created BoostPageRoute
      expect(boostPageRoute, boostPageRouteFindByOfMethod);
    });
  });

  testWidgets(
      'try to find BoostPageRoute through the BoostPageRoute.tryOf(context) method, '
      'but it doesn\'t exist, the method should return null',
      (WidgetTester tester) async {
    BoostPageRoute<dynamic> boostPageRouteFindByOfMethod;

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute<dynamic>(
            settings: settings,
            builder: (BuildContext context) => Builder(
              builder: (BuildContext context) {
                return FloatingActionButton(
                  onPressed: () {
                    boostPageRouteFindByOfMethod =
                        BoostPageRoute.tryOf<dynamic>(context);
                  },
                );
              },
            ),
          );
        },
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(seconds: 1));

    expect(boostPageRouteFindByOfMethod, null);
  });
}
