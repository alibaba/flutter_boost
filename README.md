<p align="center">
  <img src="flutter_boost.png">
   <b></b><br>
  <a href="README_CN.md">中文文档</a>
  <a href="https://mp.weixin.qq.com/s?__biz=MzU4MDUxOTI5NA==&mid=2247484367&idx=1&sn=fcbc485f068dae5de9f68d52607ea08f&chksm=fd54d7deca235ec86249a9e3714ec18be8b2d6dc580cae19e4e5113533a6c5b44dfa5813c4c3&scene=0&subscene=131&clicktime=1551942425&ascene=7&devicetype=android-28&version=2700033b&nettype=ctnet&abtest_cookie=BAABAAoACwASABMABAAklx4AVpkeAMSZHgDWmR4AAAA%3D&lang=zh_CN&pass_ticket=1qvHqOsbLBHv3wwAcw577EHhNjg6EKXqTfnOiFbbbaw%3D&wx_header=1">中文介绍</a>
</p>

# Release Note

Please checkout the release note for the latest 0.1.50 to see changes [0.1.50 release note](https://github.com/alibaba/flutter_boost/releases)

# FlutterBoost
A next-generation Flutter-Native hybrid solution. FlutterBoost is a Flutter plugin which enables hybrid integration of Flutter for your existing native apps with minimum efforts.The philosophy of FlutterBoost is to use Flutter as easy as using a WebView. Managing Native pages and Flutter pages at the same time is non-trivial in an existing App. FlutterBoost takes care of page resolution for you. The only thing you need to care about is the name of the page(usually could be an URL). 
<a name="bf647454"></a>

# Prerequisites
You need to add Flutter to your project before moving on.The version of the flutter SDK requires v1.5.4-hotfixes, or it will compile error.

# Getting Started


## Add a dependency in you Flutter project.

Open you pubspec.yaml and add the following line to dependencies:

```java
flutter_boost: ^0.1.52
```

or you could rely directly on a Github project tag, for example(recommended)

```java
flutter_boost:
        git:
            url: 'https://github.com/alibaba/flutter_boost.git'
            ref: '0.1.52'
```



## Integration with Flutter code.
Add init code to you App

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

  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Flutter Boost example',
      builder: FlutterBoost.init(), ///init container manager
      home: Container());
}
```


## Integration with iOS code.

Note: You need to add libc++ into "Linked Frameworks and Libraries" 

Use FLBFlutterAppDelegate as the superclass of your AppDelegate

```objc
@interface AppDelegate : FLBFlutterAppDelegate <UIApplicationDelegate>
@end
```


Implement FLBPlatform protocol methods for your App.

```objc
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



Initialize FlutterBoost with FLBPlatform at the beginning of your App.

```objc
 [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform:router
                                                        onStart:^(id engine) {
                                                            
                                                        }];
```

## Integration with Android code.

Init FlutterBoost in Application.onCreate() 

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

            @Override
            public boolean isDebug() {
                return true;
            }

            @Override
            public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
            		//native open url 
            }

            @Override
            public IFlutterEngineProvider engineProvider() {
                return new BoostEngineProvider(){
                    @Override
                    public BoostFlutterEngine createEngine(Context context) {
                        return new BoostFlutterEngine(context, new DartExecutor.DartEntrypoint(
                                context.getResources().getAssets(),
                                FlutterMain.findAppBundlePath(context),
                                "main"),"/");
                    }
                };
            }

            @Override
            public int whenEngineStart() {
                return ANY_ACTIVITY_CREATED;
            }

        });
    }
```


# Basic Usage
## Concepts

All page routing requests are being sent to the native router. Native router communicates with Native Container Manager, Native Container Manager takes care of building and destroying of Native Containers. 


## Use Flutter Boost Native Container to show a Flutter page in native code.

iOS

```objc
 FLBFlutterViewContainer *vc = FLBFlutterViewContainer.new;
        [vc setName:name params:params];
        [self.navigationController presentViewController:vc animated:animated completion:^{}];
```

Android

```java
public class FlutterPageActivity extends BoostFlutterActivity {


    @Override
    public String getContainerUrl() {
     	//specify the page name register in FlutterBoost
       return "sample://firstPage";
    }

    @Override
    public Map getContainerUrlParams() {
    	//params of the page
        Map<String,String> params = new HashMap<>();
        params.put("key","value");
        return params;
    }
}
```

or

```java

public class FlutterFragment extends BoostFlutterFragment {
	  @Override
     public String getContainerUrl() {
        return "flutterFragment";
    }

    @Override
     public Map getContainerUrlParams() {
        Map<String,String> params = new HashMap<>();
        params.put("tag",getArguments().getString("tag"));
        return params;
    }
}
```


## Use Flutter Boost to open a page in dart code.

Dart

```objc

FlutterBoost.singleton
                .open("pagename")

```

## Use Flutter Boost to close a page in dart code.

```objc

FlutterBoost.singleton.close(uniqueId);

```

# Running the Demo
Please see the example for details.


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
