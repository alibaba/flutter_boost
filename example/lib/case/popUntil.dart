import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class PopUntilRoute extends StatefulWidget {
  static int count = 0;

  @override
  PopUntilRouteState createState() => PopUntilRouteState();
}

class PopUntilRouteState extends State<PopUntilRoute> {
  @override
  void initState() {
    super.initState();
    PopUntilRoute.count++;
  }

  @override
  void dispose() {
    super.dispose();
    PopUntilRoute.count--;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            child: Row(
              children: [
                // Icon(Icons.arrow_back),
                Text('popUntil'),
              ],
            ),
            onTap: () => onBackPressed(context),
          ),
          title: Text('Page A ${PopUntilRoute.count}'),
        ),
        body: Container(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    BoostNavigator.instance
                        .push("popUntilView", withContainer: true);
                  },
                  child: Text('push with container')),
              TextButton(
                  onPressed: () {
                    BoostNavigator.instance
                        .push("popUntilView", withContainer: false);
                  },
                  child: Text('push without container ')),
            ],
          )),
        ));
  }

  void onBackPressed(BuildContext context) {
    BoostNavigator.instance.popUntil(route: "flutterPage");
  }
}
