import 'package:flutter/material.dart';
import 'package:flutter_boost/boost_navigator.dart';

class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick an option and return'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Close the screen and return "A" as the result.
                  BoostNavigator.of().pop('A');
                },
                child: Text('A'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Close the screen and return "B" as the result.
                  BoostNavigator.of().pop('B');
                },
                child: Text('B'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
