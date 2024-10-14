import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class CupertinoPageRouteDemo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cupertino Page Route Demo'),
      ),
      body: Center(
        child: TextButton(
          child: const Text('Dismiss'),
          onPressed: () {
            BoostNavigator.instance.pop();
          },
        ),
      )
    );
  }
}