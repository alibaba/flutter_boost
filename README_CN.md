<p align="center">
  <img src="flutter_boost.png">
</p>


# Release Note

v3.0-beta.1

1.flutter sdk升级不需要升级boost
2.android不需要区分androidx 和support
3.简化架构
4.简化接口设计
5.双端设计统一
6.解决了top issue

# FlutterBoost

新一代Flutter-Native混合解决方案。 FlutterBoost是一个Flutter插件，它可以轻松地为现有原生应用程序提供Flutter混合集成方案。FlutterBoost的理念是将Flutter像Webview那样来使用。在现有应用程序中同时管理Native页面和Flutter页面并非易事。 FlutterBoost帮你处理页面的映射和跳转，你只需关心页面的名字和参数即可（通常可以是URL）。


# 前置条件

1.在继续之前，您需要将Flutter集成到你现有的项目中。
2.boost3.0版本支持的flutter sdk 版本为 >= 1.22


# 安装

## 在Flutter项目中添加依赖项。

打开pubspec.yaml并将以下行添加到依赖项：

androidx branch

```json
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: 'v3.0-hotfixes'
```


# boost集成
## dart测接入
### 1. 初始化：

```dart
void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
   static Map<String, FlutterBoostRouteFactory>
	   routerMap = {
    '/': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___)
          => Container());
    },
    'embedded': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) =>
          EmbeddedFirstRouteWidget());
    },
    'presentFlutterPage': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) =>
          FlutterRouteWidget(
                params: settings.arguments,
                uniqueId: uniqueId,
              ));
    }};
   Route<dynamic> routeFactory(RouteSettings settings, String uniqueId) {
    FlutterBoostRouteFactory func =routerMap[settings.name];
    if (func == null) {
      return null;
    }
    return func(settings, uniqueId);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(
      routeFactory
    );
  }
  ```
### 2.Boost生命周期监听：
```dart
class SimpleWidget extends StatefulWidget {
  final Map params;
  final String messages;
  final String uniqueId;

  const SimpleWidget(this.uniqueId, this.params, this.messages);

  @override
  _SimpleWidgetState createState() => _SimpleWidgetState();
}

class _SimpleWidgetState extends State<SimpleWidget>
    with PageVisibilityObserver {
  static const String _kTag = 'xlog';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('$_kTag#didChangeDependencies, ${widget.uniqueId}, $this');

  }

  @override
  void initState() {
    super.initState();
   PageVisibilityBinding.instance.addObserver(this, ModalRoute.of(context));
   print('$_kTag#initState, ${widget.uniqueId}, $this');
  }

  @override
  void dispose() {
    PageVisibilityBinding.instance.removeObserver(this);
    print('$_kTag#dispose, ${widget.uniqueId}, $this');
    super.dispose();
  }

  @override
  void onForeground() {
    print('$_kTag#onForeground, ${widget.uniqueId}, $this');
  }

  @override
  void onBackground() {
    print('$_kTag#onBackground, ${widget.uniqueId}, $this');
  }

  @override
  void onAppear(ChangeReason reason) {
    print('$_kTag#onAppear, ${widget.uniqueId}, $reason, $this');
  }

  void onDisappear(ChangeReason reason) {
    print('$_kTag#onDisappear, ${widget.uniqueId}, $reason, $this');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tab_example'),
      ),
      body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 80.0),
                child: Text(
                  widget.messages,
                  style: TextStyle(fontSize: 28.0, color: Colors.blue),
                ),
                alignment: AlignmentDirectional.center,
              ),
              Container(
                margin: const EdgeInsets.only(top: 32.0),
                child: Text(
                  widget.uniqueId,
                  style: TextStyle(fontSize: 22.0, color: Colors.red),
                ),
                alignment: AlignmentDirectional.center,
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(30.0),
                    color: Colors.yellow,
                    child: Text(
                      'open flutter page',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.of().push("flutterPage",
                    arguments: <String, String>{'from': widget.uniqueId}),
              )
              Container(
                height: 300,
                width: 200,
                child: Text(
                  '',
                  style: TextStyle(fontSize: 22.0, color: Colors.black),
                ),
              )
            ],
          ))),
    );
  }
}
```
### 页面跳转
打开页面
```java
 String result = await BoostNavigator.of()
                        .push("flutterPage", withContainer: true);
```
关闭页面
```java
BoostNavigator.of().pop('I am result for popping.'),
```
## Android 测接入
### 1.Application 初始化
```java
public class MyApplication extends FlutterApplication {


    @Override
    public void onCreate() {
        super.onCreate();

        FlutterBoost.instance().setup(this, new FlutterBoostDelegate() {

            @Override
            public void pushNativeRoute(String pageName, HashMap<String, String> arguments) {
                Intent intent = new Intent(FlutterBoost.instance().currentActivity(), NativePageActivity.class);
                FlutterBoost.instance().currentActivity().startActivity(intent);
            }

            @Override
            public void pushFlutterRoute(String pageName, HashMap<String, String> arguments) {
                Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(FlutterBoostActivity.class, FlutterBoost.ENGINE_ID)
                        .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
                        .destroyEngineWithActivity(false)
                        .url(pageName)
                        .urlParams(arguments)
                        .build(FlutterBoost.instance().currentActivity());
                FlutterBoost.instance().currentActivity().startActivity(intent);
            }

        },engine->{
            engine.getPlugins();
        } );


    }
}

```

