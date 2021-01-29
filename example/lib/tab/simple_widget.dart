import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/boost_navigator.dart';
import 'package:flutter_boost/page_visibility.dart';
import '../main.dart';

class SimpleWidget extends StatefulWidget {
  final Map params;
  final String messages;
  final String uniqueId;

  const SimpleWidget(this.uniqueId, this.params, this.messages);

  @override
  _SimpleWidgetState createState() => _SimpleWidgetState();
}

class _SimpleWidgetState extends State<SimpleWidget>
    with PageVisibilityObserver, RouteAware {
  static const String _kTag = 'xlog';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
    PageVisibilityBinding.instance.addObserver(this, ModalRoute.of(context));
    print('$_kTag#didChangeDependencies, ${widget.uniqueId}, $this');
  }

  @override
  void initState() {
    super.initState();
    print('$_kTag#initState, ${widget.uniqueId}, $this');
  }

  @override
  void dispose() {
    PageVisibilityBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    print('$_kTag#dispose, ${widget.uniqueId}, $this');
    super.dispose();
  }

  @override
  void onForeground() {
    print('$_kTag#onForeground, ${widget.uniqueId}, $this');
  }

  @override
  void onBackground() {
    print('$_kTag#onBackground, ${widget.uniqueId}, $this');
  }

  @override
  void onAppear(ChangeReason reason) {
    print('$_kTag#onAppear, ${widget.uniqueId}, $reason, $this');
  }

  void onDisappear(ChangeReason reason) {
    print('$_kTag#onDisappear, ${widget.uniqueId}, $reason, $this');
  }

  @override
  void didPush() {
    final route = ModalRoute.of(context).settings.name;
    print('$_kTag#didPush ${widget.uniqueId}, route: $route');
  }

  @override
  void didPopNext() {
    final route = ModalRoute.of(context).settings.name;
    print('$_kTag#didPopNext ${widget.uniqueId}, route: $route');
  }

  @override
  void didPushNext() {
    final route = ModalRoute.of(context).settings.name;
    print('$_kTag#didPushNext ${widget.uniqueId}, route: $route');
  }

  @override
  void didPop() {
    final route = ModalRoute.of(context).settings.name;
    print('$_kTag#didPop ${widget.uniqueId}, route: $route');
  }

  @override
  String uniqueId() {
    return widget.uniqueId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tab_example'),
      ),
      body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 80.0),
                child: Text(
                  widget.messages,
                  style: TextStyle(fontSize: 28.0, color: Colors.blue),
                ),
                alignment: AlignmentDirectional.center,
              ),
              Container(
                margin: const EdgeInsets.only(top: 32.0),
                child: Text(
                  widget.uniqueId,
                  style: TextStyle(fontSize: 22.0, color: Colors.red),
                ),
                alignment: AlignmentDirectional.center,
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(30.0),
                    color: Colors.yellow,
                    child: Text(
                      'open native page',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.of().push("native"),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(30.0),
                    color: Colors.yellow,
                    child: Text(
                      'open flutter page',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.of().push("flutterPage",
                    arguments: <String, String>{'from': widget.uniqueId}),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(30.0),
                    color: Colors.yellow,
                    child: Text(
                      'open flutter page with FlutterView',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.of().push("flutterPage",
                    withContainer: true,
                    arguments: <String, String>{'from': widget.uniqueId}),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(30.0),
                    color: Colors.yellow,
                    child: Text(
                      'Navigator.push',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(title: Text('Navigator.push')),
                      body: Center(
                        child: TextButton(
                          child: Text('POP'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                )),
              ),
              Container(
                height: 300,
                width: 200,
                child: Text(
                  '',
                  style: TextStyle(fontSize: 22.0, color: Colors.black),
                ),
              )
            ],
          ))),
    );
  }
}
