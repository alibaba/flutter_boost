1、为何使用flutter_boost？

    官方的集成方案有诸多弊病：
    - 日志不能输出到原生端；
    - 存在内存泄漏的问题，使用boost可以让内存稳定；
    - native调用flutter，flutter调用native，通道的封装，使开发更加简便；
    - 同时对于页面生命周期的管理，也梳理的比较整齐

2、集成流程IOS


在delegate中做flutter初始化的工作
```

在appDelegate中引入，PlatformRouterImp，用于实现平台侧的页面打开和关闭，不建议直接使用用于页面打开，建议使用FlutterBoostPlugin中的open和close方法来打开或关闭页面；
PlatformRouterImp内部实现打开各种native页面的映射。 

    self.router = [PlatformRouterImp new];
    //初始化FlutterBoost混合栈环境。应在程序使用混合栈之前调用。如在AppDelegate中。本函数默认需要flutter boost来注册所有插件。
    [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform:self.router
                                                        onStart:^(FlutterEngine *engine) {
                                                            
                                                        }];

```
PlatformRouterImp，内部实现打开native页面的路由代码截图

```
- (void)open:(NSString *)name
   urlParams:(NSDictionary *)params
        exts:(NSDictionary *)exts
  completion:(void (^)(BOOL))completion
{
    if ([name isEqualToString:@"page1"]) {//打开页面1
        // 打开页面1的vc
        return;
    }
    
    BOOL animated = [exts[@"animated"] boolValue];
    FLBFlutterViewContainer *vc = FLBFlutterViewContainer.new;
    [vc setName:name params:params];
    [self.navigationController pushViewController:vc animated:animated];
    if(completion) completion(YES);
}
```
如何打开，关闭flutter页面，直接调用FlutterBoostPlugin的类方法即可。

```

/**
 * 关闭页面，混合栈推荐使用的用于操作页面的接口
 *
 * @param uniqueId 关闭的页面唯一ID符
 * @param resultData 页面要返回的结果（给上一个页面），会作为页面返回函数的回调参数
 * @param exts 额外参数
 * @param completion 关闭页面的即时回调，页面一旦关闭即回调
 */
+ (void)close:(NSString *)uniqueId
       result:(NSDictionary *)resultData
         exts:(NSDictionary *)exts
   completion:(void (^)(BOOL))completion;

/**
 * 打开新页面（默认以push方式），混合栈推荐使用的用于操作页面的接口；通过urlParams可以设置为以present方式打开页面：urlParams:@{@"present":@(YES)}
 *
 * @param url 打开的页面资源定位符
 * @param urlParams 传人页面的参数; 若有特殊逻辑，可以通过这个参数设置回调的id
 * @param exts 额外参数
 * @param resultCallback 当页面结束返回时执行的回调，通过这个回调可以取得页面的返回数据，如close函数传入的resultData
 * @param completion 打开页面的即时回调，页面一旦打开即回调
 */
+ (void)open:(NSString *)url
   urlParams:(NSDictionary *)urlParams
        exts:(NSDictionary *)exts
       onPageFinished:(void (^)(NSDictionary *))resultCallback
  completion:(void (^)(BOOL))completion;

/**
 * Present方式打开新页面，混合栈推荐使用的用于操作页面的接口
 *
 * @param url 打开的页面资源定位符
 * @param urlParams 传人页面的参数; 若有特殊逻辑，可以通过这个参数设置回调的id
 * @param exts 额外参数
 * @param resultCallback 当页面结束返回时执行的回调，通过这个回调可以取得页面的返回数据，如close函数传入的resultData
 * @param completion 打开页面的即时回调，页面一旦打开即回调
 */
+ (void)present:(NSString *)url
   urlParams:(NSDictionary *)urlParams
        exts:(NSDictionary *)exts
onPageFinished:(void (^)(NSDictionary *))resultCallback
  completion:(void (^)(BOOL))completion;
```

IOS如何传递数据给flutter（可以自定义channel）

```
//name是事件的名称，arguments中是一个NSDictionary，OC代码
[FlutterBoostPlugin.sharedInstance sendEvent:@"name" arguments:@{}];

//flutter部分接收数据，dart代码
  FlutterBoost.singleton.channel.addEventListener('name',
        (name, arguments){
      //todo

      return;
    });
```

flutter如何传递数据给native（可以自定义channel）

```
//flutter代码，ChannelName是通道名称与native部分一致即可，tmp是map类型的参数
 Map<String,dynamic> tmp = Map<String,dynamic>();

   try{

     FlutterBoost.singleton.channel.sendEvent(ChannelName, tmp);

   }catch(e){


   }
   
   
//IOS侧代码
  [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
  
        
    } forName:@"statistic"];
```


flutter中页面的生命周期管理


