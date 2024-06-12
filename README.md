<p align="center">
  <img src="flutter_boost.png">
   <b></b><br>
  <a href="README_CN.md">中文文档</a>
  <a href="https://zhuanlan.zhihu.com/p/362662962">中文介绍</a>
</p>

# Release Note
## 4.5.11

PS：Null-safety is already supported.

- Flutter SDK upgrades do not require Boost upgrades
- Simplify the architecture
- Simplify the interface
- Unified design of double-end interface
- Solved the Top Issue
- Android does not need to distinguish between AndroidX and Support

# FlutterBoost
A next-generation Flutter-Native hybrid solution. FlutterBoost is a Flutter plugin which enables hybrid integration of Flutter for your existing native apps with minimum efforts. The philosophy of FlutterBoost is to use Flutter as easy as using a WebView. Managing Native pages and Flutter pages at the same time is non-trivial in an existing App. FlutterBoost takes care of page resolution for you. The only thing you need to care about is the name of the page(usually could be an URL). 
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
        ref: '4.5.11'
```

# Version Notes
- For Flutter SDK 3.0 and above, use `4.0.1+`.
- For Flutter SDK below 3.0, use `v3.0-release.2` or earlier versions.
- The null safety versions supporting Flutter SDK 2.5.x are `3.1.0+`.
- The versions supporting Flutter SDK 3.16.x are `5.0.0+`.
- The versions supporting HarmonyOS are `[4.5.0, 5.0.0)`.


# Usage
- [Detailed Integration Steps](https://github.com/alibaba/flutter_boost/blob/master/docs/install.md)
- [Basic Routing API](https://github.com/alibaba/flutter_boost/blob/master/docs/routeAPI.md)
- [API for Page Lifecycle](https://github.com/alibaba/flutter_boost/blob/master/docs/lifecycle.md)
- [Custom API for Sending Cross-Platform Events](https://github.com/alibaba/flutter_boost/blob/master/docs/event.md)

# Contribution
- [How to File an Issue to Us](https://github.com/alibaba/flutter_boost/blob/master/docs/issue.md)
- [How to Submit a PR to Us](https://github.com/alibaba/flutter_boost/blob/master/docs/pr.md)

# FAQ
please read this document:
<a href="Frequently Asked Question.md">FAQ</a>


# License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## About Us
Alibaba-Xianyu Tech is one of the earliest and largest teams running Flutter on a large scale online in China.

In our official WeChat account, we have carefully selected exclusive Flutter content for you, both comprehensive and in-depth.

The content includes tutorials and open-source information on Flutter integration, large-scale applications, engine exploration, engineering systems, and innovative technologies.

**Architects / Backend Engineers / Client-side Engineers / Frontend Developers / Algorithm Engineers / Quality Engineers - submit your resumes through our WeChat account, there is no limit to the number of positions.**

We welcome you to join Xianyu and become a curious, happy, and influential programmer. To send your resume, please email: `tino.wjf@alibaba-inc.com`

Subscribe at:

<img src="https://img.alicdn.com/tfs/TB17Ki5XubviK0jSZFNXXaApXXa-656-656.png" width="328px" height="328px">

[For English](https://twitter.com/xianyutech "For English")
