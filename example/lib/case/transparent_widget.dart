import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

/// For translucent dialog demo
class TransparentWidget extends StatefulWidget {
  @override
  TransparentWidgetState createState() => TransparentWidgetState();
}

class TransparentWidgetState extends State<TransparentWidget> {
  Color _myColor =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0x00000000),
        body: Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xffffffff),
                border: Border.all(color: _myColor, width: 5.0)),
            height: 300,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(24.0),
                        child: Text(
                          'This is translucent dialog.',
                          style: TextStyle(fontSize: 22.0, color: _myColor),
                        ),
                      )),
                  Expanded(
                    flex: 1,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.all(8.0),
                                color: Colors.yellow,
                                child: Text(
                                  'Go Back',
                                  style: TextStyle(
                                      fontSize: 22.0, color: Colors.black),
                                )),
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          InkWell(
                            child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.all(8.0),
                                color: Colors.yellow,
                                child: Text(
                                  'Open New Dialog',
                                  style: TextStyle(
                                      fontSize: 22.0, color: Colors.black),
                                )),
                            onTap: () => BoostNavigator.instance.push(
                                "transparentWidget",
                                withContainer: true,
                                opaque: false),
                          ),
                        ]),
                  ),
                ]),
          ),
        ));
  }
}
