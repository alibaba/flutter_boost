<p align="center">
  <img src="flutter_boost.png">
</p>


# Release Note

v3.0-release.2

PS：空安全版本(null-safety)请看这里 https://github.com/alibaba/flutter_boost/tree/null-safety


- 1.flutter sdk升级不需要升级boost
- 2.简化架构
- 3.简化接口
- 4.双端接口设计统一
- 5.解决了top issue
- 6.android不需要区分androidx 和support

# FlutterBoost

新一代Flutter-Native混合解决方案。 FlutterBoost是一个Flutter插件，它可以轻松地为现有原生应用程序提供Flutter混合集成方案。FlutterBoost的理念是将Flutter像Webview那样来使用。在现有应用程序中同时管理Native页面和Flutter页面并非易事。 FlutterBoost帮你处理页面的映射和跳转，你只需关心页面的名字和参数即可（通常可以是URL）。


# 前置条件

1.在继续之前，您需要将Flutter集成到你现有的项目中。
2.boost3.0版本支持的flutter sdk 版本为 >= 1.22

## 将FlutterBoost添加到你的Flutter工程依赖中

打开你的工程的pubspec.yaml ，增加以下依赖

```json
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: 'v3.0-release.2'
```

# 使用文档

- [集成详细步骤](https://github.com/alibaba/flutter_boost/blob/master/docs/install.md)
- [基本的路由API](https://github.com/alibaba/flutter_boost/blob/master/docs/routeAPI.md)
- [页面生命周期监测相关API](https://github.com/alibaba/flutter_boost/blob/master/docs/lifecycle.md)
- [自定义发送跨端事件API](https://github.com/alibaba/flutter_boost/blob/master/docs/event.md)

# 建设文档
- [如何向我们提issue](https://github.com/alibaba/flutter_boost/blob/master/docs/issue.md)
- [如何向我们提PR](https://github.com/alibaba/flutter_boost/blob/master/docs/pr.md)


# FAQ

请阅读这篇文章:
<a href="Frequently Asked Question.md">FAQ</a>


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