```
enum ContainerLifeCycle {
  Init,
  Appear,//已经出现，很遗憾的是如果在native部分present页面，这里是不会回调的。
  WillDisappear,
  Disappear,
  Destroy,
  Background,
  Foreground
}



  FlutterBoost.singleton.addBoostContainerLifeCycleObserver(//这个类是单例，再每个页面的initState方法中添加即可监听
          (ContainerLifeCycle state, BoostContainerSettings settings) {
          //setttings是配置，name表示页面的名称，建议一定要等到当前页面Appear状态的时候再做操作，
        print(
            'FlutterBoost.singleton.addBoostContainerLifeCycleObserver '+state.toString()+' '+settings.name);
      },
    );
```
关于flutter部分打开新页面的回调的一些坑。

```
 FlutterBoost.singleton
                        .open(CoursePage.routeName, urlParams: {
                      
                    }).then((Map<dynamic, dynamic> value) {
                      print(
                          'call me when page is finished. did recieve second route result $value');

                     //这个方法会优先于addBoostContainerLifeCycleObserver中的appear方法调用，所以说有些方法在这里调用，如果appear还没有出现的话就会有问题。
                    });
```

IOS已知的一些问题
```
    1、如果在IOS端只是第一次打开Flutter页面用Boost的路由然后FlutterA跳转到FlutterB用的Navigator的话，当前右滑会直接pop掉所有Flutter页面，因为这种情况只有一个VC承载Flutter页面，
推荐Native->Flutter，FlutterA->FlutterB，Flutter->Native都用Boost路由管理

    2、移除addEventListener，移除addBoostContainerLifeCycleObserver。addEventListener方法会返回一个FLBVoidCallback，执行这个FLBVoidCallback就会移除；addBoostContainerLifeCycleObserver会返回一个VoidCallback，在dispose()中调用VoidCallback就remove了
    
    3、Flutter调Native后获取Native回传。channel肯定可以的，boost目前默认应该只支持FlutterA->FlutterB的回传，Flutter->Native和Native->Flutter可以自己实现。下面是FlutterA->FlutterB的回传方式
        FlutterA打开FlutterB：
            FlutterBoost.singleton
                .open('FlutterB')
                .then((Map<dynamic, dynamic> value) {
              print(
                  'call me when page is finished. did recieve FlutterB route result $value');
            });
        FlutterB close并回传：
            final BoostContainerSettings settings = BoostContainer.of(context).settings;
            FlutterBoost.singleton.close(settings.uniqueId, result: <String, dynamic>{'result': 'data from FlutterB'});
```

3、集成流程Android

在Android工程全局Application类的onCreate周期初始化，具体可以参考example
```
INativeRouter router =new INativeRouter() {
    @Override
    public void openContainer(Context context, String url, Map<String, Object> urlParams, int requestCode, Map<String, Object> exts) {
       String  assembleUrl=Utils.assembleUrl(url,urlParams);
        PageRouter.openPageByUrl(context,assembleUrl, urlParams);
    }

};

// 生命周期监听
FlutterBoost.BoostLifecycleListener boostLifecycleListener= new FlutterBoost.BoostLifecycleListener(){

    @Override
    public void beforeCreateEngine() {

    }

    @Override
    public void onEngineCreated() {
        // 引擎创建后的操作，比如自定义MethodChannel，PlatformView等
    }

    @Override
    public void onPluginsRegistered() {

    }

    @Override
    public void onEngineDestroy() {

    }

};

// 生成Platform配置
Platform platform= new FlutterBoost
        .ConfigBuilder(this,router)
        .isDebug(true)
        .dartEntrypoint() //dart入口，默认为main函数，这里可以根据native的环境自动选择Flutter的入口函数来统一Native和Flutter的执行环境，（比如debugMode == true ? "mainDev" : "mainProd"，Flutter的main.dart里也要有这两个对应的入口函数）
        .whenEngineStart(FlutterBoost.ConfigBuilder.ANY_ACTIVITY_CREATED)
        .renderMode(FlutterView.RenderMode.texture)
        .lifecycleListener(boostLifecycleListener)
        .build();
// 初始化
FlutterBoost.instance().init(platform);
```

