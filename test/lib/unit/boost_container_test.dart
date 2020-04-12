import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_boost/container/boost_container.dart';
import 'package:flutter_test/flutter_test.dart';

class FirstWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/second');
      },
      child: Container(
        color: const Color(0xFFFFFF00),
        child: const Text('X'),
      ),
    );
  }
}

class SecondWidget extends StatefulWidget {
  @override
  SecondWidgetState createState() => SecondWidgetState();
}

class SecondWidgetState extends State<SecondWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: const Color(0xFFFF00FF),
        child: const Text('Y'),
      ),
    );
  }
}

typedef ExceptionCallback = void Function(dynamic exception);

class ThirdWidget extends StatelessWidget {
  const ThirdWidget({this.targetKey, this.onException});

  final Key targetKey;
  final ExceptionCallback onException;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: targetKey,
      onTap: () {
        try {
          Navigator.of(context);
        } catch (e) {
          onException(e);
        }
      },
      behavior: HitTestBehavior.opaque,
    );
  }
}

class OnTapPage extends StatelessWidget {
  const OnTapPage({Key key, this.id, this.onTap}) : super(key: key);

  final String id;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page $id')),
      body: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          child: Center(
            child: Text(id, style: Theme.of(context).textTheme.display2),
          ),
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can navigator navigate to and from a stateful widget',
      (WidgetTester tester) async {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      '/': (BuildContext context) => FirstWidget(), // X
      '/second': (BuildContext context) => SecondWidget(), // Y
    };

    await tester.pumpWidget(MaterialApp(routes: routes));
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y', skipOffstage: false), findsNothing);

    await tester.tap(find.text('X'));
    await tester.pump();
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y', skipOffstage: false), isOffstage);

    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('X'), findsNothing);
    expect(find.text('X', skipOffstage: false), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);

    await tester.tap(find.text('Y'));
    expect(find.text('X'), findsNothing);
    expect(find.text('Y'), findsOneWidget);

    await tester.pump();
    await tester.pump();
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y', skipOffstage: false), findsNothing);
  });
//
  testWidgets('Navigator.of  gracefully when not found in context',
      (WidgetTester tester) async {
    const Key targetKey = Key('foo');
    dynamic exception;
    final Widget widget = ThirdWidget(
      targetKey: targetKey,
      onException: (dynamic e) {
        exception = e;
      },
    );
    await tester.pumpWidget(widget);

    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(targetKey));

    await tester.pump(const Duration(seconds: 1));

    expect(exception, isInstanceOf<FlutterError>());
    expect('$exception',
        startsWith('Navigator operation requested with a context'));
  });
//
//  testWidgets('Navigator.of rootNavigator finds root Navigator',
//      (WidgetTester tester) async {
//    await tester.pumpWidget(MaterialApp(
//      home: Material(
//        child: Column(
//          children: <Widget>[
//            const SizedBox(
//              height: 300.0,
//              child: Text('Root page'),
//            ),
//            SizedBox(
//              height: 300.0,
//              child: Navigator(
//                onGenerateRoute: (RouteSettings settings) {
//                  if (settings.isInitialRoute) {
//                    return MaterialPageRoute<void>(
//                      builder: (BuildContext context) {
//                        return RaisedButton(
//                          child: const Text('Next'),
//                          onPressed: () {
//                            BoostContainer.of(context).push(
//                              MaterialPageRoute<void>(
//                                  builder: (BuildContext context) {
//                                return RaisedButton(
//                                  child: const Text('Inner page'),
//                                  onPressed: () {
//                                    BoostContainer.of(context)
//                                        .push(
//                                      MaterialPageRoute<void>(
//                                          builder: (BuildContext context) {
//                                        return const Text('Dialog');
//                                      }),
//                                    );
//                                  },
//                                );
//                              }),
//                            );
//                          },
//                        );
//                      },
//                    );
//                  }
//                  return null;
//                },
//              ),
//            ),
//          ],
//        ),
//      ),
//    ));
////
////    await tester.tap(find.text('Next'));
////    await tester.pump();
////    await tester.pump(const Duration(milliseconds: 300));
//
//    // Both elements are on screen.
//    expect(find.text('Next'), findsOneWidget);
////    expect(tester.getTopLeft(find.text('Inner page')).dy, greaterThan(300.0));
////
////    await tester.tap(find.text('Inner page'));
////    await tester.pump();
////    await tester.pump(const Duration(milliseconds: 300));
////
////    // Dialog is pushed to the whole page and is at the top of the screen, not
////    // inside the inner page.
////    expect(tester.getTopLeft(find.text('Dialog')).dy, 0.0);
//  });
}