### 2.AndroidManifest.xml
flutterEmbedding=2

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          xmlns:tools="http://schemas.android.com/tools"
          package="com.idlefish.flutterboost.example">

    <application
        android:name="com.idlefish.flutterboost.example.MyApplication"
        android:label="flutter_boost_example"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name="com.idlefish.flutterboost.containers.FlutterBoostActivity"
            android:theme="@style/Theme.AppCompat"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize" >
            <meta-data android:name="io.flutter.embedding.android.SplashScreenDrawable" android:resource="@drawable/launch_background"/>

        </activity>
        <meta-data android:name="flutterEmbedding"
                   android:value="2">
        </meta-data>
    </application>
</manifest>
```
### 3.native 打开关闭Flutter页面
```java
FlutterBoost.instance().open("flutterPage",params);

 FlutterBoost.instance().close("uniqueId");

```
## IOS测接入

### 1.AppDelegate
```objc
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    MyFlutterBoostDelegate* delegate=[[MyFlutterBoostDelegate alloc ] init];

    [[FlutterBoost instance] setup:application delegate:delegate callback:^(FlutterEngine *engine) {

    } ];

    return YES;
}
@end

```

### FlutterBoostDelegate
```objc
@interface MyFlutterBoostDelegate : NSObject<FlutterBoostDelegate>
@property (nonatomic,strong) UINavigationController *navigationController;
@end

@implementation MyFlutterBoostDelegate

- (void) pushNativeRoute:(FBCommonParams*) params{
    BOOL animated = [params.arguments[@"animated"] boolValue];
    BOOL present= [params.arguments[@"present"] boolValue];
    UIViewControllerDemo *nvc = [[UIViewControllerDemo alloc] initWithNibName:@"UIViewControllerDemo" bundle:[NSBundle mainBundle]];
    if(present){
        [self.navigationController presentViewController:nvc animated:animated completion:^{
        }];
    }else{
        [self.navigationController pushViewController:nvc animated:animated];
    }
}

- (void) pushFlutterRoute:(FBCommonParams*)params {

    FlutterEngine* engine =  [[FlutterBoost instance ] getEngine];
    engine.viewController = nil;

    FBFlutterViewContainer *vc = FBFlutterViewContainer.new ;

    [vc setName:params.pageName params:params.arguments];

    BOOL animated = [params.arguments[@"animated"] boolValue];
    BOOL present= [params.arguments[@"present"] boolValue];
    if(present){
        [self.navigationController presentViewController:vc animated:animated completion:^{
        }];
    }else{
        [self.navigationController pushViewController:vc animated:animated];

    }
}

- (void) popRoute:(FBCommonParams*)params
         result:(NSDictionary *)result{

    FBFlutterViewContainer *vc = (id)self.navigationController.presentedViewController;

    if([vc isKindOfClass:FBFlutterViewContainer.class] && [vc.uniqueIDString isEqual: params.uniqueId]){
        [vc dismissViewControllerAnimated:YES completion:^{}];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }

}

@end

```
### native 打开flutter 页面

```objc
[[FlutterBoost instance] open:@"flutterPage" arguments:@{@"animated":@(YES)}  ];

[[FlutterBoost instance] open:@"secondStateful" arguments:@{@"present":@(YES)}];
```


# FAQ

请阅读这篇文章:
<a href="Frequently Asked Question.md">FAQ</a>


# 许可证
该项目根据MIT许可证授权 - 有关详细信息，请参阅[LICENSE.md]（LICENSE.md）文件
<a name="Acknowledgments"> </a>



## 关于我们
阿里巴巴-闲鱼技术是国内最早也是最大规模线上运行Flutter的团队。

我们在公众号中为你精选了Flutter独家干货，全面而深入。

内容包括：Flutter的接入、规模化应用、引擎探秘、工程体系、创新技术等教程和开源信息。

**架构／服务端／客户端／前端／算法／质量工程师 在公众号中投递简历，名额不限哦**

欢迎来闲鱼做一个好奇、幸福、有影响力的程序员，简历投递：tino.wjf@alibaba-inc.com

订阅地址

<img src="https://img.alicdn.com/tfs/TB17Ki5XubviK0jSZFNXXaApXXa-656-656.png" width="328px" height="328px">

[For English](https://twitter.com/xianyutech "For English")
