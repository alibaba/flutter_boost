import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost_example/case/platform_view.dart';
import 'package:flutter_boost/boost_navigator.dart';
import 'package:flutter_boost/logger.dart';

class FlutterRouteWidget extends StatefulWidget {
  FlutterRouteWidget({this.params, this.message, this.uniqueId});
  final Map params;
  final String message;
  final String uniqueId;

  @override
  _FlutterRouteWidgetState createState() => _FlutterRouteWidgetState();
}

class _FlutterRouteWidgetState extends State<FlutterRouteWidget> {
  final TextEditingController _usernameController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger.log(
        '${MediaQuery.of(context).padding.top} uniqueId=${widget.uniqueId}');
    Logger.log(
        '${MediaQuery.of(context).padding.bottom} uniqueId=${widget.uniqueId}');
    Logger.log(
        '${MediaQuery.of(context).size.width} uniqueId=${widget.uniqueId}');
    Logger.log(
        '${MediaQuery.of(context).size.height} uniqueId=${widget.uniqueId}');

    final String message = widget.message;
    return Scaffold(
      appBar: AppBar(
        // brightness:Brightness.light,
        // backgroundColor: Colors.white,
        // textTheme:new TextTheme(title: TextStyle(color: Colors.black)) ,

        title: Text('flutter_boost_example'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 700,
          margin: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: Text(
                  message ??
                      "This is a flutter activity \n params:${widget.params}",
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
              ),
              new TextField(
                controller: new TextEditingController(),
                focusNode: FocusNode(),
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
                onTap: () => BoostNavigator.of().push("native"),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'open imagepick demo',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),

                ///后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                ///例如：sample://nativePage?aaa=bbb
                onTap: () =>
                    BoostNavigator.of().push("imagepick", openContainer: true),
              ),
              InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'open willPop demo',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),

                  ///后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                  ///例如：sample://nativePage?aaa=bbb
                  onTap: () =>
                      BoostNavigator.of().push("willPop", openContainer: true)),
              InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'mediaquery demo',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),

                  ///后面的参数会在native的IPlatform.startActivity方法回调中拼接到url的query部分。
                  ///例如：sample://nativePage?aaa=bbb
                  onTap: () => BoostNavigator.of()
                      .push("mediaquery", openContainer: true)),

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
                onTap: () => BoostNavigator.of()
                    .push("flutterPage", openContainer: true),
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
    super.dispose();
    _backPressedListenerUnsub?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
