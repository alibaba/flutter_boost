# Flutter Boost 联邦插件迁移记录

本文档记录了将 `flutter_boost` 插件迁移为 Flutter 联邦插件架构的过程。

## 迁移概述

### 什么是联邦插件

联邦插件（Federated Plugin）是 Flutter 官方推荐的插件架构，它将插件拆分为多个独立的包：

1. **平台接口包** (`flutter_boost_platform_interface`): 定义平台无关的抽象接口
2. **平台实现包** (`flutter_boost_android`, `flutter_boost_ios`): 各平台的具体实现
3. **应用层包** (`flutter_boost`): 对外暴露 API，聚合各平台实现

### 迁移优势

- 更好的代码组织和模块化
- 支持添加新平台而无需修改现有代码
- 允许第三方提供替代的平台实现
- 更清晰的依赖关系

---

## 迁移步骤详细记录

### 1. 创建 `flutter_boost_platform_interface` 包

**目录**: `flutter_boost_platform_interface/`

#### 1.1 创建 `pubspec.yaml`

**文件**: `flutter_boost_platform_interface/pubspec.yaml`

**修改内容**:
- 创建新的 pubspec.yaml 文件
- 添加 `plugin_platform_interface` 依赖
- 保持与主包相同的版本号 (5.0.2)

**原因**: 平台接口包需要依赖 `plugin_platform_interface` 来实现标准的平台接口模式。

#### 1.2 迁移 `messages.dart`

**文件**: `flutter_boost_platform_interface/lib/src/messages.dart`

**修改内容**:
- 将原 `lib/src/messages.dart` 复制到平台接口包
- 保持 Pigeon 生成的代码不变

**原因**: `messages.dart` 包含了 `NativeRouterApi` 和 `FlutterRouterApi` 的定义，是 Flutter 与原生平台通信的核心接口，应该放在平台接口层。

#### 1.3 创建平台接口抽象类

**文件**: `flutter_boost_platform_interface/lib/src/flutter_boost_platform_interface.dart`

**修改内容**:
- 创建 `FlutterBoostPlatform` 抽象类
- 继承 `PlatformInterface`
- 定义平台接口方法

**原因**: 根据联邦插件最佳实践，平台接口需要继承 `PlatformInterface` 并提供标准的实例访问模式。

#### 1.4 创建方法通道默认实现

**文件**: `flutter_boost_platform_interface/lib/src/method_channel_flutter_boost.dart`

**修改内容**:
- 创建 `MethodChannelFlutterBoost` 类
- 实现 `FlutterBoostPlatform` 接口
- 提供基于方法通道的默认实现

**原因**: 提供默认的平台通信实现，各平台实现包可以继承或替换此实现。

#### 1.5 创建主库导出文件

**文件**: `flutter_boost_platform_interface/lib/flutter_boost_platform_interface.dart`

**修改内容**:
- 创建库导出文件
- 导出所有公开 API

**原因**: 统一的导出点，方便其他包引用。

---

### 2. 创建 `flutter_boost_android` 包

**目录**: `flutter_boost_android/`

#### 2.1 创建 `pubspec.yaml`

**文件**: `flutter_boost_android/pubspec.yaml`

**修改内容**:
- 创建新的 pubspec.yaml 文件
- 添加对 `flutter_boost_platform_interface` 的依赖
- 配置 `flutter.plugin.implements` 为 `flutter_boost`
- 配置 `flutter.plugin.platforms.android` 指定原生插件类

**原因**: 联邦插件的平台实现包需要声明它实现了哪个插件，并指定原生插件类。

#### 2.2 迁移 Android 原生代码

**操作**: 将 `android/` 目录复制到 `flutter_boost_android/android/`

**修改内容**:
- 复制所有 Android 原生代码
- 保持包名 `com.idlefish.flutterboost` 不变
- 保持插件类 `FlutterBoostPlugin` 不变

**原因**: Android 原生代码无需修改，只需移动到对应的平台实现包中。

#### 2.3 创建空的 Dart 库文件

**文件**: `flutter_boost_android/lib/flutter_boost_android.dart`

**修改内容**:
- 创建空的库文件（平台实现包不需要导出 Dart 代码）

**原因**: 平台实现包主要提供原生实现，Dart 层面不需要导出内容。

---

### 3. 创建 `flutter_boost_ios` 包

**目录**: `flutter_boost_ios/`

#### 3.1 创建 `pubspec.yaml`

**文件**: `flutter_boost_ios/pubspec.yaml`

**修改内容**:
- 创建新的 pubspec.yaml 文件
- 添加对 `flutter_boost_platform_interface` 的依赖
- 配置 `flutter.plugin.implements` 为 `flutter_boost`
- 配置 `flutter.plugin.platforms.ios` 指定原生插件类

**原因**: 联邦插件的平台实现包需要声明它实现了哪个插件，并指定原生插件类。

#### 3.2 迁移 iOS 原生代码

**操作**: 将 `ios/` 目录复制到 `flutter_boost_ios/ios/`

**修改内容**:
- 复制所有 iOS 原生代码
- 重命名 podspec 文件为 `flutter_boost_ios.podspec`
- 更新 podspec 中的 `s.name` 为 `flutter_boost_ios`
- 更新版本号为 `5.0.2`
- 更新 homepage 为正确的 GitHub 地址

