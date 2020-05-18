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

IOS如何传递数据给flutter

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

flutter如何传递数据给native

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
3、集成流程Android（待补充）