import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WillPopRoute extends StatefulWidget {
  WillPopRoute({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => new _WillPopRouteState();
}

class _WillPopRouteState extends State<WillPopRoute> {
  bool shouldPop = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter WillPopScope demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                child: const Text('Go back!'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                child: Text('shouldPop: $shouldPop'),
                onPressed: () {
                  setState(
                    () {
                      shouldPop = !shouldPop;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
