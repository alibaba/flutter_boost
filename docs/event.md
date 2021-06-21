# 自定义事件传递API

这个部分相当于让开发者省略了手动搭桥的功能，通过事件标识key和参数map即可完成事件传递


## flutter端使用

 - 接收消息
```dart
///声明一个用来存回调的对象
VoidCallback removeListener;

///添加事件响应者,监听native发往flutter端的事件
removeListener = BoostChannel.instance.addEventListener("yourEventKey", (key, arguments) {
  ///deal with your event here
  return;
});

///然后在退出的时候（比如dispose中）移除监听者
removeListener?.call();
```

 - 发送消息给native
```dart
BoostChannel.instance.sendEventToNative("eventToNative",{"key1":"value1"});
```

## iOS端使用

 - 接收消息
```swift
//同样声明一个对象用来存删除的函数
var removeListener:FBVoidCallback?

//这里注册事件监听，监听flutter发送到iOS的事件
self.removeListener =  FlutterBoost.instance().addEventListener({[weak self] key, dic in
    //注意，如果这里self持有removeListener，而这个闭包中又有self的话，要用weak self
    //否则就有self->removeListener->self 循环引用
    
    //在这里处理你的事件
    
}, forName: "event")

//在退出的时候解除注册(比如 deinit/dealloc 中)
removeListener?()
```

- 发送消息给flutter
```swift
FlutterBoost.instance().sendEventToFlutter(with: "event", arguments: ["data":"event from native"])
```

## Android端使用

 - 接收消息

```java
EventListener listener = (key, args) -> {
    //deal with your event here      
};
ListenerRemover remover = FlutterBoost.instance().addEventListener("event", listener);

//最后在清理的时候移除监听(比如onDestroy中)
remover.remove();
```

- 发送消息给flutter
```java
Map<Object,Object> map = new HashMap<>();
map.put("key","value");
FlutterBoost.instance().sendEventToFlutter("eventToFlutter",map);
```