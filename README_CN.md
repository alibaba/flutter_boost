<p align="center">
  <img src="flutter_boost.png">
</p>


# Release Note

 请查看最新版本0.1.61的release note 确认变更，[0.1.61 release note](https://github.com/alibaba/flutter_boost/releases)。

# FlutterBoost

新一代Flutter-Native混合解决方案。 FlutterBoost是一个Flutter插件，它可以轻松地为现有原生应用程序提供Flutter混合集成方案。FlutterBoost的理念是将Flutter像Webview那样来使用。在现有应用程序中同时管理Native页面和Flutter页面并非易事。 FlutterBoost帮你处理页面的映射和跳转，你只需关心页面的名字和参数即可（通常可以是URL）。


# 前置条件

在继续之前，您需要将Flutter集成到你现有的项目中。flutter sdk 的版本需要 v1.9.1-hotfixes，否则会编译失败.

# 安装

## 在Flutter项目中添加依赖项。

打开pubspec.yaml并将以下行添加到依赖项：

support分支
```json

flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: '0.1.61'

```

androidx分支
```json
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: 'feature/flutter_1.9_androidx_upgrade'
```

## Dart代码的集成
将init代码添加到App App

```dart
void main() {
    runApp(MyApp());
}

class MyApp extends StatefulWidget {
    @override
    _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    @override
    void initState() {
    super.initState();
    
        FlutterBoost.singleton.registerPageBuilders({
            'first': (pageName, params, _) => FirstRouteWidget(),
            'second': (pageName, params, _) => SecondRouteWidget(),
            'tab': (pageName, params, _) => TabRouteWidget(),
            'platformView': (pageName, params, _) => PlatformRouteWidget(),
            'flutterFragment': (pageName, params, _) => FragmentRouteWidget(params),
            'flutterPage': (pageName, params, _) {
                print("flutterPage params:$params");
            
                return FlutterRouteWidget(params:params);
            },
        });
    }
    
    @override
    Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Boost example',
        builder: FlutterBoost.init(postPush: _onRoutePushed),
        home: Container());
    }
    
    void _onRoutePushed(
        String pageName, String uniqueId, Map params, Route route, Future _) {
    }
}
```

## iOS代码集成。

注意：需要将libc++ 加入 "Linked Frameworks and Libraries" 中。

### objective-c:

使用FLBFlutterAppDelegate作为AppDelegate的超类

```objectivec
@interface AppDelegate : FLBFlutterAppDelegate <UIApplicationDelegate>
@end
```


为您的应用程序实现FLBPlatform协议方法。

```objectivec
@interface PlatformRouterImp : NSObject<FLBPlatform>
@property (nonatomic,strong) UINavigationController *navigationController;
@end


@implementation PlatformRouterImp

#pragma mark - Boost 1.5
- (void)open:(NSString *)name
   urlParams:(NSDictionary *)params
        exts:(NSDictionary *)exts
  completion:(void (^)(BOOL))completion
{
    BOOL animated = [exts[@"animated"] boolValue];
    FLBFlutterViewContainer *vc = FLBFlutterViewContainer.new;
    [vc setName:name params:params];
    [self.navigationController pushViewController:vc animated:animated];
    if(completion) completion(YES);
}

- (void)present:(NSString *)name
   urlParams:(NSDictionary *)params
        exts:(NSDictionary *)exts
  completion:(void (^)(BOOL))completion
{
    BOOL animated = [exts[@"animated"] boolValue];
    FLBFlutterViewContainer *vc = FLBFlutterViewContainer.new;
    [vc setName:name params:params];
    [self.navigationController presentViewController:vc animated:animated completion:^{
        if(completion) completion(YES);
    }];
}

- (void)close:(NSString *)uid
       result:(NSDictionary *)result
         exts:(NSDictionary *)exts
   completion:(void (^)(BOOL))completion
{
    BOOL animated = [exts[@"animated"] boolValue];
    animated = YES;
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

```objc
    PlatformRouterImp *router = [PlatformRouterImp new];
    [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform:router
                                                        onStart:^(FlutterEngine *engine) {
                                                            
                                                        }];
```

### swift:

初始化
```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    
    let router = PlatformRouterImp.init();
    FlutterBoostPlugin.sharedInstance()?.startFlutter(with: router, onStart: { (engine) in
    });
    
    self.window = UIWindow.init(frame: UIScreen.main.bounds)
    let viewController = ViewController.init()
    let navi = UINavigationController.init(rootViewController: viewController)
    self.window.rootViewController = navi
    self.window.makeKeyAndVisible()
    
    return true;//super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

为您的应用程序实现FLBPlatform协议方法。
```swift
class PlatformRouterImp: NSObject, FLBPlatform {
    func open(_ url: String, urlParams: [AnyHashable : Any], exts: [AnyHashable : Any], completion: @escaping (Bool) -> Void) {
        var animated = false;
        if exts["animated"] != nil{
            animated = exts["animated"] as! Bool;
        }
        let vc = FLBFlutterViewContainer.init();
        vc.setName(url, params: urlParams);
        self.navigationController().pushViewController(vc, animated: animated);
        completion(true);
    }
    
    func present(_ url: String, urlParams: [AnyHashable : Any], exts: [AnyHashable : Any], completion: @escaping (Bool) -> Void) {
        var animated = false;
        if exts["animated"] != nil{
            animated = exts["animated"] as! Bool;
        }
        let vc = FLBFlutterViewContainer.init();
        vc.setName(url, params: urlParams);
        navigationController().present(vc, animated: animated) {
            completion(true);
        };
    }
    
    func close(_ uid: String, result: [AnyHashable : Any], exts: [AnyHashable : Any], completion: @escaping (Bool) -> Void) {
        var animated = false;
        if exts["animated"] != nil{
            animated = exts["animated"] as! Bool;
        }
        let presentedVC = self.navigationController().presentedViewController;
        let vc = presentedVC as? FLBFlutterViewContainer;
        if vc?.uniqueIDString() == uid {
            vc?.dismiss(animated: animated, completion: {
                completion(true);
            });
        }else{
            self.navigationController().popViewController(animated: animated);
        }
    }
    
    func navigationController() -> UINavigationController {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = delegate.window?.rootViewController as! UINavigationController
        return navigationController;
    }
}
```



## Android代码集成。

在Application.onCreate（）中初始化FlutterBoost

```java
public class MyApplication extends Application {


    @Override
    public void onCreate() {
        super.onCreate();
        INativeRouter router =new INativeRouter() {
            @Override
            public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
               String  assembleUrl=Utils.assembleUrl(url,urlParams);
                PageRouter.openPageByUrl(context,assembleUrl, urlParams);
            }

        };

        FlutterBoost.BoostLifecycleListener lifecycleListener= new FlutterBoost.BoostLifecycleListener() {
            @Override
            public void onEngineCreated() {

            }

            @Override
            public void onPluginsRegistered() {
                MethodChannel mMethodChannel = new MethodChannel( FlutterBoost.instance().engineProvider().getDartExecutor(), "methodChannel");
                Log.e("MyApplication","MethodChannel create");
                TextPlatformViewPlugin.register(FlutterBoost.instance().getPluginRegistry().registrarFor("TextPlatformViewPlugin"));

            }

            @Override
            public void onEngineDestroy() {

            }
        };
        Platform platform= new FlutterBoost
                .ConfigBuilder(this,router)
                .isDebug(true)
                .whenEngineStart(FlutterBoost.ConfigBuilder.ANY_ACTIVITY_CREATED)
                .renderMode(FlutterView.RenderMode.texture)
                .lifecycleListener(lifecycleListener)
                .build();

        FlutterBoost.instance().init(platform);



    }
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

但是，这种方式无法获取页面返回的数据，建议你按上面的example实现类似于PlatformRouterImp这样的路由器，然后通过以下方式来打开/关闭页面

```objc
//push the page
[FlutterBoostPlugin open:@"first" urlParams:@{kPageCallBackId:@"MycallbackId#1"} exts:@{@"animated":@(YES)} onPageFinished:^(NSDictionary *result) {
        NSLog(@"call me when page finished, and your result is:%@", result);
    } completion:^(BOOL f) {
        NSLog(@"page is opened");
    }];
//prsent the page
[FlutterBoostPlugin open:@"second" urlParams:@{@"present":@(YES),kPageCallBackId:@"MycallbackId#2"} exts:@{@"animated":@(YES)} onPageFinished:^(NSDictionary *result) {
        NSLog(@"call me when page finished, and your result is:%@", result);
    } completion:^(BOOL f) {
        NSLog(@"page is presented");
    }];
//close the page
[FlutterBoostPlugin close:yourUniqueId result:yourdata exts:exts completion:nil];
```
Android

```java
public class PageRouter {

    public final static Map<String, String> pageName = new HashMap<String, String>() {{


        put("first", "first");
        put("second", "second");
        put("tab", "tab");

        put("sample://flutterPage", "flutterPage");
    }};

    public static final String NATIVE_PAGE_URL = "sample://nativePage";
    public static final String FLUTTER_PAGE_URL = "sample://flutterPage";
    public static final String FLUTTER_FRAGMENT_PAGE_URL = "sample://flutterFragmentPage";

    public static boolean openPageByUrl(Context context, String url, Map params) {
        return openPageByUrl(context, url, params, 0);
    }

    public static boolean openPageByUrl(Context context, String url, Map params, int requestCode) {

        String path = url.split("\\?")[0];

        Log.i("openPageByUrl",path);

        try {
            if (pageName.containsKey(path)) {
                Intent intent = BoostFlutterActivity.withNewEngine().url(pageName.get(path)).params(params)
                        .backgroundMode(BoostFlutterActivity.BackgroundMode.opaque).build(context);

                context.startActivity(intent);

            } else if (url.startsWith(FLUTTER_FRAGMENT_PAGE_URL)) {
                context.startActivity(new Intent(context, FlutterFragmentPageActivity.class));
                return true;
            } else if (url.startsWith(NATIVE_PAGE_URL)) {
                context.startActivity(new Intent(context, NativePageActivity.class));
                return true;
            } else {
                return false;
            }
        } catch (Throwable t) {
            return false;
        }
        return false;
    }
}
```


## 使用Flutter Boost在dart代码打开页面。
Dart

```java

 FlutterBoost.singleton
                .open("sample://flutterFragmentPage")

```


## 使用Flutter Boost在dart代码关闭页面。

```java
 FlutterBoost.singleton.close(uniqueId);
```

# Examples
更详细的使用例子请参考Demo

# 许可证
该项目根据MIT许可证授权 - 有关详细信息，请参阅[LICENSE.md]（LICENSE.md）文件
<a name="Acknowledgments"> </a>

# 问题反馈群（钉钉群)

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
