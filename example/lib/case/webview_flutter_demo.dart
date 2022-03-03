import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  bool withContainer = true;
  bool visible = true;
  final url = 'https://flutter.dev';

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('WebView Example'),
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
            body: Container(
                child: Column(children: <Widget>[
              Container(
                margin: const EdgeInsets.all(10.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter something...'),
                ),
              ),
              InkWell(
                child: Container(
                    margin: const EdgeInsets.all(10.0),
                    color: Colors.yellow,
                    child: Text(
                      'Open flutter page',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("flutterPage", withContainer: withContainer),
              ),
              InkWell(
                child: Container(
                    margin: const EdgeInsets.all(10.0),
                    color: Colors.yellow,
                    child: Text(
                      'Open another webview',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("webview", withContainer: withContainer),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 1080,
                      height: 50,
                      margin: const EdgeInsets.all(10.0),
                      child: MaterialButton(
                        color: Colors.blue,
                        child: Text(
                          'Click me to change something ~~',
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            visible = !visible;
                          });
                        },
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        if (visible)
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.blue, width: 5.0)),
                            width: 400,
                            height: 300,
                            margin: const EdgeInsets.all(10.0),
                            child: WebView(
                              initialUrl: url,
                            ),
                          ),
                        Opacity(
                          opacity: visible ? 1.0 : 0.5,
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.red, width: 5.0)),
                            width: 200,
                            height: 200,
                            margin: const EdgeInsets.all(10.0),
                            child: WebView(
                              initialUrl: url,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.blue, width: 5.0)),
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.all(10.0),
                          child: WebView(
                            initialUrl: url,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]))));
  }
}
