import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_boost/flutter_boost.dart';

class ReplacementPage extends StatefulWidget {
  const ReplacementPage({Key? key}) : super(key: key);

  @override
  _ReplacementPageState createState() => _ReplacementPageState();
}

class _ReplacementPageState extends State<ReplacementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CupertinoButton.filled(
            child: Text('back'),
            onPressed: () {
              BoostNavigator.instance.pop();
            }),
      ),
    );
  }
}
