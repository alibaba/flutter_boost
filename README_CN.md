<p align="center">
  <img src="flutter_boost.png">
</p>


# Release Note

 请查看最新版本0.1.64的release note 确认变更，[0.1.64 release note](https://github.com/alibaba/flutter_boost/releases)。

# FlutterBoost

新一代Flutter-Native混合解决方案。 FlutterBoost是一个Flutter插件，它可以轻松地为现有原生应用程序提供Flutter混合集成方案。FlutterBoost的理念是将Flutter像Webview那样来使用。在现有应用程序中同时管理Native页面和Flutter页面并非易事。 FlutterBoost帮你处理页面的映射和跳转，你只需关心页面的名字和参数即可（通常可以是URL）。


# 前置条件

在继续之前，您需要将Flutter集成到你现有的项目中。flutter sdk 的版本需要 v1.9.1-hotfixes，否则会编译失败.

# FAQ
请阅读这篇文章:
<a href="Frequently Asked Question.md">FAQ</a>

# boost 版本说明

| Flutter Boost 版本 | 支持的 Flutter SDK 版本 | Description                                                  | 是否支持 AndroidX？ |
| ----------------------- | ----------------------- | ------------------------------------------------------------ | ------------------- |
| 0.1.50                  | 1.5.4-hotfixes          | android 如果其他 flutter 版本或者分支会编译错误。            | No                  |
| 0.1.51-0.1.59           | 1.5.4-hotfixes          | 0.1.50 的 bugfix。                                           | No                  |
| 0.1.60                  | 1.9.1-hotfixes          | android 如果其他 flutter 分支会编译错误。                    | No                  |
| 0.1.63                  | 1.9.1-hotfixes          | 和 0.1.60 代码同步， bugfix 也会合入该分支，如果其他分支会编译错误。 | No                  |
| 0.1.61-0.1.69           | 1.9.1-hotfixes          | 0.1.60 的 bugfix。                                           | No                  |
| 1.9.1+2              | 1.9.1-hotfixes              | 版本号重新命名，开始默认支持androidx  | Yes                 |
| 1.12.13               | 1.12.13 -hotfixes              | 支持androidx  | Yes                 |





| Flutter Boost 分支 | 支持的 Flutter SDK 版本 | Description                                                  | Support AndroidX？ |
| --------------------- | --------------------------- | ------------------------------------------------------------ | ------------------ |
| v1.9.1-hotfixes         | 1.9.1-hotfixes          | for androidx  | Yes                 |
| task/task_v1.9.1_support_hotfixes| 1.9.1-hotfixes  | for support  | NO                 |
| v1.12.13-hotfixes       | 1.12.13-hotfixes         | for androidx                                                        | Yes                 |
| task/task_v1.12.13_support_hotfixes| 1.12.13-hotfixes  | for support  | NO                 |



# 安装

## 在Flutter项目中添加依赖项。

打开pubspec.yaml并将以下行添加到依赖项：

androidx branch
```json
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: '1.12.13'
```
support branch
```json
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: 'task/task_v1.12.13_support_hotfixes'

```



## boost集成

 集成请看boost的Examples



# 问题反馈群（钉钉群)

<img width="200" src="https://img.alicdn.com/tfs/TB1JSzVeYY1gK0jSZTEXXXDQVXa-892-1213.jpg">



# 许可证
该项目根据MIT许可证授权 - 有关详细信息，请参阅[LICENSE.md]（LICENSE.md）文件
<a name="Acknowledgments"> </a>



## 关于我们
阿里巴巴-闲鱼技术是国内最早也是最大规模线上运行Flutter的团队。

我们在公众号中为你精选了Flutter独家干货，全面而深入。

内容包括：Flutter的接入、规模化应用、引擎探秘、工程体系、创新技术等教程和开源信息。

**架构／服务端／客户端／前端／算法／质量工程师 在公众号中投递简历，名额不限哦**

欢迎来闲鱼做一个好奇、幸福、有影响力的程序员，简历投递：tino.wjf@alibaba-inc.com

订阅地址

<img src="https://img.alicdn.com/tfs/TB17Ki5XubviK0jSZFNXXaApXXa-656-656.png" width="328px" height="328px">

[For English](https://twitter.com/xianyutech "For English")
