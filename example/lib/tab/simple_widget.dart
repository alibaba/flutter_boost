import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/boost_navigator.dart';

class SimpleWidget extends StatelessWidget {
  final Map params;
  final String messages;
  final String tag;

  SimpleWidget(this.params, this.messages, this.tag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tab_example'),
      ),
      body: SingleChildScrollView(
          child: Container(
              height: 800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 80.0),
                    child: Text(
                      messages,
                      style: TextStyle(fontSize: 28.0, color: Colors.blue),
                    ),
                    alignment: AlignmentDirectional.center,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 32.0),
                    child: Text(
                      tag,
                      style: TextStyle(fontSize: 28.0, color: Colors.red),
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
                    onTap: () => BoostNavigator.of().push("flutterPage"),
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
