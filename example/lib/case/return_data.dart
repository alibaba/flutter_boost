import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class ReturnDataWidget extends StatefulWidget {
  @override
  State<ReturnDataWidget> createState() => _ReturnDataWidgetState();
}

class _ReturnDataWidgetState extends State<ReturnDataWidget> {
  bool withContainer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Return data from a screen'),
          actions: <Widget>[
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
        body: Builder(builder: (BuildContext context) {
          return Center(
            child: ElevatedButton(
              child: const Text('Pick an option, any option!'),
              onPressed: () {
                _navigateAndDisplaySelection(context);
              },
            ),
          );
        }));
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    final result = await BoostNavigator.instance
        .push('selectionScreen', withContainer: withContainer);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("$result")));
  }
}
