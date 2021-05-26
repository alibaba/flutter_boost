# 基本路由API部分

## Dart 部分
### 1.开启新页面统一API
```dart
BoostNavigator.instance.push(
    "yourPage", //required
    withContainer: false, //optional
    arguments: {"key","value"}, //optional
    opaque: true, //optional,default value is true
);
```

参数名 | 意义 | 是否可选
-------- | -----| -----
`name` | 页面在路由表中的名字 | NO
`withContainer` | 是否需伴随原生容器弹出 | YES 
`arguments` | 携带到下一页面的参数 | YES
`opaque` | 页面是否透明(下面会再次提到) | YES

### 2.开启透明弹窗(flutter中开启，原生开启flutter弹窗请移步下方原生相关API)

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
 - ##### 一定注意，当result返回给flutter页面的时候，可以是任何形式，如果返回给原生页面，需要是`Map<String, dynamic>`类型



## Android

## iOS


### 下一步：[生命周期API](https://github.com/alibaba/flutter_boost/blob/task/doc/docs/lifecycle.md)
