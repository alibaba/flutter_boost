# 基本路由API部分

## Dart 部分
### 1.开启新页面统一API
```dart
BoostNavigator.instance.push(
    "yourPage", //required
    withContainer: false, //optional
    arguments: {"key":"value"}, //optional
    opaque: true, //optional,default value is true
);

///or

Navigator.of(context).pushNamed('simplePage', arguments: {'data': _controller.text});

///不能使用匿名路由，boost目前无法捕捉匿名路由，匿名路由就是直接使用类似
///类似CupertinoPageRoute的形式来进行push，暂不支持！！！
```

参数名 | 意义 | 是否可选
-------- | -----| -----
`name` | 页面在路由表中的名字 | NO
`withContainer` | 是否需伴随原生容器弹出 | YES
`arguments` | 携带到下一页面的参数 | YES
`opaque` | 页面是否透明(下面会再次提到) | YES

### 2.开启透明弹窗(flutter中开启弹窗)

- 不开启新容器的flutter内部弹窗(推荐)

```dart
///首先你需要在你的routeFactory路由表中这样指定弹窗页面
'dialogPage': (settings, uniqueId) {
    return PageRouteBuilder<dynamic>(

      ///透明弹窗页面这个需要是false
      opaque: false,

      ///背景蒙版颜色
      barrierColor: Colors.black12,
      settings: settings,
      pageBuilder: (_, __, ___) => DialogPage());
},

///然后这样弹出即可
BoostNavigator.instance.push("dialogPage");

///如果要接收参数返回参数的形式
final result = await BoostNavigator.instance.push("dialogPage");
```


- 开启新容器的flutter内部弹窗

dialogPage在路由表中的注册方法可以同上
```dart
 BoostNavigator.instance.push("dialogPage",
        withContainer: true,

        ///如果开启新容器，需要指定opaque为false
        opaque: false);
```


### 3.关闭页面API
```dart
///pop一次
BoostNavigator.instance.pop(result);

///pop两次,首次需要用await等待
await BoostNavigator.instance.pop(result);
BoostNavigator.instance.pop(result);
```

参数名 | 意义 | 是否可选
-------- | -----| -----
`result` | 返回的参数 | YES
 - ##### 一定注意：如果打开的Flutter页面不带容器（例如，通过原生的Navigator.push，或者withContainer=false），那么pop时，result可以是任何类型；如果打开的页面是一个带容器的Flutter页面（即，withContainer=true）或一个Native页面，那么result需要是`Map<String, dynamic>`类型。



## Android
### 1.开启新页面统一API
```java
FlutterBoostRouteOptions options = new FlutterBoostRouteOptions.Builder()
                .pageName("pageName")
                .arguments(new HashMap<>())
                .requestCode(1111)
                .build();
FlutterBoost.instance().open(options);
```


### 2.关闭页面API（用得比较少）
```java
FlutterBoost.instance().close(uniqueId);
```


### 3.页面关闭时，返回结果给前一个页面
#### 3.1 Flutter页面退出时，传递参数给上一个Native页面

FlutterBoostActivity示例如下：
```java
// 1. 打开Flutter页面，等待返回结果
Intent intent = new FlutterBoostActivity.CachedEngineIntentBuilder(FlutterBoostActivity.class)
        .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.opaque)
        .destroyEngineWithActivity(false)
        .url("DialogPage")
        .urlParams(params)
        .build(this);
startActivityForResult(intent, REQUEST_CODE);

@Override
public void onActivityResult(int requestCode, int resultCode, Intent data) {
    // 处理返回结果
}
```

```dart
// 2. 关闭Flutter页面，返回结果
InkWell(
child: Container(
    padding: const EdgeInsets.all(8.0),
    margin: const EdgeInsets.all(8.0),
    color: Colors.yellow,
    child: Text(
        'Pop with Navigator',
        style: TextStyle(fontSize: 22.0, color: Colors.blue),
    )),
// 这里也可以使用: Navigator.of(context).pop({'retval' : 'I am from dart...'})
onTap: () => BoostNavigator.instance.pop({'retval' : 'I am from dart...'}),
),
```

注：如需定制，请自行实现FlutterViewContainer的finishContainer接口。

#### 3.2 Native页面退出时，传递参数给上一个Flutter页面

```dart
// 1. 从Flutter页面打开一个Native页面，并处理返回结果
InkWell(
child: Container(
    padding: const EdgeInsets.all(8.0),
    margin: const EdgeInsets.all(8.0),
    color: Colors.yellow,
    child: Text(
        'open native page',
        style: TextStyle(fontSize: 22.0, color: Colors.black),
    )),
onTap: () => BoostNavigator.instance
    .push("ANativePage") // Native页面路由
    .then((value) => print('retval:$value')),
),
```

```java
// 2. Native页面退出时，返回结果
@Override
public void finish() {
    Intent intent = new Intent();
    intent.putExtra("msg","This message is from Native!!!");
    intent.putExtra("bool", true);
    intent.putExtra("int", 666);
    setResult(Activity.RESULT_OK, intent);  // 返回结果给dart
    super.finish();
}
```

#### 3.3 Flutter页面退出时，传递参数给上一个Flutter页面
```dart
// 1. 打开一个Flutter页面，并处理返回结果
InkWell(
child: Container(
    padding: const EdgeInsets.all(8.0),
    margin: const EdgeInsets.all(8.0),
    color: Colors.yellow,
    child: Text(
        'open transparent widget',
        style: TextStyle(fontSize: 22.0, color: Colors.black),
    )),
onTap: () {
    // 如果withContainer为false时，也可以使用原生的Navigator
    final result = await BoostNavigator.instance.push("AFlutterPage",
        withContainer: true, opaque: false);
},
),

// 2. 页面关闭，并返回结果
// 这里也可以使用原生的 Navigator
onTap: () => BoostNavigator.instance.pop({'retval' : 'I am from dart...'}),
```

## iOS

### 1.开启新页面统一API

```swift
let options = FlutterBoostRouteOptions()
options.pageName = "mainPage"
options.arguments = ["key" :"value"]

//页面是否透明（用于透明弹窗场景），若不设置，默认情况下为true
options.opaque = true

//这个是push操作完成的回调，而不是页面关闭的回调！！！！
options.completion = { completion in
    print("open operation is completed")
}

//这个是页面关闭并且返回数据的回调，回调实际需要根据您的Delegate中的popRoute来调用
options.onPageFinished = { dic in
    print(dic)
}

FlutterBoost.instance().open(options)
```

### 2.关闭页面API（用得比较少）
```swift
FlutterBoost.instance().close(uniqueId)
```

### 3.原生参数回传flutter
```swift
//这里pageName是你push的这个原生的pageName，而不是上一个flutter页面的pageName
//这句话并不会退出页面
FlutterBoost.instance().sendResultToFlutter(withPageName: "pageName", arguments: ["key":"value"])
```

### 下一步：[生命周期API](https://github.com/alibaba/flutter_boost/blob/master/docs/lifecycle.md)
