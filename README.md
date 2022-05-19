<p align="center">
  <img src="flutter_boost.png">
   <b></b><br>
  <a href="README_CN.md">中文文档</a>
  <a href="https://zhuanlan.zhihu.com/p/362662962">中文介绍</a>
</p>

# Release Note
v3.0-release.2

PS：Here for null-safety https://github.com/alibaba/flutter_boost/tree/null-safety

- 1. Flutter SDK upgrades do not require Boost upgrades
- 2. Simplify the architecture
- 3. Simplify the interface
- 4. Unified design of double-end interface
- 5. Solved the Top Issue
- 6. Android does not need to distinguish between AndroidX and Support
# FlutterBoost
A next-generation Flutter-Native hybrid solution. FlutterBoost is a Flutter plugin which enables hybrid integration of Flutter for your existing native apps with minimum efforts.The philosophy of FlutterBoost is to use Flutter as easy as using a WebView. Managing Native pages and Flutter pages at the same time is non-trivial in an existing App. FlutterBoost takes care of page resolution for you. The only thing you need to care about is the name of the page(usually could be an URL). 
<a name="bf647454"></a>

# Prerequisites

1. Before proceeding, you need to integrate Flutter into your existing project.
2. The Flutter SDK version supported by Boost 3.0 is >= 1.22


# Getting Started


## Add a dependency in you Flutter project.

Open you pubspec.yaml and add the following line to dependencies:

``` yaml
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: 'v3.0-release.2'
```



# Boost  Integration


# 使用文档

- [集成详细步骤](https://github.com/alibaba/flutter_boost/blob/master/docs/install.md)
- [基本的路由API](https://github.com/alibaba/flutter_boost/blob/master/docs/routeAPI.md)
- [页面生命周期监测相关API](https://github.com/alibaba/flutter_boost/blob/master/docs/lifecycle.md)
- [自定义发送跨端事件API](https://github.com/alibaba/flutter_boost/blob/master/docs/event.md)

# 建设文档
- [如何向我们提issue](https://github.com/alibaba/flutter_boost/blob/master/docs/issue.md)
- [如何向我们提PR](https://github.com/alibaba/flutter_boost/blob/master/docs/pr.md)


# FAQ
please read this document:
<a href="Frequently Asked Question.md">FAQ</a>


# License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


## 关于我们

阿里巴巴-闲鱼技术是国内最早也是最大规模线上运行Flutter的团队。

我们在公众号中为你精选了Flutter独家干货，全面而深入。

内容包括：Flutter的接入、规模化应用、引擎探秘、工程体系、创新技术等教程和开源信息。

**架构／服务端／客户端／前端／算法／质量工程师 在公众号中投递简历，名额不限哦**

欢迎来闲鱼做一个好奇、幸福、有影响力的程序员，简历投递：tino.wjf@alibaba-inc.com

订阅地址

<img src="https://img.alicdn.com/tfs/TB17Ki5XubviK0jSZFNXXaApXXa-656-656.png" width="328px" height="328px">

[For English](https://twitter.com/xianyutech "For English")
