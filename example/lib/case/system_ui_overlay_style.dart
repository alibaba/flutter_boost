/// Flutter code sample for SystemChrome.setSystemUIOverlayStyle

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';

///
/// SystemUiOverlayStyle 测试Demo
///
class SystemUiOverlayStyleDemo extends StatefulWidget {
  final bool? isDark;

  const SystemUiOverlayStyleDemo({Key? key, this.isDark = false})
      : super(key: key);

  static const String _title = 'SystemUiOverlayStyle Demo';

  @override
  State<SystemUiOverlayStyleDemo> createState() =>
      _SystemUiOverlayStyleDemoState();
}

class _SystemUiOverlayStyleDemoState extends State<SystemUiOverlayStyleDemo> {
  late bool withContainer;
  late Random _random = Random();
  late SystemUiOverlayStyle _currentStyle;

  @override
  void initState() {
    super.initState();
    _currentStyle = (widget.isDark ?? true)
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
    withContainer = true;
  }

  void _changeColor() {
    final Color color = Color.fromRGBO(
      _random.nextInt(255),
      _random.nextInt(255),
      _random.nextInt(255),
      1.0,
    );
    setState(() {
      _currentStyle = _currentStyle.copyWith(
        statusBarColor: color,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SystemUiOverlayStyleDemo._title),
        systemOverlayStyle: _currentStyle,
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('newContainer'),
                Switch(
                  value: withContainer,
                  onChanged: (value) {
                    setState(() {
                      withContainer = value;
                    });
                  },
                  activeTrackColor: Colors.yellow,
                  activeColor: Colors.orangeAccent,
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: const Text(
                        'change current systemUIOverlay',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),
                  onTap: () {
                    _changeColor();
                  },
                ),
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: const Text(
                        'Open Light SystemUIOverlay Style Page',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),
                  onTap: () {
                    BoostNavigator.instance.push("system_ui_overlay_style",
                        arguments: {
                          'isDark': false,
                        },
                        withContainer: withContainer);
                  },
                ),
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: const Text(
                        'Open Dark SystemUIOverlay Style Page',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),
                  onTap: () {
                    BoostNavigator.instance.push("system_ui_overlay_style",
                        arguments: {
                          'isDark': true,
                        },
                        withContainer: withContainer);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
