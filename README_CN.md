<p align="center">
  <img src="flutter_boost.png">
</p>

# FlutterBoost

新一代Flutter-Native混合解决方案。 FlutterBoost是一个Flutter插件，它可以轻松地为现有原生应用程序提供Flutter混合集成方案。FlutterBoost的理念是将Flutter像Webview那样来使用。在现有应用程序中同时管理Native页面和Flutter页面并非易事。 FlutterBoost帮你处理页面的映射和跳转，你只需关心页面的名字和参数即可（通常可以是URL）。


# 前置条件
在继续之前，您需要将Flutter集成到你现有的项目中。

# 安装

## 在Flutter项目中添加依赖项。

打开pubspec.yaml并将以下行添加到依赖项：

```json
flutter_boost: ^0.0.412
```

或者可以直接依赖github的项目的版本，Tag，pub发布会有延迟，推荐直接依赖Github项目
```java
flutter_boost:
        git:
            url: 'https://github.com/alibaba/flutter_boost.git'
            ref: '0.0.412'
```
## Dart代码的集成
将init代码添加到App App

```dart
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    ///register page widget builders,the key is pageName
    FlutterBoost.singleton.registerPageBuilders({
      'sample://firstPage': (pageName, params, _) => FirstRouteWidget(),
      'sample://secondPage': (pageName, params, _) => SecondRouteWidget(),
    });

    ///query current top page and load it
    FlutterBoost.handleOnStartPage();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Flutter Boost example',
      builder: FlutterBoost.init(), ///init container manager
      home: Container());
}
```

## iOS代码集成。

注意：需要将libc++ 加入 "Linked Frameworks and Libraries" 中。

使用FLBFlutterAppDelegate作为AppDelegate的超类

```objectivec
@interface AppDelegate : FLBFlutterAppDelegate <UIApplicationDelegate>
@end
```


为您的应用程序实现FLBPlatform协议方法。

```objectivec
@interface DemoRouter : NSObject<FLBPlatform>

@property (nonatomic,strong) UINavigationController *navigationController;

+ (DemoRouter *)sharedRouter;

@end


@implementation DemoRouter

- (void)openPage:(NSString *)name
          params:(NSDictionary *)params
        animated:(BOOL)animated
      completion:(void (^)(BOOL))completion
{
    if([params[@"present"] boolValue]){
        FLBFlutterViewContainer *vc = FLBFlutterViewContainer.new;
        [vc setName:name params:params];
        [self.navigationController presentViewController:vc animated:animated completion:^{}];
    }else{
        FLBFlutterViewContainer *vc = FLBFlutterViewContainer.new;
        [vc setName:name params:params];
        [self.navigationController pushViewController:vc animated:animated];
    }
}


- (void)closePage:(NSString *)uid animated:(BOOL)animated params:(NSDictionary *)params completion:(void (^)(BOOL))completion
{
    FLBFlutterViewContainer *vc = (id)self.navigationController.presentedViewController;
    if([vc isKindOfClass:FLBFlutterViewContainer.class] && [vc.uniqueIDString isEqual: uid]){
        [vc dismissViewControllerAnimated:animated completion:^{}];
    }else{
        [self.navigationController popViewControllerAnimated:animated];
    }
}

@end
```



在应用程序开头使用FLBPlatform初始化FlutterBoost。

```的ObjectiveC
 [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform：router
                                                        onStart：^（FlutterViewController * fvc）{
                                                            
                                                        }];
```

## Android代码集成。

在Application.onCreate（）中初始化FlutterBoost

```java
public class MyApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        FlutterBoostPlugin.init(new IPlatform() {
            @Override
            public Application getApplication() {
                return MyApplication.this;
            }

            /**
             * get the main activity, this activity should always at the bottom of task stack.
             */
            @Override
            public Activity getMainActivity() {
                return MainActivity.sRef.get();
            }

            @Override
            public boolean isDebug() {
                return false;
            }

            /**
             * start a new activity from flutter page, you may need a activity router.
             */
            @Override
            public boolean startActivity(Context context, String url, int requestCode) {
                return PageRouter.openPageByUrl(context,url,requestCode);
            }

            @Override
            public Map getSettings() {
                return null;
            }
        });
    }
```

# 基本用法
## 概念

所有页面路由请求都将发送到Native路由器。Native路由器与Native Container Manager通信，Native Container Manager负责构建和销毁Native Containers。

## 使用Flutter Boost Native Container用Native代码打开Flutter页面。

```objc
 FLBFlutterViewContainer *vc = FLBFlutterViewContainer.new;
        [vc setName:name params:params];
        [self.navigationController presentViewController:vc animated:animated completion:^{}];
```

Android

```java
public class FlutterPageActivity extends BoostFlutterActivity {

    @Override
    public void onRegisterPlugins(PluginRegistry registry) {
        //register flutter plugins
        GeneratedPluginRegistrant.registerWith(registry);
    }

    @Override
    public String getContainerName() {
        //specify the page name register in FlutterBoost
        return "sample://firstPage";
    }

    @Override
    public Map getContainerParams() {
        //params of the page
        Map<String,String> params = new HashMap<>();
        params.put("key","value");
        return params;
    }
}
```

或者用Fragment

```java
public class FlutterFragment extends BoostFlutterFragment {
    @Override
    public void onRegisterPlugins(PluginRegistry registry) {
        GeneratedPluginRegistrant.registerWith(registry);
    }

    @Override
    public String getContainerName() {
        return "sample://firstPage";
    }

    @Override
    public Map getContainerParams() {
        Map<String,String> params = new HashMap<>();
        params.put("key","value");
        return params;
    }
}
```


## 使用Flutter Boost在dart代码打开页面。
Dart

```java
 FlutterBoost.singleton.openPage("pagename", {}, true);
```


## 使用Flutter Boost在dart代码关闭页面。

```java
FlutterBoost.singleton.closePageForContext(context);
```

# Examples
更详细的使用例子请参考Demo


# 作者
阿里巴巴闲鱼终端团队

# 许可证
该项目根据MIT许可证授权 - 有关详细信息，请参阅[LICENSE.md]（LICENSE.md）文件
<a name="Acknowledgments"> </a>
# 致谢
- Flutter
