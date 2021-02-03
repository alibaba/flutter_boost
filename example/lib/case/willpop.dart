import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WillPopRoute extends StatefulWidget {
  WillPopRoute({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => new _WillPopRouteState();
}

class _WillPopRouteState extends State<WillPopRoute> {
  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("WillPopRoute"),
        ),
        body: new Center(
          child: new Text("返回的时候提示弹窗"),
        ),
      ),
    );
  }
}
