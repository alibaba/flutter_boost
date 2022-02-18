import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class DialogPage extends StatefulWidget {
  const DialogPage({Key key}) : super(key: key);

  @override
  _DialogPageState createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 250,
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Material(
          child: CupertinoButton(
              color: Colors.deepPurpleAccent,
              child: const Text('点击退出弹窗'),
              onPressed: () {
                //这里退出依然要用Boost的导航器，而不是官方的Navigator
                BoostNavigator.instance.pop();
              }),
        ),
      ),
    );
  }
}
