### 1. 在FlutterBoost下如何管理Flutter页面的生命周期？原生的Flutter的AppLifecycleState事件会不一致，比如ViewAppear会导致app状态suspending或者paused。混合栈怎么处理？
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
### 2. 如何判断flutter的widget或者container是当前可见的？
回答：有个api可以判断当前页面是否可见：
```dart
bool isTopContainer = FlutterBoost.BoostContainer.of(context).onstage
```
传入你widget的context，就能判断你的widget是否是可见的
基于这个API，可以判断你的widget是否可见，从而避免接收一些重复的生命周期消息。参考这个issue:https://github.com/alibaba/flutter_boost/issues/498

### 3. 您好，我想请教一下flutter_boost有关的问题：ABC三个都是flutter页面，从 A页面 -> B页面 -> C页面，当打开C页面时希望自动关掉B页面，当从C页面返回时直接返回A页面，可有什么方法？
回答：你只需要操作Native层的UINavigationController里的vc数组就可以了。就如同平时你操作普通的UIViewController一样。因为FlutterBoost对Native层的FlutterViewController和Dart层的flutter page的生命周期管理是一致的，当FlutterViewController被销毁，其在dart层管理的flutter page也会自动被销毁。

### 4. 在ios中voice over打开，demo在点击交互会crash;
回答：无障碍模式下目前Flutter Engine有bug，已经提交issue和PR给flutter啦。请参考这个issue：https://github.com/alibaba/flutter_boost/issues/488及其分析。提交给flutter的PR见这里：https://github.com/flutter/engine/pull/14155

### 5. 在ios模拟器下运行最新的flutter boost会闪退
回答：如上面第4条所说的，最新的flutter engine在voice over下有bug，会导致crash。因为模拟器下flutter默认会将voice over模式打开，所以其实就是辅助模式，这回触发上面的bug：“在ios中voice over打开，demo在点击交互会crash”。
可参考Engine的代码注释：
```c++
#if TARGET_OS_SIMULATOR
  // There doesn't appear to be any way to determine whether the accessibility
  // inspector is enabled on the simulator. We conservatively always turn on the
  // accessibility bridge in the simulator, but never assistive technology.
  platformView->SetSemanticsEnabled(true);
  platformView->SetAccessibilityFeatures(flags);
```

### 6. 似乎官方已经提供了混合栈的功能，参考这里：https://flutter.dev/docs/development/add-to-app; FlutterBoost是否有存在的必要？
回答：官方的解决方案仅仅是在native侧对FlutterViewController和Flutterengine进行解耦，如此可以一个FlutterEngine切换不同的FlutterViewController或者Activity进行渲染。但其并未解决Native和Flutter页面混合的问题，无法保证两侧的页面生命周期一致。即使是Flutter官方针对这个问题也是建议使用FlutterBoost。
其差别主要有：

|*|FlutterBoost2.0	|Flutter官方方案	|其他框架|
|----|----|----|----|
|是否支持混合页面之间随意跳转	|Y	|N	|Y|
|一致的页面生命周期管理(多Flutter页面)	|Y	|N	|?|
|是否支持页面间数据传递(回传等)	|Y	|N	|N|
|是否支持测滑手势	|Y	|Y	|Y|
|是否支持跨页的hero动画	|Y	|Y	|N|
|内存等资源占用是否可控	|Y	|Y	|Y|
|是否提供一致的页面route方案	|Y	|Y	|N|
|iOS和Android能力及接口是否一致	|Y	|N	|N|
|框架是否稳定，支持Flutter1.9	|Y	|N	|?|
|是否已经支持到View级别混合	|N	|N	|N|

同时FlutterBoost也提供了一次性创建混合工程的命令：flutterboot。代码参考：https://github.com/alibaba-flutter/flutter-boot

### 7. 如果我需要通过FlutterViewController再弹出一个新的但frame比较小的FlutterViewController，应该怎么实现？
回答：如果不加处理会遇到window大小变化的问题，但可以解决。具体可以参考这个issue：https://github.com/alibaba/flutter_boost/issues/435

### 8. Flutter ViewController如何设置横屏
VC设置横屏依赖于NavigationController或者rootVC。可以通过一下方式来设置：
1. dart层的SystemChrome.setPreferredOrientations函数并非直接设置转向，而是设置页面优先使用的转向(preferred)
2. app的转向控制除了info.plist的设置外，主要受UIWindow.rootViewController控制。大概过程是这样的：硬件检测到转向，就会调用UIWindow的转向函数，然后调用其rootViewController的shouldAutorotate判断是否需要自动转，然后取supportedInterfaceOrientations和info.plist中设置的交集来判断可否转
3. 对于UIViewController中的转向，也只在rootviewcontroller中才有效

举例如下，实现步骤可以这样：
1. 重写NavigationController：
```objc
-(BOOL)shouldAutorotate
{
//    id currentViewController = self.topViewController;
//
//
//     if ([currentViewController isKindOfClass:[FlutterViewController class]])
//        return [currentViewController shouldAutorotate];

    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    id currentViewController = self.topViewController;
    if ([currentViewController isKindOfClass:[FlutterViewController class]]){
        NSLog(@"[XDEBUG]----fvc supported:%ld\n",[currentViewController supportedInterfaceOrientations]);
         return [currentViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAll;
}
```
2. 改dart层：因为SystemChrome.setPreferredOrientations的设置是全局的，但混合栈是多页面，所以在main函数中设置，后面在新建一个FlutterViewController时会被冲掉。为了解决这个问题，需要在每个dart页面的build处都加上这语句来设置每个页面能支持哪些转向类型

### 9. FlutterBoost for flutter1.12出现和surface相关的crash。可以参考这个issue：https://github.com/flutter/flutter/issues/52455
可能flutter engine的bug引起
