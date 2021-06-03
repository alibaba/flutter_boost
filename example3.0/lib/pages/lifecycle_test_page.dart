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
    print("AppLifecycleObserver - onPageShow");
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

    ///请在didChangeDependencies中注册而不是initState中
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ///注册监听器
    PageVisibilityBinding.instance.addObserver(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    ///移除监听器
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('simple lifecycle test page', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            CupertinoButton.filled(
                child: Text('push simple page'),
                onPressed: () {
                  BoostNavigator.instance
                      .push("simplePage", withContainer: true);
                }),
          ],
        ),
      ),
    );
  }
}
