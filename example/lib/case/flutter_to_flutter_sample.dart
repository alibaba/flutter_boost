import 'package:flutter/material.dart';

class F2FFirstPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return F2FFirstPageState();
  }
}

class F2FFirstPageState extends State<F2FFirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Open second with native container'),
              onPressed: () {
                // FlutterBoost.singleton.open("f2f_second");
              },
            ),
            ElevatedButton(
              child: const Text('Open second without native container'),
              onPressed: () {
                // FlutterBoost.singleton.openInCurrentContainer("f2f_second");
              },
            ),
          ],
        ),
      ),
    );
  }
}

class F2FSecondPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return F2FSecondPageState();
  }
}

class F2FSecondPageState extends State<F2FSecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('close'),
              onPressed: () {
                // FlutterBoostAPI.singleton.close();
              },
            ),
          ],
        ),
      ),
    );
  }
}
