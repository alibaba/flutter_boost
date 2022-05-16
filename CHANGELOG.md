## NEXT
1. [Android] 去掉不必要的兜底方案，解决Native页面返回值丢失的问题

v3.0-release.2
1. 修复flutter首页打开A页面，打开B页面返回到首页后内存泄露问题
2. [bugfix] 1.解决异步导致的断言错误(#1583)；2.修改测试案例，解决测试页面被拦截的问题
3. [Android] 完善PlatformView测试案例： 1. 增加复杂的Native动画场景； 2. 支持intent打开测试页面，方便自动化测试；
4. 增加简单的WebView测试场景
5. 将拦截器内部实现修改为同步，避免时序相关问题

## v3.0-release.1
1.  [ios]增加platform view测试案例 (#1546)
2. [Android] 在Fragment的使用场景中，onHiddenChanged/setUserVisibleHint可能比onCreateView先调用 (#1456)
3. [featurePR]使FlutterBoost的FlutterBoostFragment#finishContainer方法在子类可以定制容器关闭逻辑 (#1565)
4. fix(Android):FlutterBoost开启FlutterBoostFragment页面导致状态栏颜色异常 (#1570)
5.  拦截器重构： (#1583)
6. 重命名example_new为example_new_for_ios

Breaking Change
1. 拦截器重构，具体见 https://github.com/alibaba/flutter_boost/pull/1583

## v3.0-preview.18
1. 修复hot restart导致的黑屏问题 (#1537)
2. feat: Android抛出popRoute代理回调 (#1531)
3. 将运行时异常修改为日志输出 (#1541)
4. BoostContainer增加backPressedHandler用于自定义返回键功能
5. 支持通过FlutterEngineProvider创建引擎
6. 优化example

## v3.0-preview.17
1. [Android]修复特定场景下activity泄漏的问题
2. [Android] 修复FlutterEngine空指针异常 (#1471)
3. [flutter] 提供带有缓存的widget组件 BoostCacheWidget,可以解决在push过程中导致页面rebuild的问题 (#1486)
4. [iOS] 修改 podspec xcconfig 为 pod_target_xcconfig ，避免修改宿主工程编译配置 (#1507)

## v3.0-preview.16
1. [Android] 修复特定场景下activity泄漏的问题 (#1444)
2. [Android] 修复Fragment特定使用场景下的崩溃问题 (#1450)
3. popUntil使用containers列表不能保证顺序性，在同步popRoute过程会导致出现containers的乱序。需要通过提前clone队列进行保证 (#1462)
4. [dart] 修复应用启动首次访问flutter页面白屏问题

## v3.0-preview.15
1. [ios]对外暴露flutter页面资源释放API(#1443)
2. [Android] 从Native页面切换回FlutterFragment时，恢复Dart视角的system chrome style，解决沉浸式状态栏显示问题

## v3.0-preview.14
1. [ios] 修复应用置后台后，通过外链接起应用进入Flutter页面,applicationState还处于inActive状态,渲染错误的问题 (#1442)

## v3.0-preview.13
1. [flutter] 修复在引擎启动完毕但是flutter侧还没有加载完毕的时候进行操作的函数调用的时序问题 (#1415)
2. [Android] 修复实现了onWillPop回调的Widget不能后退的问题 (#1411)

## v3.0-preview.12
1. [iOS] 将控制iOS手势的方法收口到BoostChannel作为通用方法，以及在container的show的监听中做手势的动态禁用和启用
2. [flutter] 更新example以及默认的appBuilder实现，传入builder参数，避免showDialog无法关闭dialog而是关闭页面的操作
3. [flutter] 修复路由在极端情况下顺序错误的问题

## v3.0-preview.11
1. [flutter] 让NavigatorExt接管pushNamed方法
2. [flutter] 增加tab模式的example，删除iOS端无用的生命周期，避免初始化阶段进行push，造成初始化情况下tab白屏问题
3. [iOS] 提前事件监听的注册时机，以及在删除的时候对block进行判空，避免crash

## v3.0-preview.10
1. [iOS] 提供引擎预热功能，避免第一次进入flutter页面短暂的白屏/黑屏，以及字体大小跳动的情况
2. [iOS] 单VC，多flutterPage下，动态控制容器手势侧滑，内部有多page的时候，侧滑将走flutter内部侧滑逻辑，避免多page下侧滑直接带走整个容器的情况
3. [dart] 更新example代码，表明如何在单容器内跳转拥有跳转动画（比如iOS的push效果）

## v3.0-preview.9
1.  [Android] 解决切后台场景下Android Q生命周期回调异常导致透明弹窗背景不正确问题 (#1288)
2.  [Android] 增加引擎释放接口 (#1291)

## v3.0-preview.8
1. [Android] 解决特定场景下半透明弹窗背景黑/白屏、传参丢失、请求权限失败，以及image_picker插件不可用等问题
2. [Android] 修复FlutterBoostActivity和FlutterBoostFragment接收不到请求权限结果的bug
3. 解决 iOS dismissViewController completion 异步回调事件不完整的问题
4. [Android] 适配页面透明参数，增加测试案例 (#1265)
5. [Android] fix #1264 修复由于这条提交 #1250 导致FlutterboosrActivity 接收不到onActivityResult 回调结果 的bug

## v3.0-preview.7
1. [Android] 解决前一个页面destroy时导致当前页面的PlatformViewsChannel断开的问题 (#1250)
2. Hfix #1229 修复example中从Flutter页面推后台再回前天，栈顶页面是Native的页面的问题
3. 修复单引擎多VC下问题：1.updateViewportMetrics在键盘唤起时被多个VC调用 2.Tab初始化场景下导致的Crash
4. 修复 FlutterBoostFragment跳转新的FlutterBoostFragment，返回上一个FlutterFragment后不响应点击事件


## v3.0-preview.6
1.[iOS] 修复iOS打开Flutter页面再关闭不走dispose逻辑问题
2.[Android] 解决setSystemUIOverlayStyle不生效的问题
3.[Android] 默认开启状态恢复功能

## v3.0-preview.5
1. Native侧代码重构
  a.uniqueId的创建方式与Dart侧保持一致
  b.去掉ContainerShadowNode抽象代码
  c.去掉Flutter容器创建时不必要的engineId参数
2. open方法实现自定义配置参数，增强拓展性
3. [双端一致性] Android端抽象出FlutterContainerManager的概念
4. 原生 onActivityResult 回传参数到Flutter 重构
5. 增加线程判断，确保 engine run 在主线程，可以让业务在子线程 setup boost
6. [android] 修复Tab场景下多个Fragment使用了同一个FlutterView，以及解决Fragment第一次显示时不能正确切换surface的问题
7. FlutterBoostFragment优化
8. [android]当FlutterFragment的onCreateView回调时，暂不attache到引擎
9. iOS侧透明能力提供
10. 增加example3.0
11. 修复FlutterFragment退出后，下面的容器页面出现假死问题
12. 为了业务能更方便地从2.0升级到3.0，为remove接口提供argument可选参数
13. 【dart,Android,iOS】均提供自定义事件发送机制，事件均可双向传递
14. [Android] 允许业务复用提前创建的引擎
15. FIXED:HeroController.didPush assert(navigator != null) 报空异常
16. 确保onPageShow事件能够在页面创建的时候调用到
17. PageVisibility不再提供create和destroy方法，另外onPageCreate和onPageDestroy改名为onPagePush和onPagePop
18. FIXED:同一个容器提供多个FlutterView,业务层通过remove(uniqueId)，指定id移除非首个flutterview会失效
19. Boost接管handleAppLifecycleStateChanged，让Flutter生命周期与应用前后台对齐
20. BoostNavigator添加pushReplacement方法，同时修复pop和findContainerById的逻辑
21. 过滤内部路由RouteSettings.name为null的路由事件，如对话框路等非页面路由事件，否则影响正常页面生命周期
22. [双端一致性] iOS端FBFlutterContainerManager与Android统一，FLutterBoostPlugin生命周期相关逻辑统一
23. 调整 Flutter Engine 初始化流程，避免使用异步方式产生插件注册时序问题
24. 支持通过原生Navigator关闭容器页面
25. 重构内部路由Pop时的结果回传逻辑
26. [Android] 修复特定场景下（例如，ViewPager2）onPageHide事件未触发的问题

Breaking Change
1.为了后续Delegate的可扩展性，增加一个FlutterBoostRouteOptions的概念用于封装参数，Delegate的push和pop的参数传递都依赖这个对象

具体见
https://github.com/alibaba/flutter_boost/commit/14a3be59f97cad24bdba8663a79f3d17359641df
https://github.com/alibaba/flutter_boost/commit/c085258e09b79dc6c3660d384409c50e2497ef4b
https://github.com/alibaba/flutter_boost/commit/ce48530ad7114703d3a8dfb02e4e32543c9aaa10
https://github.com/alibaba/flutter_boost/commit/47676230f21472c28791660ec93515f41d4f6c2f

2. BoostNavigator提供的pop接口改为异步
https://github.com/alibaba/flutter_boost/commit/d2d1fdc100dee34085b76d597194b93309e0cd0f

3. PageVisibility不再提供create和destroy方法，另外onPageCreate和onPageDestroy改名为onPagePush和onPagePop
原先写在onPageCreate和onPageDestroy的代码，写到initState和dispose中
https://github.com/alibaba/flutter_boost/commit/e2f15b234260ede810e943c4f8248fd07fce6414

4. Boost接管handleAppLifecycleStateChanged，让容器数量决定Flutter的resume和pause状态
请移步接入文档，看BoostFlutterBinding的使用方式
https://github.com/alibaba/flutter_boost/commit/173c910ff8ed971eacfa1a263745921ae5cd5689
https://github.com/alibaba/flutter_boost/commit/abc2598f48dbcbeabf48057eec6d7737b0e21989


## v3.0-beta.11
1. 修复透明页面背景是前一个Container的问题
2. 重写BoostContainerWidget判等方法，避免框架层对已存在页面进行rebuild

## v3.0-beta.10
1. BoostContainer重构，修复容器内打开和关闭页面时界面不刷新问题

## v3.0-beta.9
1. 添加前台后台的回调接口
2. 增加从原生open flutter页面时，open操作完成后的回调能力

Breaking Change:
 [iOS] 增加从原生open flutter页面时，open操作完成后的回调能力 : https://github.com/alibaba/flutter_boost/commit/7f55728955b0afcdbaba5a17543e9dbdf1c24e65
由于一些业务方需要知道页面动画是否完成，需要获取present的completion回调，
因此将
- (void) pushFlutterRoute:(NSString *) pageName uniqueId:(NSString *)uniqueId arguments:(NSDictionary *) arguments
改为
- (void) pushFlutterRoute:(NSString *) pageName uniqueId:(NSString *)uniqueId arguments:(NSDictionary *) arguments completion:(void(^)(BOOL)) completion;

## v3.0-beta.8
1. 提供flutter_boost.dart作为对外接口
2. BoostNavigator相关API和实现的修改
3. 解决_pendingResult可能没有完成的问题
4. 新增前置拦截器能力
5. 解决在push和pop的时候，页面栈所有页面重复build的问题
6. 使用effective_dart包提供的linter规则文件

## v3.0-beta.7
1. 生命周期实现调整
2. 解决Android端特定场景下生命周期事件重复的问题
3. 添加自定义启动参数设置入口
4. 新增页面回退传参能力

Breaking Change:
page create and destroy event adjustment : https://github.com/alibaba/flutter_boost/commit/62c88805bf08606805e13254170691d2bc00bd4a
由于生命周期实现的改变，PageVisiblityObserver的onPageShow和onPageHide方法中，不再包含参数isForegroundEvent以及isBackgroundEvent

## 1.12.13+2
  Fixed bugs

## 1.12.13
  Supported Flutter sdk 1.12.13

## 1.9.1+2

  Rename the version number and start supporting androidx by default, Based on the flutter 1.9.1 - hotfixs。
  fixed bugs

## 0.1.66

  Fixed bugs

## 0.1.64

  Fixed bugs

## 0.1.63

  android:
  Fixed bugs

  iOS:
  no change

## 0.1.61

  android:
  Fixed bugs

  iOS:
  no change

## 0.1.60

A better implementation to support Flutter v1.9.1+hotfixes

Change the content
android:

1. based on the v1.9.1+hotfixes branch of flutter
2. Solve major bugs, such as page parameter passing
3. Support platformview
4. Support androidx branch :feature/flutter_1.9_androidx_upgrade
5. Resolve memory leaks
6. Rewrite part of the code
7. API changes
8. Improved demo and added many demo cases

ios:

1.based on the v1.9.1+hotfixes branch of flutter
2.bugfixed



## 0.1.5
The main changes are as following:
1. The new version do the page jump (URL route) based on the inherited FlutterViewController or Activity. The jump procedure will create new instance of FlutterView, while the old version just reuse the underlying FlutterView
2. Avoiding keeping and reusing the FlutterView, there is no screenshot and complex attach&detach logical any more. As a result, memory is saved and black or white-screen issue occured in old version all are solved.
3. This version also solved the app life cycle observation issue, we recommend you to use ContainerLifeCycle observer to listen the app enter background or foreground notification instead of WidgetBinding.
4. We did some code refactoring, the main logic became more straightforward.

## 0.0.1

* TODO: Describe initial release.


### API changes
From the point of API changes, we did some refactoring as following:
#### iOS API changes
1. FlutterBoostPlugin's startFlutterWithPlatform function change its parameter from FlutterViewController to Engine
2.
**Before change**
```objectivec
FlutterBoostPlugin
- (void)startFlutterWithPlatform:(id<FLBPlatform>)platform onStart:(void (^)(FlutterViewController *))callback;
```

**After change**

```objectivec
FlutterBoostPlugin2
- (void)startFlutterWithPlatform:(id<FLB2Platform>)platform
                         onStart:(void (^)(id<FlutterBinaryMessenger,
                                           FlutterTextureRegistry,
                                           FlutterPluginRegistry> engine))callback;

```

2. FLBPlatform protocol removed flutterCanPop、accessibilityEnable and added entryForDart
**Before change:**
```objectivec
@protocol FLBPlatform <NSObject>
@optional
//Whether to enable accessibility support. Default value is Yes.
- (BOOL)accessibilityEnable;
// flutter模块是否还可以pop
- (void)flutterCanPop:(BOOL)canpop;
@required
- (void)openPage:(NSString *)name
          params:(NSDictionary *)params
        animated:(BOOL)animated
      completion:(void (^)(BOOL finished))completion;
- (void)closePage:(NSString *)uid
         animated:(BOOL)animated
           params:(NSDictionary *)params
       completion:(void (^)(BOOL finished))completion;
@end
```
**After change:**
```objectivec
@protocol FLB2Platform <NSObject>
@optional
- (NSString *)entryForDart;

@required
- (void)open:(NSString *)url
   urlParams:(NSDictionary *)urlParams
        exts:(NSDictionary *)exts
      completion:(void (^)(BOOL finished))completion;
- (void)close:(NSString *)uid
       result:(NSDictionary *)result
         exts:(NSDictionary *)exts
   completion:(void (^)(BOOL finished))completion;
@end
```

#### Android API changes
Android mainly changed the IPlatform interface and its implementation.
It removed following APIs:
```java
Activity getMainActivity();
boolean startActivity(Context context,String url,int requestCode);
Map getSettings();
```

And added following APIs:

```java
void registerPlugins(PluginRegistry registry) 方法
void openContainer(Context context,String url,Map<String,Object> urlParams,int requestCode,Map<String,Object> exts);
void closeContainer(IContainerRecord record, Map<String,Object> result, Map<String,Object> exts);
IFlutterEngineProvider engineProvider();
int whenEngineStart();
```
