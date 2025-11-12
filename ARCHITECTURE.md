# FlutterBoost 联邦插件架构文档 / Federated Plugin Architecture

[English version below](#english-version)

## 中文版本

### 架构概览

FlutterBoost 现采用联邦插件架构，将代码组织为四个独立的包：

```
flutter_boost/
├── flutter_boost/                      # 主包（app-facing package）
├── flutter_boost_platform_interface/   # 平台接口包
├── flutter_boost_android/              # Android 平台实现
└── flutter_boost_ios/                  # iOS 平台实现
```

### 包的职责

#### 1. flutter_boost (主包)
- **位置**: `/flutter_boost`
- **职责**: 
  - 提供应用开发者使用的 Dart API
  - 导出所有公共接口
  - 依赖平台接口和平台实现包
  - 保持向后兼容性
- **关键文件**:
  - `lib/flutter_boost.dart` - 主导出文件
  - `lib/src/*` - 核心 Dart 实现
  - `pubspec.yaml` - 配置为联邦插件（使用 `default_package`）

#### 2. flutter_boost_platform_interface (平台接口)
- **位置**: `/flutter_boost_platform_interface`
- **职责**:
  - 定义平台接口抽象类 `FlutterBoostPlatform`
  - 提供数据模型类（CommonParams, StackInfo 等）
  - 提供默认的 MethodChannel 实现
  - 作为平台实现的契约
- **关键文件**:
  - `lib/src/flutter_boost_platform.dart` - 平台接口定义
  - `lib/src/method_channel_flutter_boost.dart` - 默认实现
  - `lib/src/common_params.dart` - 数据模型
  - `lib/src/stack_info.dart` - 导航栈信息
  - `lib/src/flutter_container.dart` - 容器模型
  - `lib/src/flutter_page.dart` - 页面模型

#### 3. flutter_boost_android (Android 实现)
- **位置**: `/flutter_boost_android`
- **职责**:
  - 实现 Android 平台的原生代码
  - 提供 Dart 绑定层
  - 注册为 `flutter_boost` 的 Android 实现
- **关键文件**:
  - `lib/flutter_boost_android.dart` - Dart 绑定层
  - `android/src/main/java/com/idlefish/flutterboost/` - Java 实现
  - `pubspec.yaml` - 配置 `implements: flutter_boost`

#### 4. flutter_boost_ios (iOS 实现)
- **位置**: `/flutter_boost_ios`
- **职责**:
  - 实现 iOS 平台的原生代码
  - 提供 Dart 绑定层
  - 注册为 `flutter_boost` 的 iOS 实现
- **关键文件**:
  - `lib/flutter_boost_ios.dart` - Dart 绑定层
  - `ios/Classes/` - Objective-C/Swift 实现
  - `ios/flutter_boost_ios.podspec` - CocoaPods 配置
  - `pubspec.yaml` - 配置 `implements: flutter_boost`

### 依赖关系

```
应用
  └── flutter_boost
       ├── flutter_boost_platform_interface
       ├── flutter_boost_android (自动包含，当平台为 Android 时)
       │    └── flutter_boost_platform_interface
       └── flutter_boost_ios (自动包含，当平台为 iOS 时)
            └── flutter_boost_platform_interface
```

### 通信流程

1. **应用 → Flutter**: 应用使用 `flutter_boost` 的公共 API
2. **Flutter → 平台接口**: `flutter_boost` 调用 `FlutterBoostPlatform` 接口
3. **平台接口 → 平台实现**: 根据当前平台，自动路由到对应的实现
4. **平台实现 → 原生代码**: 通过 MethodChannel 与原生代码通信

### 核心接口

#### FlutterBoostPlatform

```dart
abstract class FlutterBoostPlatform extends PlatformInterface {
  Future<void> pushNativeRoute(CommonParams param);
  Future<void> pushFlutterRoute(CommonParams param);
  Future<void> popRoute(CommonParams param);
  Future<StackInfo> getStackFromHost();
  Future<void> saveStackToHost(StackInfo stack);
  Future<void> sendEventToNative(CommonParams params);
}
```

### 数据模型

#### CommonParams
用于跨平台通信的通用参数：
- `opaque`: 是否不透明
- `key`: 事件键
- `pageName`: 页面名称
- `uniqueId`: 唯一标识符
- `arguments`: 参数字典

#### StackInfo
导航栈信息：
- `ids`: 页面 ID 列表
- `containers`: 容器字典

#### FlutterContainer
Flutter 容器：
- `pages`: 页面列表

#### FlutterPage
Flutter 页面：
- `withContainer`: 是否带容器
- `pageName`: 页面名称
- `uniqueId`: 唯一标识符
- `arguments`: 参数字典

### 为什么使用联邦插件架构？

#### 优势

1. **模块化**: 各平台代码清晰分离
2. **独立开发**: 各平台可以独立开发和测试
3. **独立版本**: 各平台可以独立发布版本
4. **清晰的接口**: 平台接口明确定义了契约
5. **更好的测试**: 每个包都可以独立测试
6. **代码复用**: 平台接口可以被多个实现复用
7. **向后兼容**: 应用层 API 保持不变

#### 实际应用

- **大型团队**: Android 和 iOS 团队可以独立工作
- **定制实现**: 可以创建自定义平台实现
- **测试**: 可以使用 mock 实现进行单元测试
- **维护**: 更容易定位和修复平台特定的问题

### 开发指南

#### 添加新的平台方法

1. 在 `flutter_boost_platform_interface` 中定义接口：
```dart
abstract class FlutterBoostPlatform {
  Future<void> newMethod(CommonParams param);
}
```

2. 在 `flutter_boost_android` 中实现：
```dart
class FlutterBoostAndroid extends FlutterBoostPlatform {
  @override
  Future<void> newMethod(CommonParams param) {
    // Android 实现
  }
}
```

3. 在 `flutter_boost_ios` 中实现：
```dart
class FlutterBoostIOS extends FlutterBoostPlatform {
  @override
  Future<void> newMethod(CommonParams param) {
    // iOS 实现
  }
}
```

4. 在 `flutter_boost` 中使用：
```dart
await FlutterBoostPlatform.instance.newMethod(params);
```

#### 测试

每个包都应该有自己的测试：

```bash
# 测试平台接口
cd flutter_boost_platform_interface && flutter test

# 测试 Android 实现
cd flutter_boost_android && flutter test

# 测试 iOS 实现
cd flutter_boost_ios && flutter test

# 测试主包
cd flutter_boost && flutter test
```

### 迁移和兼容性

- ✅ 完全向后兼容
- ✅ 现有应用无需修改代码
- ✅ API 保持不变
- ✅ 性能无影响

详见 [迁移指南](FEDERATED_PLUGIN_MIGRATION.md)。

---

## English Version

### Architecture Overview

FlutterBoost now uses a federated plugin architecture, organizing the code into four independent packages:

```
flutter_boost/
├── flutter_boost/                      # App-facing package
├── flutter_boost_platform_interface/   # Platform interface package
├── flutter_boost_android/              # Android implementation
└── flutter_boost_ios/                  # iOS implementation
```

### Package Responsibilities

#### 1. flutter_boost (Main Package)
- **Location**: `/flutter_boost`
- **Responsibilities**:
  - Provides Dart APIs for app developers
  - Exports all public interfaces
  - Depends on platform interface and implementation packages
  - Maintains backward compatibility
- **Key Files**:
  - `lib/flutter_boost.dart` - Main export file
  - `lib/src/*` - Core Dart implementation
  - `pubspec.yaml` - Configured as federated plugin (using `default_package`)

#### 2. flutter_boost_platform_interface (Platform Interface)
- **Location**: `/flutter_boost_platform_interface`
- **Responsibilities**:
  - Defines platform interface abstract class `FlutterBoostPlatform`
  - Provides data model classes (CommonParams, StackInfo, etc.)
  - Provides default MethodChannel implementation
  - Acts as contract for platform implementations
- **Key Files**:
  - `lib/src/flutter_boost_platform.dart` - Platform interface definition
  - `lib/src/method_channel_flutter_boost.dart` - Default implementation
  - `lib/src/common_params.dart` - Data model
  - `lib/src/stack_info.dart` - Navigation stack info
  - `lib/src/flutter_container.dart` - Container model
  - `lib/src/flutter_page.dart` - Page model

#### 3. flutter_boost_android (Android Implementation)
- **Location**: `/flutter_boost_android`
- **Responsibilities**:
  - Implements Android platform native code
  - Provides Dart binding layer
  - Registers as Android implementation of `flutter_boost`
- **Key Files**:
  - `lib/flutter_boost_android.dart` - Dart binding layer
  - `android/src/main/java/com/idlefish/flutterboost/` - Java implementation
  - `pubspec.yaml` - Configured with `implements: flutter_boost`

#### 4. flutter_boost_ios (iOS Implementation)
- **Location**: `/flutter_boost_ios`
- **Responsibilities**:
  - Implements iOS platform native code
  - Provides Dart binding layer
  - Registers as iOS implementation of `flutter_boost`
- **Key Files**:
  - `lib/flutter_boost_ios.dart` - Dart binding layer
  - `ios/Classes/` - Objective-C/Swift implementation
  - `ios/flutter_boost_ios.podspec` - CocoaPods configuration
  - `pubspec.yaml` - Configured with `implements: flutter_boost`

### Dependency Relationships

```
App
  └── flutter_boost
       ├── flutter_boost_platform_interface
       ├── flutter_boost_android (auto-included when platform is Android)
       │    └── flutter_boost_platform_interface
       └── flutter_boost_ios (auto-included when platform is iOS)
            └── flutter_boost_platform_interface
```

### Communication Flow

1. **App → Flutter**: App uses public APIs from `flutter_boost`
2. **Flutter → Platform Interface**: `flutter_boost` calls `FlutterBoostPlatform` interface
3. **Platform Interface → Platform Implementation**: Automatically routes to the correct implementation based on platform
4. **Platform Implementation → Native Code**: Communicates with native code via MethodChannel

### Core Interfaces

#### FlutterBoostPlatform

```dart
abstract class FlutterBoostPlatform extends PlatformInterface {
  Future<void> pushNativeRoute(CommonParams param);
  Future<void> pushFlutterRoute(CommonParams param);
  Future<void> popRoute(CommonParams param);
  Future<StackInfo> getStackFromHost();
  Future<void> saveStackToHost(StackInfo stack);
  Future<void> sendEventToNative(CommonParams params);
}
```

### Data Models

#### CommonParams
Common parameters for cross-platform communication:
- `opaque`: Whether opaque
- `key`: Event key
- `pageName`: Page name
- `uniqueId`: Unique identifier
- `arguments`: Arguments dictionary

#### StackInfo
Navigation stack information:
- `ids`: List of page IDs
- `containers`: Dictionary of containers

#### FlutterContainer
Flutter container:
- `pages`: List of pages

#### FlutterPage
Flutter page:
- `withContainer`: Whether with container
- `pageName`: Page name
- `uniqueId`: Unique identifier
- `arguments`: Arguments dictionary

### Why Use Federated Plugin Architecture?

#### Benefits

1. **Modularity**: Clear separation of platform-specific code
2. **Independent Development**: Each platform can be developed and tested independently
3. **Independent Versioning**: Each platform can release versions independently
4. **Clear Interface**: Platform interface explicitly defines the contract
5. **Better Testing**: Each package can be tested independently
6. **Code Reuse**: Platform interface can be reused by multiple implementations
7. **Backward Compatibility**: App-facing API remains unchanged

#### Practical Applications

- **Large Teams**: Android and iOS teams can work independently
- **Custom Implementations**: Can create custom platform implementations
- **Testing**: Can use mock implementations for unit testing
- **Maintenance**: Easier to locate and fix platform-specific issues

### Development Guide

#### Adding a New Platform Method

1. Define the interface in `flutter_boost_platform_interface`:
```dart
abstract class FlutterBoostPlatform {
  Future<void> newMethod(CommonParams param);
}
```

2. Implement in `flutter_boost_android`:
```dart
class FlutterBoostAndroid extends FlutterBoostPlatform {
  @override
  Future<void> newMethod(CommonParams param) {
    // Android implementation
  }
}
```

3. Implement in `flutter_boost_ios`:
```dart
class FlutterBoostIOS extends FlutterBoostPlatform {
  @override
  Future<void> newMethod(CommonParams param) {
    // iOS implementation
  }
}
```

4. Use in `flutter_boost`:
```dart
await FlutterBoostPlatform.instance.newMethod(params);
```

#### Testing

Each package should have its own tests:

```bash
# Test platform interface
cd flutter_boost_platform_interface && flutter test

# Test Android implementation
cd flutter_boost_android && flutter test

# Test iOS implementation
cd flutter_boost_ios && flutter test

# Test main package
cd flutter_boost && flutter test
```

### Migration and Compatibility

- ✅ Fully backward compatible
- ✅ Existing apps don't need to modify code
- ✅ API remains unchanged
- ✅ No performance impact

See [Migration Guide](FEDERATED_PLUGIN_MIGRATION.md) for details.
