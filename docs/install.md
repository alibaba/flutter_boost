# 各平台安装

## 1. 目录结构

我们新建一个文件夹FlutterBoostExample，这个文件夹下面放置另外三个文件夹。 另外三个分别是您的Android工程，iOS工程，以及需要接入的flutter module，
这个地方注意，flutter一定是module，而不是工程项目，判断是不是module的方法就是看其是否有android和ios文件夹， 如果没有，那就是module，才是正确的

在这里我们命名为`BoostTestAndroid`，`BoostTestIOS`,以及`flutter_module`
注意：这三个工程在同级目录下

现在可以开始搞事情了

## Dart部分

1. 首先，需要添加`FlutterBoost`依赖到`yaml`文件

```yaml
flutter_boost:
  git:
    url: 'https://github.com/alibaba/flutter_boost.git'
    ref: 'v3.0-release.2'
```

之后在flutter工程下运行`flutter pub get` dart端就集成完毕了，然后可以在dart端放上一些代码,以下代码基于example3.0

//这里要特别注意，如果你的工程里已经有一个继承自`WidgetsFlutterBinding`的自定义Binding，则只需要将其with上`BoostFlutterBinding`
//如果你的工程没有自定义的Binding，则可以参考这个`CustomFlutterBinding`的做法 //`BoostFlutterBinding`用于接管Flutter App的生命周期，必须得接入的

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

void main() {
  ///这里的CustomFlutterBinding调用务必不可缺少，用于控制Boost状态的resume和pause
  CustomFlutterBinding();
  runApp(MyApp());
}


///创建一个自定义的Binding，继承和with的关系如下，里面什么都不用写
class CustomFlutterBinding extends WidgetsFlutterBinding with BoostFlutterBinding {}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 由于很多同学说没有跳转动画，这里是因为之前exmaple里面用的是 [PageRouteBuilder]，
  /// 其实这里是可以自定义的，和Boost没太多关系，比如我想用类似iOS平台的动画，
  /// 那么只需要像下面这样写成 [CupertinoPageRoute] 即可
  /// (这里全写成[MaterialPageRoute]也行，这里只不过用[CupertinoPageRoute]举例子)
  ///
  /// 注意，如果需要push的时候，两个页面都需要动的话，
  /// （就是像iOS native那样，在push的时候，前面一个页面也会向左推一段距离）
  /// 那么前后两个页面都必须是遵循CupertinoRouteTransitionMixin的路由
  /// 简单来说，就两个页面都是CupertinoPageRoute就好
  /// 如果用MaterialPageRoute的话同理

  Map<String, FlutterBoostRouteFactory> routerMap = {
    'mainPage': (RouteSettings settings, String uniqueId) {
      return CupertinoPageRoute(
          settings: settings,
          builder: (_) {
            Map<String, Object> map = settings.arguments as Map<String, Object> ;
            String data = map['data'] as String;
            return MainPage(
              data: data,
            );
          });
    },
    'simplePage': (settings, uniqueId) {
      return CupertinoPageRoute(
          settings: settings,
          builder: (_) {
            Map<String, Object> map = settings.arguments as Map<String, Object>;
            String data = map['data'] as String;
            return SimplePage(
              data: data,
            );
          });
    },
  };

  Route<dynamic> routeFactory(RouteSettings settings, String uniqueId) {
    FlutterBoostRouteFactory func = routerMap[settings.name] as FlutterBoostRouteFactory;
    return func(settings, uniqueId);
  }

  Widget appBuilder(Widget home) {
    return MaterialApp(
      home: home,
      debugShowCheckedModeBanner: true,

      ///必须加上builder参数，否则showDialog等会出问题
      builder: (_, __) {
        return home;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(
      routeFactory,
      appBuilder: appBuilder,
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Object data});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Main Page')),
    );
  }
}

class SimplePage extends StatelessWidget {
  const SimplePage({Object data});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:  Center(child: Text('SimplePage')),
    );
  }
}
```

到此dart端就集成完毕了

## Android部分

1. 在setting.gradle文件中添加如下的代码,这一步是引用flutter工程 添加之后`Binding`会报红，这个地方不管他，直接往下看

```
setBinding(new Binding([gradle: this]))
evaluate(new File(
        settingsDir.parentFile,
        'flutter_module/.android/include_flutter.groovy'
))
include ':flutter_module'
project(':flutter_module').projectDir = new File('../flutter_module')
```

2. 然后在app的build.gradle下添加如下代码

```
implementation project(':flutter')
implementation project(':flutter_boost')
```

3. 还需要在清单文件中添加以下内容直接粘贴到`<application>`标签包裹的内部即可，也就是和其他`<activity>`标签同级

```xml
<activity
        android:name="com.idlefish.flutterboost.containers.FlutterBoostActivity"
        android:theme="@style/Theme.AppCompat"
        android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density"
        android:hardwareAccelerated="true"
        android:windowSoftInputMode="adjustResize" >

</activity>
<meta-data android:name="flutterEmbedding"
           android:value="2">
</meta-data>


