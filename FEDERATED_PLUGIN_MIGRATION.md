# 联邦插件迁移指南 / Federated Plugin Migration Guide

[English version below](#english-version)

## 中文版本

### 概述

flutter_boost 现在已经迁移到联邦插件（Federated Plugin）架构。这种架构将插件分为多个包，提供更好的模块化、可维护性和可测试性。

### 什么是联邦插件？

联邦插件是一种 Flutter 插件架构模式，将插件分为以下几个部分：

1. **主包** (`flutter_boost`): 应用开发者直接依赖的包，提供 Dart API
2. **平台接口包** (`flutter_boost_platform_interface`): 定义平台接口的纯 Dart 包
3. **平台实现包**: 各平台的具体实现
   - `flutter_boost_android`: Android 平台实现
   - `flutter_boost_ios`: iOS 平台实现

### 迁移步骤

#### 对于大多数用户

**好消息！** 如果您只是使用 flutter_boost 插件，**不需要做任何改变**。联邦插件架构对应用开发者是透明的。

您的 `pubspec.yaml` 文件保持不变：

```yaml
dependencies:
  flutter_boost:
    git:
      url: 'https://github.com/alibaba/flutter_boost.git'
      ref: 'main'  # 或指定的版本标签
```

#### 对于插件开发者和贡献者

如果您正在为 flutter_boost 贡献代码或开发基于它的插件：

1. **平台特定代码的位置**：
   - Android 代码现在位于 `flutter_boost_android/android/` 目录
   - iOS 代码现在位于 `flutter_boost_ios/ios/` 目录
   - Dart 平台接口位于 `flutter_boost_platform_interface/lib/` 目录

2. **测试各个包**：
   ```bash
   # 测试平台接口
   cd flutter_boost_platform_interface
   flutter test
   
   # 测试 Android 实现
   cd flutter_boost_android
   flutter test
   
   # 测试 iOS 实现
   cd flutter_boost_ios
   flutter test
   
   # 测试主包
   cd flutter_boost
   flutter test
   ```

3. **构建示例应用**：
   ```bash
   cd example
   flutter pub get
   flutter run
   ```

### 新架构的优势

1. **更好的模块化**：平台特定代码被清晰地分离
2. **独立版本管理**：各平台可以独立更新和发布
3. **更容易测试**：每个包都可以独立测试
4. **更清晰的依赖**：平台接口明确定义了契约
5. **更好的可维护性**：代码组织更清晰

### 常见问题

**Q: 我需要更新我的代码吗？**  
A: 不需要。应用层 API 保持完全向后兼容。

**Q: 性能会受到影响吗？**  
A: 不会。联邦插件架构只是改变了代码的组织方式，不会影响运行时性能。

**Q: 如果我遇到问题怎么办？**  
A: 请在 GitHub 上提交 issue，我们会及时帮助您。

---

## English Version

### Overview

flutter_boost has now been migrated to a federated plugin architecture. This architecture splits the plugin into multiple packages, providing better modularity, maintainability, and testability.

### What is a Federated Plugin?

A federated plugin is a Flutter plugin architecture pattern that splits a plugin into:

1. **App-facing package** (`flutter_boost`): The package that app developers depend on directly, providing Dart APIs
2. **Platform interface package** (`flutter_boost_platform_interface`): A pure Dart package that defines the platform interface
3. **Platform implementation packages**: Platform-specific implementations
   - `flutter_boost_android`: Android implementation
   - `flutter_boost_ios`: iOS implementation

### Migration Steps

#### For Most Users

**Good news!** If you're just using the flutter_boost plugin, **you don't need to change anything**. The federated plugin architecture is transparent to app developers.

Your `pubspec.yaml` remains the same:

```yaml
dependencies:
  flutter_boost:
    git:
      url: 'https://github.com/alibaba/flutter_boost.git'
      ref: 'main'  # or your specific version tag
```

#### For Plugin Developers and Contributors

If you're contributing to flutter_boost or developing plugins based on it:

1. **Location of platform-specific code**:
   - Android code is now in `flutter_boost_android/android/`
   - iOS code is now in `flutter_boost_ios/ios/`
   - Dart platform interface is in `flutter_boost_platform_interface/lib/`

2. **Testing individual packages**:
   ```bash
   # Test platform interface
   cd flutter_boost_platform_interface
   flutter test
   
   # Test Android implementation
   cd flutter_boost_android
   flutter test
   
   # Test iOS implementation
   cd flutter_boost_ios
   flutter test
   
   # Test main package
   cd flutter_boost
   flutter test
   ```

3. **Building the example app**:
   ```bash
   cd example
   flutter pub get
   flutter run
   ```

### Benefits of the New Architecture

1. **Better modularity**: Platform-specific code is clearly separated
2. **Independent versioning**: Each platform can be updated and released independently
3. **Easier testing**: Each package can be tested independently
4. **Clearer dependencies**: Platform interface explicitly defines the contract
5. **Better maintainability**: Clearer code organization

### FAQ

**Q: Do I need to update my code?**  
A: No. The app-facing API remains fully backward compatible.

**Q: Will performance be affected?**  
A: No. The federated plugin architecture only changes how the code is organized, not runtime performance.

**Q: What if I encounter issues?**  
A: Please file an issue on GitHub, and we'll help you promptly.
