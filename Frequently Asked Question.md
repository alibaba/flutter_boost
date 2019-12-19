### 在FlutterBoost下如何管理Flutter页面的生命周期？原生的Flutter的AppLifecycleState事件会不一致，比如ViewAppear会导致app状态suspending或者paused。混合栈怎么处理？
回答：在混合栈下，页面事件基于以下自定义的事件：
```dart
enum ContainerLifeCycle {
  Init,
  Appear,
  WillDisappear,
  Disappear,
  Destroy,
  Background,
  Foreground
}
```
对于页面事件重复，请参考下面的FAQ。
### 如何判断flutter的widget或者container是当前可见的？
回答：有个api可以判断当前页面是否可见：
```dart
bool isTopContainer = FlutterBoost.BoostContainer.of(context).onstage
```
传入你widget的context，就能判断你的widget是否是可见的
基于这个API，可以判断你的widget是否可见，从而避免接收一些重复的生命周期消息。参考这个issue:https://github.com/alibaba/flutter_boost/issues/498

### 您好，我想请教一下flutter_boost有关的问题：ABC三个都是flutter页面，从 A页面 -> B页面 -> C页面，当打开C页面时希望自动关掉B页面，当从C页面返回时直接返回A页面，可有什么方法？
回答：你只需要操作Native层的UINavigationController里的vc数组就可以了。就如同平时你操作普通的UIViewController一样。因为FlutterBoost对Native层的FlutterViewController和Dart层的flutter page的生命周期管理是一致的，当FlutterViewController被销毁，其在dart层管理的flutter page也会自动被销毁。

### 在ios中voice over打开，demo在点击交互会crash
回答：无障碍模式下目前Flutter Engine有bug，已经提交issue和PR给flutter啦。请参考这个issue：https://github.com/alibaba/flutter_boost/issues/488及其分析。提交给flutter的PR见这里：https://github.com/flutter/engine/pull/14155

### 似乎官方已经提供了混合栈的功能，参考这里：https://flutter.dev/docs/development/add-to-app; FlutterBoost是否有存在的必要？
回答：官方的解决方案仅仅是在native侧对FlutterViewController和Flutterengine进行解耦，如此可以一个FlutterEngine切换不同的FlutterViewController或者Activity进行渲染。但其并未解决Native和Flutter页面混合的问题，无法保证两侧的页面生命周期一致。即使是Flutter官方针对这个问题也是建议使用FlutterBoost。
其差别主要有：

|*|FlutterBoost1.5	|Flutter官方方案	|其他框架|
|----|----|----|----|
|是否支持混合页面之间随意跳转	|Y	|N	|Y|
|一致的页面生命周期管理(多Flutter页面)	|Y	|N	|?|
|是否支持页面间数据传递(回传等)	|Y	|N	|N|
|是否支持测滑手势	|Y	|Y	|Y|
|是否支持跨页的hero动画	|N	|Y	|N|
|内存等资源占用是否可控	|Y	|Y	|Y|
|是否提供一致的页面route方案	|Y	|Y	|N|
|iOS和Android能力及接口是否一致	|Y	|N	|N|
|框架是否稳定，支持Flutter1.9	|Y	|N	|?|
|是否已经支持到View级别混合	|N	|N	|N|

同时FlutterBoost也提供了一次性创建混合工程的命令：flutterboot。代码参考：https://github.com/alibaba-flutter/flutter-boot
