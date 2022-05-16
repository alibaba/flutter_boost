import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class FlutterRouteWidget extends StatefulWidget {
  FlutterRouteWidget({this.params, this.message, this.uniqueId});

  final Map params;
  final String message;
  final String uniqueId;

  @override
  _FlutterRouteWidgetState createState() => _FlutterRouteWidgetState();
}

class _FlutterRouteWidgetState extends State<FlutterRouteWidget>
    with PageVisibilityObserver {
  static const String _kTag = 'page_visibility';
  bool withContainer = true;

  @override
  void initState() {
    super.initState();
    Logger.log('$_kTag#initState, ${widget.uniqueId}, $this');
  }

  @override
  void didChangeDependencies() {
    Logger.log('$_kTag#didChangeDependencies, ${widget.uniqueId}, $this');
    PageVisibilityBinding.instance.addObserver(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    PageVisibilityBinding.instance.removeObserver(this);
    Logger.log('$_kTag#dispose~, ${widget.uniqueId}, $this');
    super.dispose();
  }

  @override
  void onPageShow() {
    Logger.log('$_kTag#onPageShow, ${widget.uniqueId}, $this');
  }

  void onPageHide() {
    Logger.log('$_kTag#onPageHide, ${widget.uniqueId}, $this');
  }

  @override
  void onForeground() {
    Logger.log('$_kTag#onForeground, ${widget.uniqueId}, $this');
  }

  @override
  void onBackground() {
    Logger.log('$_kTag#onBackground, ${widget.uniqueId}, $this');
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

    return Scaffold(
      appBar: AppBar(
        title: Text('FlutterBoost Example'),
        actions: <Widget>[
          Switch(
            value: withContainer,
            onChanged: (value) {
              setState(() {
                withContainer = value;
              });
            },
            activeTrackColor: Colors.yellow,
            activeColor: Colors.orangeAccent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin:
                    const EdgeInsets.only(left: 8.0, top: 10.0, bottom: 20.0),
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
                  TextSpan(
                      text: "withContainer: ",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  TextSpan(
                      text: "$withContainer",
                      style: TextStyle(fontSize: 16.0, color: Colors.red)),
                ])),
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
              ),
              new TextField(
                enabled: true,
                autocorrect: true,
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
                      'Pop with Navigator',
                      style: TextStyle(fontSize: 22.0, color: Colors.blue),
                    )),
                onTap: () => Navigator.of(context).pop(),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'Open native page',
                      style: TextStyle(fontSize: 22.0, color: Colors.blue),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("native")
                    .then((value) => print("Return from Native: ${value?.toString()}")),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'image_picker demo',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("imagepick", withContainer: withContainer),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'You can not open this page',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("interceptor", withContainer: withContainer),
              ),
              InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'WillPopScope demo',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),
                  onTap: () => BoostNavigator.instance
                      .push("willPop", withContainer: withContainer)),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'MediaQuery demo',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("mediaquery", withContainer: withContainer)
                    .then((value) =>
                        print('xlog, mediaquery, Return Value:$value')),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'PlatformView Example',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance.push(
                    "platformview/animation",
                    withContainer: withContainer),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'WebView Example',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("webview", withContainer: withContainer)
                    .then(
                        (value) => print('xlog, webview, Return Value:$value')),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'PlatformView Perf Test',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance.push(
                    "platformview/listview",
                    withContainer: withContainer),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'Simple WebView Test',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance.push(
                    "platformview/simplewebview",
                    withContainer: withContainer),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'Bottom Navigation Example',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("bottom_navigation", withContainer: withContainer),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'State Restoration Example',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("state_restoration", withContainer: withContainer),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'SystemUiOverlayStyle Example',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance.push(
                    "system_ui_overlay_style",
                    withContainer: withContainer),
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
                  Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                          builder: (_) => PushWidget())).then((value) =>
                      print('xlog, PushWidget, Return Value: $value'));
                },
              ),
              InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'returning data demo',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),
                  onTap: () => BoostNavigator.instance
                      .push("returnData", withContainer: withContainer)),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'translucent dialog demo',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () {
                  BoostNavigator.instance.push("transparentWidget",
                      withContainer: withContainer, opaque: false);
                },
              ),
              InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'Radial Transition Demo',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),
                  onTap: () => BoostNavigator.instance
                      .push("radialExpansion", withContainer: withContainer)),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'popUntil demo',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () {
                  BoostNavigator.instance
                      .push('popUntilView', withContainer: withContainer);
                },
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'flutter rebuild demo',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () {
                  BoostNavigator.instance
                      .push('flutterRebuildDemo', withContainer: withContainer);
                },
              ),
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
  void dispose() {
    super.dispose();
    _backPressedListenerUnsub?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              // 如果有抽屉的话的就打开
              onPressed: () {
                // BoostNavigator.instance.pop('Hello, I am from PushWidget.');
                Navigator.of(context).pop('Hello, I am from PushWidget.');
              },
              // 显示描述信息
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          }),
          title: Text('flutter_boost_example'),
        ),
        body: Container(
          color: Colors.red,
          width: 300,
          height: 300,
        ));
  }
}
