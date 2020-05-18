import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost_example/platform_view.dart';

class FirstRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FirstRouteWidgetState();
}

class _FirstRouteWidgetState extends State<FirstRouteWidget> {
  _FirstRouteWidgetState();

  // flutter 侧MethodChannel配置，channel name需要和native侧一致
  static const MethodChannel _methodChannel = MethodChannel('flutter_native_channel');
  String _systemVersion = '';

  Future<dynamic> _getPlatformVersion() async {

    try {
      final String result = await _methodChannel.invokeMethod('getPlatformVersion');
      print('getPlatformVersion:' + result);
      setState(() {
        _systemVersion = result;
      });
    } on PlatformException catch (e) {
      print(e.message);
    }

  }

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
      appBar: AppBar(title: const Text('First Route')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: const Text('Open native page'),
              onPressed: () {
                print('open natve page!');
                FlutterBoost.singleton
                    .open('native')
                    .then((Map<dynamic, dynamic> value) {
                  print(
                      'call me when page is finished. did recieve native route result $value');
                });
              },
            ),
            RaisedButton(
              child: const Text('Open FF route'),
              onPressed: () {
                print('open FF page!');
                FlutterBoost.singleton
                    .open('firstFirst')
                    .then((Map<dynamic, dynamic> value) {
                  print(
                      'call me when page is finished. did recieve FF route result $value');
                });
              },
            ),
            RaisedButton(
              child: const Text('Open second route1'),
              onPressed: () {
                print('open second page!');
                FlutterBoost.singleton
                    .open('second')
                    .then((Map<dynamic, dynamic> value) {
                  print(
                      'call me when page is finished. did recieve second route result $value');
                });
              },
            ),
            RaisedButton(
              child: const Text('Present second stateful route'),
              onPressed: () {
                print('Present second stateful page!');
                FlutterBoost.singleton.open('secondStateful',
                    urlParams: <String, dynamic>{
                      'present': true
                    }).then((Map<dynamic, dynamic> value) {
                  print(
                      'call me when page is finished. did recieve second stateful route result $value');
                });
              },
            ),
            RaisedButton(
              child: const Text('Present second route'),
              onPressed: () {
                print('Present second page!');
                FlutterBoost.singleton.open('second',
                    urlParams: <String, dynamic>{
                      'present': true
                    }).then((Map<dynamic, dynamic> value) {
                  print(
                      'call me when page is finished. did recieve second route result $value');
                });
              },
            ),
            RaisedButton(
              child: Text('Get system version by method channel:' + _systemVersion),
              onPressed: () => _getPlatformVersion(),
            ),
          ],
        ),
      ),
    );
  }
}

class FirstFirstRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FirstFirstRouteWidgetState();
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
      appBar: AppBar(title: const Text('First Route')),
      body: Center(
        child: RaisedButton(
          child: const Text('Open first route'),
          onPressed: () {
            print('open first page again!');
            FlutterBoost.singleton
                .open('first')
                .then((Map<dynamic, dynamic> value) {
              print('did recieve first route result');
              print('did recieve first route result $value');
            });
          },
        ),
      ),
    );
  }
}

class EmbeddedFirstRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmbeddedFirstRouteWidgetState();
}

