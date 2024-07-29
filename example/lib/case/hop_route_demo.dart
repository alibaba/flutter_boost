import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class HopRoutePageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hop Route Page A'),
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: () {
          BoostNavigator.instance.pushWithHiddenPage(
              'hopRoutePageC', 'hopRoutePageB',
              argumentsOfTargetPage: {'C_id': 'i am C'},
              argumentsOfHiddenPage: {'B_id': 1008611});
        },
        child: const Text('Jump to page C'),
      )),
    );
  }
}

class HopRoutePageB extends StatefulWidget {
  const HopRoutePageB({this.params});

  final Map? params;
  @override
  _HopRoutePageBState createState() => _HopRoutePageBState();
}

class _HopRoutePageBState extends State<HopRoutePageB> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Hop Route Page B')),
        body: Builder(builder: (BuildContext context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(widget.params.toString()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      BoostNavigator.instance
                          .push("hopRoutePageC", withContainer: true);
                    },
                    child: const Text('Open page C'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      BoostNavigator.instance.pop();
                    },
                    child: const Text('Return to page A'),
                  ),
                )
              ],
            ),
          );
        }));
  }
}

class HopRoutePageC extends StatefulWidget {
  const HopRoutePageC({this.params});

  final Map? params;
  @override
  _HopRoutePageCState createState() => _HopRoutePageCState();
}

class _HopRoutePageCState extends State<HopRoutePageC> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Hop Route Page C'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(widget.params.toString()),
          ElevatedButton(
            onPressed: () {
              BoostNavigator.instance.pop();
            },
            child: const Text('Return to page B'),
          )
        ],
      )),
    );
  }
}
