import 'package:flutter/material.dart';
import 'package:flutter_boost_example/case/platform_view.dart';
import 'package:flutter_boost/flutter_boost.dart';

class FirstRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FirstRouteWidgetState();
  }
}

class _FirstRouteWidgetState extends State<FirstRouteWidget> {
  _FirstRouteWidgetState();

  @override
  void initState() {
    debugPrint('initState');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    debugPrint('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FirstRouteWidget oldWidget) {
    debugPrint('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    debugPrint('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('[XDEBUG] - FirstRouteWidget is disposing~');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Open native page'),
              onPressed: () {
                debugPrint("open native page!");
                BoostNavigator.instance.push("native");
              },
            ),
            ElevatedButton(
              child: const Text('Open FF route'),
              onPressed: () {
                debugPrint("open FF page!");
                BoostNavigator.instance.push("firstFirst");
              },
            ),
            ElevatedButton(
              child: const Text('Open second route1'),
              onPressed: () {
                debugPrint("open willPop page!22");
                BoostNavigator.instance.push("willPop", withContainer: true);
              },
            ),
            ElevatedButton(
              child: const Text('Present second stateful route'),
              onPressed: () {
                debugPrint("Present second stateful page!");
              },
            ),
            ElevatedButton(
              child: const Text('Present second route'),
              onPressed: () {
                debugPrint("Present second page!");
                // FlutterBoost.singleton.open("second",urlParams:<String,dynamic>{"present":true}).then((Map<dynamic,dynamic> value) {
                //   debugPrint(
                //       "call me when page is finished. did receive second route result $value");
                // });
              },
            ),
            ElevatedButton(
                child: const Text('Flutter to Flutter with Animation'),
                onPressed: () {
                  // FlutterBoost.singleton.open("f2f_first").then((Map<dynamic,dynamic> value) {
                  //   debugPrint(
                  //       "call me when page is finished. did receive second route result $value");
                  // });
                })
          ],
        ),
      ),
    );
  }
}

class FirstFirstRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FirstFirstRouteWidgetState();
  }
}

class _FirstFirstRouteWidgetState extends State<FirstFirstRouteWidget> {
  _FirstFirstRouteWidgetState();

  @override
  void initState() {
    debugPrint('initState');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    debugPrint('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FirstFirstRouteWidget oldWidget) {
    debugPrint('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    debugPrint('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('[XDEBUG] - FirstFirstRouteWidget is disposing~');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open first route'),
          onPressed: () {
            debugPrint("open first page again!");
            // FlutterBoost.singleton.open("first").then((Map value){
            //   debugPrint("did receive first route result");
            //   debugPrint("did receive first route result $value");
            // });
          },
        ),
      ),
    );
  }
}

class EmbeddedFirstRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EmbeddedFirstRouteWidgetState();
  }
}

class _EmbeddedFirstRouteWidgetState extends State<EmbeddedFirstRouteWidget> {
  @override
  Widget build(BuildContext context) {
    debugPrint('_EmbeddedFirstRouteWidgetState build called!');
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Open second route2'),
          onPressed: () {
            debugPrint("open second page!");
            // FlutterBoost.singleton.open("second").then((Map<dynamic,dynamic> value) {
            //   debugPrint(
            //       "call me when page is finished. did receive second route result $value");
            // });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('[XDEBUG]:_EmbeddedFirstRouteWidgetState disposing~');
    super.dispose();
  }
}

class SecondStatefulRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SecondStatefulRouteWidgetState();
  }
}

class _SecondStatefulRouteWidgetState extends State<SecondStatefulRouteWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SecondStateful Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.

            // BoostContainerSettings settings =
            //     BoostContainer.of(context).settings;
            // FlutterBoost.singleton.close(settings.uniqueId,
            //     result: <String,dynamic>{"result": "data from second"});

            // PageInfo pageInfo = BoostNavigator.instance.getTopPageInfo();
            BoostNavigator.instance.pop();
          },
          child: const Text('Go back with result!'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('[XDEBUG]:SecondStatefulRouteWidget disposing~');
    super.dispose();
  }
}

class TabRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tab Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // FlutterBoost.singleton.open("second");
          },
          child: const Text('Open second route3'),
        ),
      ),
    );
  }
}

class PlatformRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Platform Route"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const TextView(),
          onPressed: () {
            debugPrint("open second page!");
            // FlutterBoost.singleton.open("second").then((Map<dynamic,dynamic> value) {
            //   debugPrint(
            //       "call me when page is finished. did receive second route result $value");
            // });
          },
        ),
      ),
    );
  }
}
