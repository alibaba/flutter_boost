import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class PushReplacementWidget extends StatefulWidget {
  final int index;

  const PushReplacementWidget({Key? key, required this.index})
      : super(key: key);

  @override
  State<PushReplacementWidget> createState() => _PushReplacementWidgetState();
}

class _PushReplacementWidgetState extends State<PushReplacementWidget> {
  bool withContainer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the CounterPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('PushReplaceDemo'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is Page${widget.index}',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                BoostNavigator.instance.pushReplacement(
                  "pushReplacement",
                  arguments: {
                    'index': widget.index + 1,
                  },
                  withContainer: withContainer,
                );
              },
              child: Text(
                'PushAndReplace',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
