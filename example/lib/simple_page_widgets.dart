import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost_example/platform_view.dart';
import 'package:flutter_boost/boost_navigator.dart';

class FirstRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _FirstRouteWidgetState();
  }
}
class _FirstRouteWidgetState extends State<FirstRouteWidget>{
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
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          <Widget>[
            RaisedButton(
                child: Text('Open native page'),
                onPressed: () {
                  print("open native page!");
                  BoostNavigator.of(context).push("native");

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
                  BoostNavigator.of(context).push("firstFirst");

                },
              ),
              RaisedButton(
                child: Text('Open second route1'),
                onPressed: () {
                  print("open second page!22");
//                  FlutterBoost.singleton.open("second").then((Map<dynamic,dynamic> value) {
//                    print(
//                        "call me when page is finished. did receive second route result $value");
//                  });

                  BoostNavigator.of(context).push("second",openContainer: true);

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
                  }
                )
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

class _FirstFirstRouteWidgetState extends State<FirstFirstRouteWidget>{
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
class _SecondStatefulRouteWidgetState extends State<SecondStatefulRouteWidget>{
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

class SecondRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            // Navigate back to first route when tapped.

            // BoostContainerSettings settings =
            //     BoostContainer.of(context).settings;
            // FlutterBoost.singleton.close(settings.uniqueId,
            //     result: <String,dynamic>{"result": "data from second"});
          },
          child: Text('Go back with result!'),
        ),
      ),
    );
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
        title:Text("Platform Route"),
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
class FlutterRouteWidget extends StatefulWidget {
  FlutterRouteWidget({this.params,this.message});
  final Map params;
  final String message;

  @override
  _FlutterRouteWidgetState createState() => _FlutterRouteWidgetState();
}

class _FlutterRouteWidgetState extends State<FlutterRouteWidget> {
  final TextEditingController _usernameController = TextEditingController();
  @override
  void dispose(){
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final String message=widget.message;
    return Scaffold(
      appBar: AppBar(
        // brightness:Brightness.light,
        // backgroundColor: Colors.white,
        // textTheme:new TextTheme(title: TextStyle(color: Colors.black)) ,

        title: Text('flutter_boost_example'),
      ),

      body: SingleChildScrollView(
        child:Container(
          height: 500,
            margin: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10.0,bottom: 20.0),
                  child: Text(
                    message ?? "This is a flutter activity \n params:${widget.params}",
                    style: TextStyle(fontSize: 28.0, color: Colors.blue),
                  ),
                  alignment: AlignmentDirectional.center,
                ),
//                Expanded(child: Container()),
        const CupertinoTextField(
          prefix: Icon(
            CupertinoIcons.person_solid,
            color: CupertinoColors.lightBackgroundGray,
            size: 28.0,
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
          clearButtonMode: OverlayVisibilityMode.editing,
          textCapitalization: TextCapitalization.words,
        ),
                new TextField(
                  enabled: true,
                  autocorrect: true,
                  style: const TextStyle(
                      fontSize: 20.0,
                      color: const Color(0xFF222222),
                      fontWeight: FontWeight.w500),
                ), new TextField(
                  controller: new TextEditingController(),
                  focusNode:FocusNode(),
                  enabled: true,
                  autocorrect: false,
                  style: const TextStyle(
                      fontSize: 20.0,
                      color: const Color(0xFF222222),
                      fontWeight: FontWeight.w500),
                ),
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'open native page',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),

                  ///后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                  ///例如：sample://nativePage?aaa=bbb
                  onTap: () =>  BoostNavigator.of(context).push("native"),
                ),
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'open first',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),

                  ///后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                  ///例如：sample://nativePage?aaa=bbb
                  onTap: () => BoostNavigator.of(context).push("first"),
                ),
                // InkWell(
                //   child: Container(
                //       padding: const EdgeInsets.all(8.0),
                //       margin: const EdgeInsets.all(8.0),
                //       color: Colors.yellow,
                //       child: Text(
                //         'open second',
                //         style: TextStyle(fontSize: 22.0, color: Colors.black),
                //       )),
                //
                //   ///后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                //   ///例如：sample://nativePage?aaa=bbb
                //   // onTap: () => FlutterBoost.singleton
                //   //     .open("second", urlParams:<String,dynamic> {
                //   //   "query": {"aaa": "bbb"}
                //   // }),
                // ),
                // InkWell(
                //   child: Container(
                //       padding: const EdgeInsets.all(8.0),
                //       margin: const EdgeInsets.all(8.0),
                //       color: Colors.yellow,
                //       child: Text(
                //         'open tab',
                //         style: TextStyle(fontSize: 22.0, color: Colors.black),
                //       )),
                //
                //   ///后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                //   ///例如：sample://nativePage?aaa=bbb
                //   // onTap: () => FlutterBoost.singleton
                //   //     .open("tab", urlParams:<String,dynamic> {
                //   //   "query": {"aaa": "bbb"}
                //   // }),
                // ),
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'open flutter page',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),

                  ///后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                  ///例如：sample://nativePage?aaa=bbb
                  onTap: () =>  BoostNavigator.of(context).push("flutterPage",openContainer: false),
                ),
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'push flutter widget',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),
                  onTap: () {
                  Navigator.push<dynamic>(context,
                        MaterialPageRoute<dynamic>(builder: (_) => PushWidget()));
                  // Navigator.of(context).maybePop();

                  },
                ),

              // InkWell(
              //   child: Container(
              //       padding: const EdgeInsets.all(8.0),
              //       margin: const EdgeInsets.all(8.0),
              //       color: Colors.yellow,
              //       child: Text(
              //         'push Platform demo',
              //         style: TextStyle(fontSize: 22.0, color: Colors.black),
              //       )),
              //   onTap: () {
              //     Navigator.push<dynamic>(context,
              //         MaterialPageRoute<dynamic>(builder: (_) => PlatformRouteWidget()));
              //   }
              // ),
              //   InkWell(
              //     child: Container(
              //         padding: const EdgeInsets.all(8.0),
              //         margin: const EdgeInsets.all(8.0),
              //         color: Colors.yellow,
              //         child: Text(
              //           'open flutter fragment page',
              //           style: TextStyle(fontSize: 22.0, color: Colors.black),
              //         )),
              //     // onTap: () => FlutterBoost.singleton
              //     //     .open("sample://flutterFragmentPage"),
              //   ),
              ],
            ),

        ),
      ),
    );
  }

}


class PushWidget extends StatefulWidget {
  @override
  _PushWidgetState createState() => _PushWidgetState();
}

class _PushWidgetState extends State<PushWidget> {
  VoidCallback _backPressedListenerUnsub;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

//    if (_backPressedListenerUnsub == null) {
//      _backPressedListenerUnsub =
//          BoostContainer.of(context).addBackPressedListener(() {
//        if (BoostContainer.of(context).onstage &&
//            ModalRoute.of(context).isCurrent) {
//          Navigator.pop(context);
//        }
//      });
//    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('[XDEBUG] - PushWidget is disposing~');
    super.dispose();
    _backPressedListenerUnsub?.call();
  }

  @override
  Widget build(BuildContext context) {
    return FirstFirstRouteWidget();
  }
}
