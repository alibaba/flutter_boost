import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost_example/case/platform_view.dart';
import 'package:flutter_boost/boost_navigator.dart';
import 'package:flutter_boost/logger.dart';

class FirstRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _FirstRouteWidgetState();
  }
}

class _FirstRouteWidgetState extends State<FirstRouteWidget> {
  _FirstRouteWidgetState();

  @override
  void initState() {
    print('initState');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    print('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FirstRouteWidget oldWidget) {
    print('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('[XDEBUG] - FirstRouteWidget is disposing~');
    super.dispose();
  }

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
              child: Text('Open native page'),
              onPressed: () {
                print("open native page!");
                BoostNavigator.of().push("native");

                // FlutterBoost.singleton.open("native").then((Map<dynamic,dynamic> value) {
                //   print(
                //       "call me when page is finished. did receive native route result $value");
                // });
              },
            ),
            RaisedButton(
              child: Text('Open FF route'),
              onPressed: () {
                print("open FF page!");
//
//                  FlutterBoost.singleton.open("firstFirst").then((Map value) {
//                    print(
//                        "call me when page is finished. did receive FF route result $value");
//                  });
                BoostNavigator.of().push("firstFirst");
              },
            ),
            RaisedButton(
              child: Text('Open second route1'),
              onPressed: () {
                print("open willPop page!22");
//                  FlutterBoost.singleton.open("second").then((Map<dynamic,dynamic> value) {
//                    print(
//                        "call me when page is finished. did receive second route result $value");
//                  });

                BoostNavigator.of().push("willPop", withContainer: true);
              },
            ),
            RaisedButton(
              child: Text('Present second stateful route'),
              onPressed: () {
                print("Present second stateful page!");
                // FlutterBoost.singleton.open("secondStateful",urlParams:<String,dynamic>{"present":true}).then((Map value) {
                //   print(
                //       "call me when page is finished. did receive second stateful route result $value");
                // });
              },
            ),
            RaisedButton(
              child: Text('Present second route'),
              onPressed: () {
                print("Present second page!");
                // FlutterBoost.singleton.open("second",urlParams:<String,dynamic>{"present":true}).then((Map<dynamic,dynamic> value) {
                //   print(
                //       "call me when page is finished. did receive second route result $value");
                // });
              },
            ),
            RaisedButton(
                child: Text('Flutter to Flutter with Animation'),
                onPressed: () {
                  // FlutterBoost.singleton.open("f2f_first").then((Map<dynamic,dynamic> value) {
                  //   print(
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
    return new _FirstFirstRouteWidgetState();
  }
}

class _FirstFirstRouteWidgetState extends State<FirstFirstRouteWidget> {
  _FirstFirstRouteWidgetState();

  @override
  void initState() {
    print('initState');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    print('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FirstFirstRouteWidget oldWidget) {
    print('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('[XDEBUG] - FirstFirstRouteWidget is disposing~');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Open first route'),
          onPressed: () {
            print("open first page again!");
            // FlutterBoost.singleton.open("first").then((Map value){
            //   print("did receive first route result");
            //   print("did receive first route result $value");
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
    print('_EmbeddedFirstRouteWidgetState build called!');
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text('Open second route2'),
          onPressed: () {
            print("open second page!");
            // FlutterBoost.singleton.open("second").then((Map<dynamic,dynamic> value) {
            //   print(
            //       "call me when page is finished. did receive second route result $value");
            // });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('[XDEBUG]:_EmbeddedFirstRouteWidgetState disposing~');
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
        title: Text("SecondStateful Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            // Navigate back to first route when tapped.

            // BoostContainerSettings settings =
            //     BoostContainer.of(context).settings;
            // FlutterBoost.singleton.close(settings.uniqueId,
            //     result: <String,dynamic>{"result": "data from second"});

            PageInfo pageInfo = BoostNavigator.of().getTopPageInfo();
            BoostNavigator.of().pop();
          },
          child: Text('Go back with result!'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('[XDEBUG]:SecondStatefulRouteWidget disposing~');
    super.dispose();
  }
}

class TabRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tab Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            // FlutterBoost.singleton.open("second");
          },
          child: Text('Open second route3'),
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
        title: Text("Platform Route"),
      ),
      body: Center(
        child: RaisedButton(
          child: TextView(),
          onPressed: () {
            print("open second page!");
            // FlutterBoost.singleton.open("second").then((Map<dynamic,dynamic> value) {
            //   print(
            //       "call me when page is finished. did receive second route result $value");
            // });
          },
        ),
      ),
    );
  }
}
