<p align="center">
  <img src="flutter_boost.png">
   <b></b><br>
  <a href="README_CN.md">中文文档</a>
  <a href="https://mp.weixin.qq.com/s?__biz=MzU4MDUxOTI5NA==&mid=2247484367&idx=1&sn=fcbc485f068dae5de9f68d52607ea08f&chksm=fd54d7deca235ec86249a9e3714ec18be8b2d6dc580cae19e4e5113533a6c5b44dfa5813c4c3&scene=0&subscene=131&clicktime=1551942425&ascene=7&devicetype=android-28&version=2700033b&nettype=ctnet&abtest_cookie=BAABAAoACwASABMABAAklx4AVpkeAMSZHgDWmR4AAAA%3D&lang=zh_CN&pass_ticket=1qvHqOsbLBHv3wwAcw577EHhNjg6EKXqTfnOiFbbbaw%3D&wx_header=1">中文介绍</a>
</p>

# Release Note

Please checkout the release note for the latest 0.1.63 to see changes [0.1.63 release note](https://github.com/alibaba/flutter_boost/releases)

# FlutterBoost
A next-generation Flutter-Native hybrid solution. FlutterBoost is a Flutter plugin which enables hybrid integration of Flutter for your existing native apps with minimum efforts.The philosophy of FlutterBoost is to use Flutter as easy as using a WebView. Managing Native pages and Flutter pages at the same time is non-trivial in an existing App. FlutterBoost takes care of page resolution for you. The only thing you need to care about is the name of the page(usually could be an URL). 
<a name="bf647454"></a>

# Prerequisites
You need to add Flutter to your project before moving on.The version of the flutter SDK requires v1.9.1+hotfixes, or it will compile error.



# boost version description

1. 0.1.50 is based on the flutter v1.5.4-hotfixes branch, android if other flutter versions or branches will compile incorrectly

2. 0.1.51--0.1.54 is a bugfix for 0.1.50


3. 0.1.60 is based on the flutter v1.9.1-hotfixes branch. Android does not support andriodx if other flutter branches will compile incorrectly

4. 0.1.61--0.1.62  is a bugfix for 0.1.60


5. Statement of support for androidx

 Current androidx branch is v0.1.61-androidx-hotfixes

 Is based on flutter v1.9.1-hotfixes branch, if other branches will compile incorrectly

 Synchronize with the 0.1.63 code, and bugfix also merge to this branch.



# Getting Started


## Add a dependency in you Flutter project.

Open you pubspec.yaml and add the following line to dependencies:

support branch
```json
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: '0.1.63'
```
androidx branch
```json
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: 'v0.1.61-androidx-hotfixes'
```



# Boost  Integration

Please see the boost example for details.




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
