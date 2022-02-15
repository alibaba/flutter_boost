import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class FlutterRebuildDemo extends StatefulWidget {
  const FlutterRebuildDemo({Key key}) : super(key: key);

  @override
  _FlutterRebuildDemoState createState() => _FlutterRebuildDemoState();
}

class _FlutterRebuildDemoState extends State<FlutterRebuildDemo> {
  @override
  Widget build(BuildContext context) {
    Logger.log('[FlutterRebuildDemo] FlutterRebuildDemo');
    return Scaffold(
      appBar: AppBar(title: Text("FlutterRebuildDemo")),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            MaterialButton(
              color: Colors.blue,
              padding: EdgeInsets.all(10),
              child: Text("push with container"),
              onPressed: () {
                BoostNavigator.instance
                    .push("flutterRebuildPageA", withContainer: true);
              },
            ),
            MaterialButton(
              color: Colors.blue,
              padding: EdgeInsets.all(10),
              child: Text("push without container"),
              onPressed: () {
                BoostNavigator.instance.push("flutterRebuildPageA");
              },
            ),
            MaterialButton(
              color: Colors.blue,
              padding: EdgeInsets.all(10),
              child: Text("back"),
              onPressed: () {
                BoostNavigator.instance.pop();
              },
            )
          ],
        ),
      ),
    );
  }
}

class FlutterRebuildPageA extends StatefulWidget {
  const FlutterRebuildPageA({Key key}) : super(key: key);

  @override
  _FlutterRebuildPageAState createState() => _FlutterRebuildPageAState();
}

class _FlutterRebuildPageAState extends State<FlutterRebuildPageA> {
  @override
  Widget build(BuildContext context) {
    Logger.log('[FlutterRebuildDemo] FlutterRebuildPageA');
    return Scaffold(
      appBar: AppBar(title: Text("FlutterRebuildPageA")),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            MaterialButton(
              color: Colors.blue,
              padding: EdgeInsets.all(10),
              child: Text("push with container"),
              onPressed: () {
                BoostNavigator.instance
                    .push("flutterRebuildPageB", withContainer: true);
              },
            ),
            MaterialButton(
              color: Colors.blue,
              padding: EdgeInsets.all(10),
              child: Text("push without container"),
              onPressed: () {
                BoostNavigator.instance.push("flutterRebuildPageB");
              },
            ),
            MaterialButton(
              color: Colors.blue,
              padding: EdgeInsets.all(10),
              child: Text("back"),
              onPressed: () {
                BoostNavigator.instance.pop();
              },
            )
          ],
        ),
      ),
    );
  }
}

class FlutterRebuildPageB extends StatefulWidget {
  const FlutterRebuildPageB({Key key}) : super(key: key);

  @override
  _FlutterRebuildPageBState createState() => _FlutterRebuildPageBState();
}

class _FlutterRebuildPageBState extends State<FlutterRebuildPageB> {
  @override
  Widget build(BuildContext context) {
    Logger.log('[FlutterRebuildDemo] FlutterRebuildPageB');
    return Scaffold(
      appBar: AppBar(title: Text("FlutterRebuildPageB")),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            MaterialButton(
              color: Colors.blue,
              padding: EdgeInsets.all(10),
              child: Text("back"),
              onPressed: () {
                BoostNavigator.instance.pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