class _EmbeddedFirstRouteWidgetState extends State<EmbeddedFirstRouteWidget> {
  @override
  Widget build(BuildContext context) {
    print('_EmbededFirstRouteWidgetState build called!');
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: const Text('Open second route2'),
          onPressed: () {
            print('open second page!');
            FlutterBoost.singleton
                .open('second')
                .then((Map<dynamic, dynamic> value) {
              print(
                  'call me when page is finished. did recieve second route result $value');
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('[XDEBUG]:_EmbededFirstRouteWidgetState disposing~');
    super.dispose();
  }
}

class SecondStatefulRouteWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SecondStatefulRouteWidgetState();
}

class _SecondStatefulRouteWidgetState extends State<SecondStatefulRouteWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SecondStateful Route')),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            final BoostContainerSettings settings =
                BoostContainer.of(context).settings;
            FlutterBoost.singleton.close(settings.uniqueId,
                result: <String, dynamic>{'result': 'data from second'});
          },
          child: const Text('Go back with result!'),
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
      appBar: AppBar(title: const Text('Second Route')),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            final BoostContainerSettings settings =
                BoostContainer.of(context).settings;
            FlutterBoost.singleton.close(
              settings.uniqueId,
              result: <String, dynamic>{'result': 'data from second'},
            );
          },
          child: const Text('Go back with result!'),
        ),
      ),
    );
  }
}

class TabRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tab Route')),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            FlutterBoost.singleton.open('second');
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
      appBar: AppBar(title: const Text('Platform Route')),
      body: Center(
        child: RaisedButton(
          child: const TextView(),
          onPressed: () {
            print('open second page!');
            FlutterBoost.singleton
                .open('second')
                .then((Map<dynamic, dynamic> value) {
              print(
                  'call me when page is finished. did recieve second route result $value');
            });
          },
        ),
      ),
    );
  }
}

class FlutterRouteWidget extends StatefulWidget {
  const FlutterRouteWidget({this.params, this.message});

  final Map<String, dynamic> params;
  final String message;

  @override
  _FlutterRouteWidgetState createState() => _FlutterRouteWidgetState();
}

class _FlutterRouteWidgetState extends State<FlutterRouteWidget> {

  // flutter 侧MethodChannel配置，channel name需要和native侧一致
  static const MethodChannel _methodChannel = MethodChannel('flutter_native_channel');
  String _systemVersion = '';

  Future<dynamic> _getPlatformVersion() async {

    try {
      final String result = await _methodChannel.invokeMethod('getPlatformVersion');
      print('getPlatformVersion:' + result);
      setState(() {
        _systemVersion = result;
      });
    } on PlatformException catch (e) {
      print(e.message);
    }

  }

