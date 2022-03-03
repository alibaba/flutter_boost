import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static Map<String, FlutterBoostRouteFactory> routerMap = {
    'initialRoute': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
        settings: settings,
        pageBuilder: (_, __, ___) {
          return Scaffold(
            body: Text('initialRoute text'),
          );
        },
      );
    },
    'mainPage': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) {
            final Map<String, Object> map = settings.arguments;
            final String dataString = map['data'];
            return Scaffold(
              body: Center(
                  child: Column(
                children: [
                  Text('mainPage text'),
                  Text(dataString ?? ''),
                ],
              )),
            );
          });
    },
    'secondPage': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) {
            final Map<String, Object> map = settings.arguments;
            final String dataString = map['data'];
            return Scaffold(
              body: Center(
                  child: Column(
                children: [
                  Text('secondPage text'),
                  Text(dataString ?? ''),
                ],
              )),
            );
          });
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
    return MaterialApp(home: home, debugShowCheckedModeBanner: false);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(
      routeFactory,
      appBuilder: appBuilder,
      initialRoute: "initialRoute",
    );
  }
}

void main() {
  /// push and pop with result test
  testWidgets('push and pop with result test', (tester) async {
    await tester.pumpWidget(
      MyApp(),
    );

    BoostNavigator.instance.push('mainPage');
    await tester.pumpAndSettle();

    expect(find.text('mainPage text'), findsOneWidget);

    BoostNavigator.instance.push('secondPage').then((value) {
      ///check pop result
      Map popResult = value as Map;
      expectSync(popResult['data'], 'resultString');
    });
    await tester.pumpAndSettle();

    BoostNavigator.instance.pop({'data': 'resultString'});
    await tester.pumpAndSettle();
    expect(find.text('mainPage text'), findsOneWidget);
    expect(find.text('secondPage text'), findsNothing);
  });
}
