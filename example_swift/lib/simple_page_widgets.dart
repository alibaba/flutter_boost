import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class FirstRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Center(
        child: RaisedButton(
          child: const Text('Open second route'),
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

class SecondRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
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
          child: const Text('Open second route'),
        ),
      ),
    );
  }
}

class FlutterRouteWidget extends StatelessWidget {
  const FlutterRouteWidget({this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_boost_example'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 80.0),
            child: Text(
              message ?? 'This is a flutter activity',
              style: TextStyle(fontSize: 28.0, color: Colors.blue),
            ),
            alignment: AlignmentDirectional.center,
          ),
          Expanded(child: Container()),
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
                child: Text(
                  'open flutter page',
                  style: TextStyle(fontSize: 22.0, color: Colors.black),
                )),

            ///后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
            ///例如：sample://nativePage?aaa=bbb
            onTap: () => FlutterBoost.singleton.open(
              'sample://flutterPage',
              urlParams: <String, dynamic>{
                'query': <String, dynamic>{'aaa': 'bbb'},
              },
            ),
          ),
          InkWell(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              color: Colors.yellow,
              child: Text(
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
              child: Text(
                'open flutter fragment page',
                style: TextStyle(fontSize: 22.0, color: Colors.black),
              ),
            ),
            onTap: () =>
                FlutterBoost.singleton.open('sample://flutterFragmentPage'),
          ),
        ],
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
      appBar: AppBar(
        title: const Text('flutter_boost_example'),
      ),
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
              child: Text(
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
              child: Text(
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
              child: Text(
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
    super.dispose();
    _backPressedListenerUnsub?.call();
  }

  @override
  Widget build(BuildContext context) {
    return const FlutterRouteWidget(message: 'Pushed Widget');
  }
}