配置路由PageRouter类
```
// 这里可以配置管理Native和Flutter的映射，通过Boost提供的open方法在Flutter打开Native和Flutter页面并传参，或者通过openPageByUrl方法在Native打开Native和Flutter页面并传参。
// 一定要确保Flutter端registerPageBuilders里注册的路由的key和这里能够一一映射，否则会报page != null的红屏错误

// flutter页面映射
public final static Map<String, String> pageName = new HashMap<String, String>() {{
    put("first", "first");
    put("second", "second");
    put("tab", "tab");
    put("sample://flutterPage", "flutterPage");
}};

public static final String NATIVE_PAGE_URL = "sample://nativePage";
public static final String FLUTTER_PAGE_URL = "sample://flutterPage";

public static boolean openPageByUrl(Context context, String url, Map params, int requestCode) {

    String path = url.split("\\?")[0];

    Log.i("openPageByUrl",path);

    try {
        if (pageName.containsKey(path)) {
            // 这直接用的Boost提供的Activity作为Flutter的容器，也可以继承BoostFlutterActivity后做一些自定义的行为
            Intent intent = BoostFlutterActivity.withNewEngine().url(pageName.get(path)).params(params)
                    .backgroundMode(BoostFlutterActivity.BackgroundMode.opaque).build(context);
            if(context instanceof Activity){
                Activity activity=(Activity)context;
                activity.startActivityForResult(intent,requestCode);
            }else{
                context.startActivity(intent);
            }
            return true;
        } else if (url.startsWith(NATIVE_PAGE_URL)) {
            context.startActivity(new Intent(context, NativePageActivity.class));
            return true;
        }

        return false;

    } catch (Throwable t) {
        return false;
    }
}
比如启动App后首页点击open flutter page按钮实际执行的是PageRouter.openPageByUrl(this, PageRouter.FLUTTER_PAGE_URL,params)，然后走openPageByUrl方法第一个if是Flutter页面的映射
然后pageName.get(path)这里path是sample://flutterPage，这样pageName.get(path)获取到的是flutterPage，对应的就是main.dart里registerPageBuilders注册的flutterPage对应的FlutterRouteWidget(params: params)，
进入这个页面同时把params传到这个页面
```

Flutter工程配置registerPageBuilders
```
FlutterBoost.singleton.registerPageBuilders(<String, PageBuilder>{
    'first': (String pageName, Map<String, dynamic> params, String _) => FirstRouteWidget(),
    'second': (String pageName, Map<String, dynamic> params, String _) => SecondRouteWidget(),
    'tab': (String pageName, Map<String, dynamic> params, String _) => TabRouteWidget(),
    'flutterPage': (String pageName, Map<String, dynamic> params, String _) {
        print('flutterPage params:$params');
        return FlutterRouteWidget(params: params);
    },
});
```

Android和Flutter传递数据
```
    1、Native用PageRouter.openPageByUrl打开Flutter，Flutter用FlutterBoost.singleton.open打开Native都可以传递参数
    
    2、自定义channel
    
    3、Native向Flutter传递数据在Native端发送FlutterBoost.instance().channel().sendEvent("name", map)，在Flutter端监听FlutterBoost.singleton.channel.addEventListener(name, (name, arguments) => null)，两个name要一致。
Flutter向Native发送数据在Flutter端发送FlutterBoost.singleton.channel.sendEvent(name, arguments)，在Native端监听，两个name要一致。移除的话Native端调用removeEventListener方法，Flutter端直接执行addEventListener返回的VoidCallback
```

Android已知的一些问题
```
    1、第一次进flutter页面statusBar字体颜色正常，第二次进入不正常。状态栏字体颜色的问题，Boost之前写死在delegate onPostResume里了，但是只适配白底黑字的情况所以这部分代码去掉了，当前可行的方式是继承BoostActivity自己设置状态栏颜色：
        白底黑字
        brightness: Brightness.light, （Flutter AppBar)
        backgroundColor: Colors.white, (Flutter AppBar)
        Utils.setStatusBarLightMode(host.getActivity(), true); (Native Activity，这里是之前delegate onPostResume的代码，自定义Activity使用需要修改)
        黑底白字
        brightness: Brightness.dark, （Flutter AppBar)
        backgroundColor: Colors.black, (Flutter AppBar)
        Utils.setStatusBarLightMode(host.getActivity(), false); (Native Activity，这里是之前delegate onPostResume的代码，自定义Activity使用需要修改)
        
    2、Flutter调Native后获取Native回传。channel肯定可以的，boost目前默认应该只支持FlutterA->FlutterB的回传，Flutter->Native和Native->Flutter可以自己实现。下面是FlutterA->FlutterB的回传方式
        FlutterA打开FlutterB：
            FlutterBoost.singleton
                .open('FlutterB')
                .then((Map<dynamic, dynamic> value) {
              print(
                  'call me when page is finished. did recieve FlutterB route result $value');
            });
        FlutterB close并回传：
            final BoostContainerSettings settings = BoostContainer.of(context).settings;
            FlutterBoost.singleton.close(settings.uniqueId, result: <String, dynamic>{'result': 'data from FlutterB'});
        Android端实现Flutter调Native回传的一种方案：
            FlutterBoost.singleton.open('url').then((result)=>{...}) Flutter调用Android如果需要返回值开启Activity的时候用startActivityforResult 然后关闭页面Activity的时候setResult就可以在Flutter的页面拿到返回值
            Router打开Native的时候startActivityForResult
            然后Native页面返回的时候setResult就行了
            Map map = new HashMap<String, String>();
            map.put("a", "a");
            Intent intent = getIntent().putExtra(IFlutterViewContainer.RESULT_KEY, (Serializable) map);
            setResult(0, intent);
            
    3、flutter_boost 使用pushReplacement跳转返回键报错 Unhandled Exception: Failed assertion scope != null
        目前还不支持，Navigator的方法现在只支持push/pop/maybePop/addLifeCycleObserver，待后续增加，popUntil可以用close结合广播实现，不过侵入性相对强了些
```



