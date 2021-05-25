import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_boost/flutter_boost.dart';

///全局生命周期监听示例
class AppLifecycleObserver with GlobalPageVisibilityObserver {
  @override
  void onBackground(Route route) {
    super.onBackground(route);
    print("AppLifecycleObserver - onBackground");
  }

  @override
  void onForeground(Route route) {
    super.onForeground(route);
    print("AppLifecycleObserver - onForground");
  }

  @override
  void onPageCreate(Route route) {
    super.onPageCreate(route);
    print("AppLifecycleObserver - onPageCreate");
  }

  @override
  void onPageDestroy(Route route) {
    super.onPageDestroy(route);
    print("AppLifecycleObserver - onPageDestroy");
  }

  @override
  void onPageHide(Route route) {
    super.onPageHide(route);
    print("AppLifecycleObserver - onPageHide");
  }

  @override
  void onPageShow(Route route) {
    super.onPageShow(route);
    print("AppLifecycleObserver - AppLifecycleObserver");
  }
}

///单个生命周期示例
class LifecycleTestPage extends StatefulWidget {
  const LifecycleTestPage({Key key}) : super(key: key);

  @override
  _LifecycleTestPageState createState() => _LifecycleTestPageState();
}

class _LifecycleTestPageState extends State<LifecycleTestPage>
    with PageVisibilityObserver {
  @override
  void onBackground() {
    super.onBackground();
    print("LifecycleTestPage - onBackground");
  }

  @override
  void onForeground() {
    super.onForeground();
    print("LifecycleTestPage - onForeground");
  }

  @override
  void onPageCreate() {
    super.onPageCreate();
    print("LifecycleTestPage - onPageCreate");
  }

  @override
  void onPageDestroy() {
    super.onPageDestroy();
    print("LifecycleTestPage - onPageDestroy");
  }

  @override
  void onPageHide() {
    super.onPageHide();
    print("LifecycleTestPage - onPageHide");
  }

  @override
  void onPageShow() {
    super.onPageShow();
    print("LifecycleTestPage - onPageShow");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      PageVisibilityBinding.instance.addObserver(this, ModalRoute.of(context));
    });
  }

  @override
  void dispose() {
    PageVisibilityBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Lifecycle page'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            BoostNavigator.instance.pop();
          },
        ),
      ),
      body: Center(
        child: Text('simple lifecycle test page',style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