**原因**: iOS 原生代码需要移动到对应的平台实现包，并更新 podspec 配置。

#### 3.3 创建空的 Dart 库文件

**文件**: `flutter_boost_ios/lib/flutter_boost_ios.dart`

**修改内容**:
- 创建空的库文件（平台实现包不需要导出 Dart 代码）

**原因**: 平台实现包主要提供原生实现，Dart 层面不需要导出内容。

---

### 4. 修改主包 `flutter_boost`

**目录**: `flutter_boost/`（根目录）

#### 4.1 更新 `pubspec.yaml`

**文件**: `pubspec.yaml`

**修改内容**:
- 添加对 `flutter_boost_platform_interface` 的依赖
- 添加对 `flutter_boost_android` 的依赖
- 添加对 `flutter_boost_ios` 的依赖
- 修改 `flutter.plugin.platforms.android` 配置，使用 `default_package: flutter_boost_android`
- 修改 `flutter.plugin.platforms.ios` 配置，使用 `default_package: flutter_boost_ios`
- 移除原来的 `package` 和 `pluginClass` 配置

**原因**: 联邦插件的主包需要聚合所有平台实现包，并使用 `default_package` 指定默认的平台实现。

#### 4.2 更新 `lib/flutter_boost.dart`

**文件**: `lib/flutter_boost.dart`

**修改内容**:
- 添加从 `flutter_boost_platform_interface` 导出核心类型
- 保持其他导出不变

**原因**: 主包需要重新导出平台接口中的公共类型，保持 API 向后兼容。

#### 4.3 更新 `lib/src/messages.dart`

**文件**: `lib/src/messages.dart`

**修改内容**:
- 将文件内容替换为重新导出语句
- 从 `flutter_boost_platform_interface` 重新导出所有消息类型

**原因**: 避免代码重复，统一使用平台接口包中的定义。

---

### 5. 更新 Example 目录

**目录**: `example/`

#### 5.1 更新 `example/pubspec.yaml`

**文件**: `example/pubspec.yaml`

**修改内容**:
- 更新 SDK 版本约束为 `>=3.2.0 <4.0.0`
- 将 `flutter_boost` 从 `dev_dependencies` 移动到 `dependencies`

**原因**: 
- SDK 版本需要与主包保持一致
- `flutter_boost` 是 example 的运行时依赖，应放在 `dependencies` 中

---

## 目录结构对比

### 迁移前

```
flutter_boost/
├── android/                    # Android 原生代码
├── ios/                        # iOS 原生代码
├── lib/
│   ├── flutter_boost.dart      # 主库文件
│   └── src/
│       ├── messages.dart       # Pigeon 生成的消息代码
│       └── ...                 # 其他 Dart 文件
├── example/                    # 示例项目
└── pubspec.yaml
```

### 迁移后

```
flutter_boost/
├── flutter_boost_platform_interface/   # 平台接口包
│   ├── lib/
│   │   ├── flutter_boost_platform_interface.dart
│   │   └── src/
│   │       ├── flutter_boost_platform_interface.dart
│   │       ├── method_channel_flutter_boost.dart
│   │       └── messages.dart
│   └── pubspec.yaml
├── flutter_boost_android/              # Android 平台实现包
│   ├── android/                        # Android 原生代码
│   ├── lib/
│   │   └── flutter_boost_android.dart
│   └── pubspec.yaml
├── flutter_boost_ios/                  # iOS 平台实现包
│   ├── ios/                            # iOS 原生代码
│   ├── lib/
│   │   └── flutter_boost_ios.dart
│   └── pubspec.yaml
├── android/                            # 保留原 Android 目录（可选删除）
├── ios/                                # 保留原 iOS 目录（可选删除）
├── lib/
│   ├── flutter_boost.dart              # 主库文件（更新）
│   └── src/
│       ├── messages.dart               # 重新导出
│       └── ...                         # 其他 Dart 文件（不变）
├── example/                            # 示例项目（更新）
└── pubspec.yaml                        # 更新依赖配置
```

---

## 功能保持不变

此次迁移仅涉及代码组织结构的调整，以下功能保持完全不变：

1. **Flutter 路由 API**: `BoostNavigator`, `FlutterBoostApp` 等
2. **原生通信**: `NativeRouterApi`, `FlutterRouterApi`
3. **生命周期管理**: `BoostLifecycleBinding`, `PageVisibilityBinding`
4. **容器管理**: `BoostContainer`, `BoostContainerWidget`
5. **事件通道**: `BoostChannel`
6. **拦截器**: `BoostInterceptor`
7. **所有原生实现**: Android Java 代码和 iOS Objective-C 代码

---

## 验证清单

- [x] 平台接口包结构正确
- [x] Android 平台实现包结构正确
- [x] iOS 平台实现包结构正确
- [x] 主包依赖配置正确
- [x] Example 依赖配置正确
- [x] 所有公开 API 保持向后兼容
- [x] 原生代码无修改

---

## 参考资料

- [Flutter 联邦插件文档](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#federated-plugins)
- [plugin_platform_interface 包](https://pub.dev/packages/plugin_platform_interface)
- [Flutter 插件最佳实践](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#plugin-platforms)
