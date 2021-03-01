<p align="center">
  <img src="flutter_boost.png">
   <b></b><br>
  <a href="README_CN.md">中文文档</a>
  <a href="https://mp.weixin.qq.com/s?__biz=MzU4MDUxOTI5NA==&mid=2247484367&idx=1&sn=fcbc485f068dae5de9f68d52607ea08f&chksm=fd54d7deca235ec86249a9e3714ec18be8b2d6dc580cae19e4e5113533a6c5b44dfa5813c4c3&scene=0&subscene=131&clicktime=1551942425&ascene=7&devicetype=android-28&version=2700033b&nettype=ctnet&abtest_cookie=BAABAAoACwASABMABAAklx4AVpkeAMSZHgDWmR4AAAA%3D&lang=zh_CN&pass_ticket=1qvHqOsbLBHv3wwAcw577EHhNjg6EKXqTfnOiFbbbaw%3D&wx_header=1">中文介绍</a>
</p>

# Release Note

Please check the release note of the latest version to confirm the change.  [ release note](https://github.com/alibaba/flutter_boost/releases)

# FlutterBoost
A next-generation Flutter-Native hybrid solution. FlutterBoost is a Flutter plugin which enables hybrid integration of Flutter for your existing native apps with minimum efforts.The philosophy of FlutterBoost is to use Flutter as easy as using a WebView. Managing Native pages and Flutter pages at the same time is non-trivial in an existing App. FlutterBoost takes care of page resolution for you. The only thing you need to care about is the name of the page(usually could be an URL). 
<a name="bf647454"></a>

# Prerequisites

1. Before proceeding, you need to integrate Flutter into your existing project.
2. The Flutter SDK version supported by Boost 3.0 is >= 1.22


# Getting Started


## Add a dependency in you Flutter project.

Open you pubspec.yaml and add the following line to dependencies:

androidx branch
```json
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: 'v3.0-hotfixes'
```



# Boost  Integration


## dart测接入
### 1. Initialize ：

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
### 2.Boost Lifecycle monitoring ：
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
### Page jump
Open the page

```java
 String result = await BoostNavigator.of()
                        .push("flutterPage", withContainer: true);
```
Close the page

```java
BoostNavigator.of().pop('I am result for popping.'),
```
## Android 测接入
### 1. Initialize
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
### 3.native Open and close the Flutter page
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
### native Open the Flutter page

```objc
[[FlutterBoost instance] open:@"flutterPage" arguments:@{@"animated":@(YES)}  ];

[[FlutterBoost instance] open:@"secondStateful" arguments:@{@"present":@(YES)}];
```


# FAQ
please read this document:
<a href="Frequently Asked Question.md">FAQ</a>


# License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


# Problem feedback group（ dingding group)

<img width="200" src="https://img.alicdn.com/tfs/TB1JSzVeYY1gK0jSZTEXXXDQVXa-892-1213.jpg">




## 关于我们

阿里巴巴-闲鱼技术是国内最早也是最大规模线上运行Flutter的团队。

我们在公众号中为你精选了Flutter独家干货，全面而深入。

内容包括：Flutter的接入、规模化应用、引擎探秘、工程体系、创新技术等教程和开源信息。

**架构／服务端／客户端／前端／算法／质量工程师 在公众号中投递简历，名额不限哦**

欢迎来闲鱼做一个好奇、幸福、有影响力的程序员，简历投递：tino.wjf@alibaba-inc.com

订阅地址

<img src="https://img.alicdn.com/tfs/TB17Ki5XubviK0jSZFNXXaApXXa-656-656.png" width="328px" height="328px">

[For English](https://twitter.com/xianyutech "For English")
