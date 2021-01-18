import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WillPopRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("willPop  Route"),
          ),
          body: Center(
            child: RaisedButton(
              onPressed: () {},
              child: Text('Go back with result!'),
            ),
          ),
        ),
        onWillPop: () {
          print('xxxxx');
          return Future.value(true);
        });
  }
}