  @override
  Widget build(BuildContext context) {
    final String message = widget.message;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        textTheme: const TextTheme(title: TextStyle(color: Colors.black)),
        title: const Text('flutter_boost_example'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: Text(
                  message ??
                      'This is a flutter activity \n params:${widget.params}',
                  style: TextStyle(fontSize: 28.0, color: Colors.blue),
                ),
                alignment: AlignmentDirectional.center,
              ),
              const CupertinoTextField(
                prefix: Icon(
                  CupertinoIcons.person_solid,
                  color: CupertinoColors.lightBackgroundGray,
                  size: 28.0,
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
                clearButtonMode: OverlayVisibilityMode.editing,
                textCapitalization: TextCapitalization.words,
                autocorrect: false,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        width: 0.0, color: CupertinoColors.inactiveGray),
                  ),
                ),
                placeholder: 'Name',
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.yellow,
                  child: const Text(
                    'open native page',
                    style: TextStyle(fontSize: 22.0, color: Colors.black),
                  ),
                ),

                /// 后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                /// 例如：sample://nativePage?aaa=bbb
                onTap: () => FlutterBoost.singleton.open(
                  'sample://nativePage',
                  urlParams: <String, dynamic>{
                    'query': <String, dynamic>{'aaa': 'bbb'}
                  },
                ),
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.yellow,
                  child: const Text(
                    'open first',
                    style: TextStyle(fontSize: 22.0, color: Colors.black),
                  ),
                ),

                /// 后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                /// 例如：sample://nativePage?aaa=bbb
                onTap: () => FlutterBoost.singleton.open(
                  'first',
                  urlParams: <String, dynamic>{
                    'query': <String, dynamic>{'aaa': 'bbb'}
                  },
                ),
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.yellow,
                  child: const Text(
                    'open second',
                    style: TextStyle(fontSize: 22.0, color: Colors.black),
                  ),
                ),

                /// 后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                /// 例如：sample://nativePage?aaa=bbb
                onTap: () => FlutterBoost.singleton.open(
                  'second',
                  urlParams: <String, dynamic>{
                    'query': <String, dynamic>{'aaa': 'bbb'}
                  },
                ),
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.yellow,
                  child: const Text(
                    'open tab',
                    style: TextStyle(fontSize: 22.0, color: Colors.black),
                  ),
                ),

                /// 后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                /// 例如：sample://nativePage?aaa=bbb
                onTap: () => FlutterBoost.singleton.open(
                  'tab',
                  urlParams: <String, dynamic>{
                    'query': <String, dynamic>{'aaa': 'bbb'}
                  },
                ),
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.yellow,
                  child: const Text(
                    'open flutter page',
                    style: TextStyle(fontSize: 22.0, color: Colors.black),
                  ),
                ),

                /// 后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                /// 例如：sample://nativePage?aaa=bbb
                onTap: () => FlutterBoost.singleton.open(
                  'sample://flutterPage',
                  urlParams: <String, dynamic>{
                    'query': <String, dynamic>{'aaa': 'bbb'}
                  },
                ),
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.yellow,
                  child: const Text(
                    'push flutter widget',
                    style: TextStyle(fontSize: 22.0, color: Colors.black),
                  ),
                ),
                onTap: () {
                  Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(builder: (_) => PushWidget()),
                  );
                },
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.yellow,
                  child: const Text(
                    'push Platform demo',
                    style: TextStyle(fontSize: 22.0, color: Colors.black),
                  ),
                ),
                onTap: () {
                  Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (_) => PlatformRouteWidget()),
                  );
                },
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.yellow,
                  child: const Text(
                    'open flutter fragment page',
                    style: TextStyle(fontSize: 22.0, color: Colors.black),
                  ),
                ),
                onTap: () =>
                    FlutterBoost.singleton.open('sample://flutterFragmentPage'),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'get system version by method channel:' + _systemVersion,
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => _getPlatformVersion(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FragmentRouteWidget extends StatelessWidget {
  const FragmentRouteWidget(this.params);

  final Map<String, dynamic> params;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_boost_example')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 80.0),
            child: Text(
              'This is a flutter fragment',
              style: TextStyle(fontSize: 28.0, color: Colors.blue),
            ),
            alignment: AlignmentDirectional.center,
          ),
          Container(
            margin: const EdgeInsets.only(top: 32.0),
            child: Text(
              '${params['tag']}' ?? '',
              style: TextStyle(fontSize: 28.0, color: Colors.red),
            ),
            alignment: AlignmentDirectional.center,
          ),
          Expanded(child: Container()),
          InkWell(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              color: Colors.yellow,
              child: const Text(
                'open native page',
                style: TextStyle(fontSize: 22.0, color: Colors.black),
              ),
            ),
            onTap: () => FlutterBoost.singleton.open('sample://nativePage'),
          ),
          InkWell(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              color: Colors.yellow,
              child: const Text(
                'open flutter page',
                style: TextStyle(fontSize: 22.0, color: Colors.black),
              ),
            ),
            onTap: () => FlutterBoost.singleton.open('sample://flutterPage'),
          ),
          InkWell(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 80.0),
              color: Colors.yellow,
              child: const Text(
                'open flutter fragment page',
                style: TextStyle(fontSize: 22.0, color: Colors.black),
              ),
            ),
            onTap: () =>
                FlutterBoost.singleton.open('sample://flutterFragmentPage'),
          )
        ],
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
  void didChangeDependencies() {
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
    print('[XDEBUG] - PushWidget is disposing~');
    super.dispose();
    _backPressedListenerUnsub?.call();
  }

  @override
  Widget build(BuildContext context) {
    return const FlutterRouteWidget(message: 'Pushed Widget');
  }
}
