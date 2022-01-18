import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter_boost/flutter_boost.dart';

class MediaQueryRouteWidget extends StatefulWidget {
  MediaQueryRouteWidget({this.params, this.message, this.uniqueId});

  final Map params;
  final String message;
  final String uniqueId;

  @override
  State<StatefulWidget> createState() {
    return new _MediaQueryRouteWidgetState();
  }
}

class _MediaQueryRouteWidgetState extends State<MediaQueryRouteWidget> {
  _MediaQueryRouteWidgetState();

  @override
  void initState() {
    print('initState');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    print('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('[XDEBUG] - FirstFirstRouteWidget is disposing~');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger.log(
        '${MediaQuery.of(context).padding.top} uniqueId=${widget.uniqueId}');
    Logger.log(
        '${MediaQuery.of(context).padding.bottom} uniqueId=${widget.uniqueId}');
    Logger.log(
        '${MediaQuery.of(context).size.width} uniqueId=${widget.uniqueId}');
    Logger.log(
        '${MediaQuery.of(context).size.height} uniqueId=${widget.uniqueId}');

    return Scaffold(
      appBar: AppBar(
        title: Text('media query demo'),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
          Widget>[
        Expanded(
            flex: 2,
            child: Container(
                margin: const EdgeInsets.all(24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('top: ${MediaQuery.of(context).padding.top}'),
                      Text('bottom: ${MediaQuery.of(context).padding.bottom}'),
                      Text('width: ${MediaQuery.of(context).size.width}'),
                      Text('height: ${MediaQuery.of(context).size.height}')
                    ]))),
        Expanded(
          flex: 1,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'Pop with Navigator',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),
                  onTap: () => Navigator.of(context)
                      .pop('I am Navigator from MediaQueryRouteWidget too!'),
                ),
                InkWell(
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.yellow,
                      child: Text(
                        'Pop with BoostNavigator',
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      )),
                  onTap: () => BoostNavigator.instance
                      .pop('I am BoostNavigator from MediaQueryRouteWidget!'),
                ),
              ]),
        ),
      ]),
    );
  }
}
