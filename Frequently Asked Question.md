# 如何判断flutter的widget或者container是当前可见的？
回答：有个api可以判断当前页面是否可见：
```dart
bool isTopContainer = FlutterBoost.BoostContainer.of(context).onstage
```
传入你widget的context，就能判断你的widget是否是可见的
基于这个API，可以判断你的widget是否可见，从而避免接收一些重复的生命周期消息。参考这个issue:https://github.com/alibaba/flutter_boost/issues/498

# 您好，我想请教一下flutter_boost有关的问题：ABC三个都是flutter页面，从 A页面 -> B页面 -> C页面，当打开C页面时希望自动关掉B页面，当从C页面返回时直接返回A页面，可有什么方法？
回答：你只需要操作Native层的UINavigationController里的vc数组就可以了。就如同平时你操作普通的UIViewController一样。因为FlutterBoost对Native层的FlutterViewController和Dart层的flutter page的生命周期管理是一致的，当FlutterViewController被销毁，其在dart层管理的flutter page也会自动被销毁。

# 在ios中voice over打开，demo在点击交互会crash
回答：无障碍模式下目前Flutter Engine有bug，已经提交issue和PR给flutter啦。请参考这个issue：https://github.com/alibaba/flutter_boost/issues/488及其分析。提交给flutter的PR见这里：https://github.com/flutter/engine/pull/14155