```

然后点击右上角的sync同步一下，就会开始一些下载和同步的进程，等待完成

4. 在`Application`中添加`FlutterBoost`的启动流程，并设置代理

```java
public class App extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        FlutterBoost.instance().setup(this, new FlutterBoostDelegate() {
            @Override
            public void pushNativeRoute(FlutterBoostRouteOptions options) {
                //这里根据options.pageName来判断你想跳转哪个页面，这里简单给一个
                Intent intent = new Intent(FlutterBoost.instance().currentActivity(), YourTargetAcitvity.class);
                FlutterBoost.instance().currentActivity().startActivityForResult(intent, options.requestCode());
            }

            @Override
            public void pushFlutterRoute(FlutterBoostRouteOptions options) {
                Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(FlutterBoostActivity.class)
                        .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.transparent)
                        .destroyEngineWithActivity(false)
                        .uniqueId(options.uniqueId())
                        .url(options.pageName())
                        .urlParams(options.arguments())
                        .build(FlutterBoost.instance().currentActivity());
                FlutterBoost.instance().currentActivity().startActivity(intent);
            }
        }, engine -> {
        });
    }
}
```

到此为止Android的集成流程就全部完成

## iOS部分

1. 首先到自己的iOS目录下，执行`pod init`,之后执行一次`pod install`

2. 打开创建的Podfile文件，添加以下代码

```
flutter_application_path = '../flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
install_all_flutter_pods(flutter_application_path)
```

添加之后，您的Podfile应该类似下面这样

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

flutter_application_path = '../flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'BoostTestIOS' do
  use_frameworks!

  install_all_flutter_pods(flutter_application_path)

end
```

然后再执行`pod install`,安装完成

3.进行准备工作创建`FlutterBoostDelegate`。 这里面的内容是完全可以自定义的，在您了解各个API的含义时，你可以完全自定义这里面每个方法的代码，下面只是给出大多数场景的默认解法

```swift
class BoostDelegate: NSObject,FlutterBoostDelegate {
    
    ///您用来push的导航栏
    var navigationController:UINavigationController?
    
    ///用来存返回flutter侧返回结果的表
    var resultTable:Dictionary<String,([AnyHashable:Any]?)->Void> = [:];
    
    func pushNativeRoute(_ pageName: String!, arguments: [AnyHashable : Any]!) {
        
        //可以用参数来控制是push还是pop
        let isPresent = arguments["isPresent"] as? Bool ?? false
        let isAnimated = arguments["isAnimated"] as? Bool ?? true
        //这里根据pageName来判断生成哪个vc，这里给个默认的了
        var targetViewController = UIViewController()
        
        if(isPresent){
            self.navigationController?.present(targetViewController, animated: isAnimated, completion: nil)
        }else{
            self.navigationController?.pushViewController(targetViewController, animated: isAnimated)
        }
    }
    
    func pushFlutterRoute(_ options: FlutterBoostRouteOptions!) {
        let vc:FBFlutterViewContainer = FBFlutterViewContainer()
        vc.setName(options.pageName, uniqueId: options.uniqueId, params: options.arguments,opaque: options.opaque)
        
        //用参数来控制是push还是pop
        let isPresent = (options.arguments?["isPresent"] as? Bool)  ?? false
        let isAnimated = (options.arguments?["isAnimated"] as? Bool) ?? true
        
        //对这个页面设置结果
        resultTable[options.pageName] = options.onPageFinished;
        
        //如果是present模式 ，或者要不透明模式，那么就需要以present模式打开页面
        if(isPresent || !options.opaque){
            self.navigationController?.present(vc, animated: isAnimated, completion: nil)
        }else{
            self.navigationController?.pushViewController(vc, animated: isAnimated)
        }
    }
    
    func popRoute(_ options: FlutterBoostRouteOptions!) {
        //如果当前被present的vc是container，那么就执行dismiss逻辑
        if let vc = self.navigationController?.presentedViewController as? FBFlutterViewContainer,vc.uniqueIDString() == options.uniqueId{
            
            //这里分为两种情况，由于UIModalPresentationOverFullScreen下，生命周期显示会有问题
            //所以需要手动调用的场景，从而使下面底部的vc调用viewAppear相关逻辑
            if vc.modalPresentationStyle == .overFullScreen {
                
                //这里手动beginAppearanceTransition触发页面生命周期
                self.navigationController?.topViewController?.beginAppearanceTransition(true, animated: false)
                
                vc.dismiss(animated: true) {
                    self.navigationController?.topViewController?.endAppearanceTransition()
                }
            }else{
                //正常场景，直接dismiss
                vc.dismiss(animated: true, completion: nil)
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        //否则直接执行pop逻辑
        //这里在pop的时候将参数带出,并且从结果表中移除
        if let onPageFinshed = resultTable[options.pageName] {
            onPageFinshed(options.arguments)
            resultTable.removeValue(forKey: options.pageName)
        }
    }
}
```

4.在`AppDelegate`的`didFinishLaunchingWithOptions`方法中进行初始化

```swift
//创建代理，做初始化操作
let delegate = BoostDelegate()
FlutterBoost.instance().setup(application, delegate: delegate) { engine in
    
}
```

到此为止，所有的前置内容均已完成


















