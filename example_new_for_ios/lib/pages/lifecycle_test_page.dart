import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_boost/flutter_boost.dart';

///全局生命周期监听示例
class AppLifecycleObserver with GlobalPageVisibilityObserver {
  @override
  void onBackground(Route route) {
    super.onBackground(route);
    Logger.log("AppLifecycleObserver - ${route.settings.name} - onBackground");
  }

  @override
  void onForeground(Route route) {
    super.onForeground(route);
    Logger.log("AppLifecycleObserver ${route.settings.name} - onForground");
  }

  @override
  void onPagePush(Route route) {
    super.onPagePush(route);
    Logger.log("AppLifecycleObserver - ${route.settings.name}- onPagePush");
  }

  @override
  void onPagePop(Route route) {
    super.onPagePop(route);
    Logger.log("AppLifecycleObserver - ${route.settings.name}- onPagePop");
  }

  @override
  void onPageHide(Route route) {
    super.onPageHide(route);
    Logger.log("AppLifecycleObserver - ${route.settings.name}- onPageHide");
  }

  @override
  void onPageShow(Route route) {
    super.onPageShow(route);
    Logger.log("AppLifecycleObserver - ${route.settings.name}- onPageShow");
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
    Logger.log("LifecycleTestPage - onBackground");
  }

  @override
  void onForeground() {
    super.onForeground();
    Logger.log("LifecycleTestPage - onForeground");
  }

  @override
  void onPageHide() {
    super.onPageHide();
    Logger.log("LifecycleTestPage - onPageHide");
  }

  @override
  void onPageShow() {
    super.onPageShow();
    Logger.log("LifecycleTestPage - onPageShow");
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
        middle: const Text('Lifecycle page'),
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
            const Text('simple lifecycle test page',
                style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            CupertinoButton.filled(
                child: const Text('push simple page'),
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
