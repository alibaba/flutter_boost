import 'package:flutter/material.dart';
import 'package:flutter_boost/boost_navigator.dart';

class ReturnDataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Passing data when popping')),
      body: Center(
        child: ElevatedButton(
          child: Text('Popping with data'),
          onPressed: () {
            BoostNavigator.of().pop('#FlutterBoost3.0');
          },
        ),
      ),
    );
  }
}
