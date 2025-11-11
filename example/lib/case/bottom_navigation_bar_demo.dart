import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({Key? key}) : super(key: key);

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  final GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  Route<dynamic> normal(Widget widget, RouteSettings settings) =>
      MaterialPageRoute<Widget>(
        settings: settings,
        builder: (BuildContext context) => widget,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test webview")),
      body: Navigator(
        key: globalKey,
        initialRoute: "test1",
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case "test1":
              return normal(const Test1(), settings);
            case "test2":
              return normal(const Test2(), settings);
            case "test3":
              return normal(const Test3(), settings);
          }
          return null;
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (index) {
          switch (index) {
            case 0:
              globalKey.currentState?.pushNamed("test1");
              break;
            case 1:
              globalKey.currentState?.pushNamed("test2");
              break;
            case 2:
              globalKey.currentState?.pushNamed("test3");
              break;
          }
          setState(() => this.index = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Music'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
        ],
      ),
    );
  }
}

class Test1 extends StatefulWidget {
  const Test1({Key? key}) : super(key: key);

  @override
  State<Test1> createState() => _Test1State();
}

class _Test1State extends State<Test1> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}

class Test2 extends StatelessWidget {
  const Test2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }
}

class Test3 extends StatelessWidget {
  const Test3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
    );
  }
}
