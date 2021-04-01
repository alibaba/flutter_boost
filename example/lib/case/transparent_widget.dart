import 'package:flutter/material.dart';
import 'package:flutter_boost/boost_navigator.dart';

class TransparentWidget extends StatelessWidget {
  const TransparentWidget();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x00000000),
      body: Container(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {
            BoostNavigator.of().pop();
          },
          child: Container(
            height: 300,
            color: const Color(0xffffffff),
            child: const Text(
              '部分区域透明的widget',
              style: TextStyle(fontSize: 26.0, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}
