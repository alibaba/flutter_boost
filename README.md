[![Build Status](https://travis-ci.com/alibaba/flutter_boost.svg?branch=master)](https://travis-ci.com/alibaba/flutter_boost) [![pub package](https://img.shields.io/pub/v/flutter_boost.svg)](https://pub.dartlang.org/packages/flutter_boost) [![codecov](https://codecov.io/gh/alibaba/flutter_boost/branch/master/graph/badge.svg)](https://codecov.io/gh/alibaba/flutter_boost)

<p align="center">
  <img src="flutter_boost.png">
   <b></b><br>
  <a href="README_CN.md">中文文档</a>
  <a href="https://mp.weixin.qq.com/s?__biz=MzU4MDUxOTI5NA==&mid=2247484367&idx=1&sn=fcbc485f068dae5de9f68d52607ea08f&chksm=fd54d7deca235ec86249a9e3714ec18be8b2d6dc580cae19e4e5113533a6c5b44dfa5813c4c3&scene=0&subscene=131&clicktime=1551942425&ascene=7&devicetype=android-28&version=2700033b&nettype=ctnet&abtest_cookie=BAABAAoACwASABMABAAklx4AVpkeAMSZHgDWmR4AAAA%3D&lang=zh_CN&pass_ticket=1qvHqOsbLBHv3wwAcw577EHhNjg6EKXqTfnOiFbbbaw%3D&wx_header=1">中文介绍</a>
  <a href="INTEGRATION.md">集成相关</a>
</p>

# Release Note

Please checkout the release note for the latest 1.17.1 to see changes [1.17.1 release note](https://github.com/alibaba/flutter_boost/releases)

# FlutterBoost
A next-generation Flutter-Native hybrid solution. FlutterBoost is a Flutter plugin which enables hybrid integration of Flutter for your existing native apps with minimum efforts.The philosophy of FlutterBoost is to use Flutter as easy as using a WebView. Managing Native pages and Flutter pages at the same time is non-trivial in an existing App. FlutterBoost takes care of page resolution for you. The only thing you need to care about is the name of the page(usually could be an URL). 
<a name="bf647454"></a>

# Prerequisites
You need to add Flutter to your project before moving on.The version of the flutter SDK requires to match boost's version, or it will compile error.



# boost version description

| Flutter Boost Release Version | Support Flutter SDK Version | Description                                                  | Support AndroidX？ |
| --------------------- | --------------------------- | ------------------------------------------------------------ | ------------------ |
| 1.9.1+2              | 1.9.1-hotfixes              | Rename the version number and start supporting androidx by default | Yes                 |
| 1.12.13+3               | 1.12.13-hotfixes              | 支持androidx  | Yes                 |
| 1.17.1               | 1.17.1              | 支持androidx  | Yes                 |





| Flutter Boost Branch | Support Flutter SDK Version | Description                                                  | Support AndroidX？ |
| --------------------- | --------------------------- | ------------------------------------------------------------ | ------------------ |
| v1.9.1-hotfixes         | 1.9.1-hotfixes          | for androidx  | Yes                 |
| v1.12.13-hotfixes       | 1.12.13-hotfixes         | for androidx                                                        | Yes                 |
| v1.17.1-hotfixes       | 1.17.1         | for androidx                                                        | Yes                 |

# Getting Started


## Add a dependency in you Flutter project.

Open you pubspec.yaml and add the following line to dependencies:

androidx branch
```json
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: '1.17.1'
```



# Boost  Integration

Please see

1. Boost detail example

2. integrated document <a href="INTEGRATION.md">Integration </a>

# FAQ
please read this document:
<a href="Frequently Asked Question.md">FAQ</a>


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
