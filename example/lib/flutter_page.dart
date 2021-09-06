import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/boost_navigator.dart';
import 'package:flutter_boost/logger.dart';
import 'package:flutter_boost/page_visibility.dart';

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
  final TextEditingController _usernameController = TextEditingController();
  static const String _kTag = 'page_visibility';

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
  void onPageCreate() {
    Logger.log('$_kTag#onPageCreate, ${widget.uniqueId}, $this');
  }

  @override
  void onPageDestroy() {
    Logger.log('$_kTag#onPageDestroy, ${widget.uniqueId}, $this');
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

    final String message = widget.message;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        textTheme: new TextTheme(title: TextStyle(color: Colors.black)),
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.arrow_back),
            // 如果有抽屉的话的就打开
            onPressed: () {
              BoostNavigator.instance.pop();
            },
            // 显示描述信息
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        }),
        title: Text('flutter_boost_example'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: Text.rich(TextSpan(text: '', children: <TextSpan>[
                  TextSpan(
                      text: message ??
                          "This is a flutter activity.\nuniqueId:${widget.uniqueId}",
                      style: TextStyle(color: Colors.blue)),
                  TextSpan(
                      text: "\nparams: ${widget?.params}",
                      style: TextStyle(fontStyle: FontStyle.italic)),
                ])),
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
                      'open native page',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("native")
                    .then((value) => print("return:${value?.toString()}")),
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
                onTap: () => BoostNavigator.instance
                    .push("imagepick", withContainer: true),
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
                  onTap: () => BoostNavigator.instance
                      .push("willPop", withContainer: true)),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'mediaquery demo(withContainer=false)',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("mediaquery", withContainer: false)
                    .then((value) =>
                        print('xlog, mediaquery, Return Value:$value')),
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
                    .push("webview", withContainer: true)
                    .then(
                        (value) => print('xlog, webview, Return Value:$value')),
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
                    .push("state_restoration", withContainer: true),
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
                onTap: () => BoostNavigator.instance
                    .push("system_ui_overlay_style", withContainer: true),
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
                      .push("returnData", withContainer: true)),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.yellow,
                    child: Text(
                      'open transparent widget',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () {
                  BoostNavigator.instance.push("transparentWidget",
                      withContainer: true, opaque: false);
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
                      .push("radialExpansion", withContainer: false)),
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
                  BoostNavigator.instance.push('popUntilView', withContainer: true);
                  // await BoostNavigator.instance
                  //     .push("radialExpansion", withContainer: false);
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
