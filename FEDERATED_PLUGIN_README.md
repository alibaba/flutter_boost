# FlutterBoost 联邦插件架构 / Federated Plugin Architecture

## 📖 快速导航 / Quick Navigation

### 中文文档
- [架构说明](ARCHITECTURE.md) - 详细的架构设计和实现
- [迁移指南](FEDERATED_PLUGIN_MIGRATION.md) - 如何从旧版本迁移
- [实施总结](IMPLEMENTATION_SUMMARY.md) - 实施细节和技术决策
- [实施检查清单](FEDERATED_PLUGIN_CHECKLIST.md) - 完整的实施验证清单

### English Documentation
- [Architecture](ARCHITECTURE.md#english-version) - Detailed architecture design
- [Migration Guide](FEDERATED_PLUGIN_MIGRATION.md#english-version) - How to migrate
- [Implementation Summary](IMPLEMENTATION_SUMMARY.md#english-version) - Implementation details
- [Implementation Checklist](FEDERATED_PLUGIN_CHECKLIST.md) - Complete verification checklist

---

## 🎯 什么是联邦插件？/ What is a Federated Plugin?

### 中文说明

联邦插件是 Flutter 的一种插件架构模式，将一个插件分为多个独立的包：

```
传统单体插件                  →    联邦插件架构
flutter_boost                     flutter_boost (主包)
├── lib/                          ├── lib/
├── android/                      flutter_boost_platform_interface
└── ios/                          ├── lib/
                                  flutter_boost_android
                                  ├── lib/
                                  └── android/
                                  flutter_boost_ios
                                  ├── lib/
                                  └── ios/
```

### English

A federated plugin is a Flutter plugin architecture pattern that splits a plugin into multiple independent packages:

- **App-facing package**: What users depend on
- **Platform interface**: Defines the contract
- **Platform implementations**: Platform-specific code

---

## 🚀 快速开始 / Quick Start

### 对于应用开发者 / For App Developers

**好消息！你不需要做任何改变！**  
**Good news! You don't need to change anything!**

```yaml
# pubspec.yaml - 保持不变 / Stays the same
dependencies:
  flutter_boost:
    git:
      url: 'https://github.com/alibaba/flutter_boost.git'
      ref: 'main'
```

### 对于插件开发者 / For Plugin Developers

如果你想贡献代码或开发基于 FlutterBoost 的插件：

```bash
# 克隆仓库
git clone https://github.com/alibaba/flutter_boost.git
cd flutter_boost

# 查看新的包结构
ls -d flutter_boost*

# 运行测试
cd flutter_boost_platform_interface && flutter test
cd ../flutter_boost && flutter test

# 运行示例
cd example && flutter run
```

---

## 📦 包说明 / Package Description

### 1. flutter_boost_platform_interface

**作用**: 定义平台接口契约  
**Purpose**: Defines the platform interface contract

```dart
abstract class FlutterBoostPlatform extends PlatformInterface {
  Future<void> pushNativeRoute(CommonParams param);
  Future<void> pushFlutterRoute(CommonParams param);
  Future<void> popRoute(CommonParams param);
  // ... more methods
}
```

**依赖 / Dependencies**:
- `plugin_platform_interface: ^2.1.0`
- `flutter`
- `collection`

### 2. flutter_boost_android

**作用**: Android 平台实现  
**Purpose**: Android platform implementation

**包含 / Contains**:
- 19 个 Java 源文件
- Dart 绑定层
- Gradle 构建配置

**配置 / Configuration**:
```yaml
flutter:
  plugin:
    implements: flutter_boost
    platforms:
      android:
        package: com.idlefish.flutterboost
        pluginClass: FlutterBoostPlugin
```

### 3. flutter_boost_ios

**作用**: iOS 平台实现  
**Purpose**: iOS platform implementation

**包含 / Contains**:
- 12 个 Objective-C 文件
- Dart 绑定层
- CocoaPods 配置

**配置 / Configuration**:
```yaml
flutter:
  plugin:
    implements: flutter_boost
    platforms:
      ios:
        pluginClass: FlutterBoostPlugin
```

### 4. flutter_boost (主包 / Main Package)

**作用**: 用户直接依赖的包  
**Purpose**: Package that users depend on directly

**配置 / Configuration**:
```yaml
flutter:
  plugin:
    platforms:
      android:
        default_package: flutter_boost_android
      ios:
        default_package: flutter_boost_ios
```

---

## ✨ 优势 / Benefits

### 1. 模块化 / Modularity
- 平台代码清晰分离
- Clear separation of platform code

### 2. 独立性 / Independence
- 各平台可独立开发和发布
- Platforms can be developed and released independently

### 3. 可测试性 / Testability
- 每个包可独立测试
- Each package can be tested independently

### 4. 可扩展性 / Extensibility
- 容易添加新平台
- Easy to add new platforms

### 5. 可维护性 / Maintainability
- 代码组织更清晰
- Clearer code organization

---

## 🔄 工作原理 / How It Works

### 依赖关系图 / Dependency Graph

```
你的应用 / Your App
    ↓
flutter_boost
    ↓
    ├─→ flutter_boost_platform_interface (接口定义 / Interface)
    ├─→ flutter_boost_android (自动加载 / Auto-loaded on Android)
    │       ↓
    │       └─→ flutter_boost_platform_interface
    └─→ flutter_boost_ios (自动加载 / Auto-loaded on iOS)
            ↓
            └─→ flutter_boost_platform_interface
```

### 调用流程 / Call Flow

```
应用代码 / App Code
    ↓
flutter_boost API
    ↓
FlutterBoostPlatform.instance
    ↓
MethodChannelFlutterBoost (默认实现 / Default)
    ↓
MethodChannel
    ↓
原生平台 (Android/iOS) / Native Platform
```

---

## 📊 统计信息 / Statistics

### 文件统计 / File Statistics

| 包 / Package | 文件数 / Files | 代码文件 / Code | 测试 / Tests |
|--------------|---------------|----------------|--------------|
| platform_interface | 12 | 7 | 1 |
| flutter_boost_android | 26 | 20 | - |
| flutter_boost_ios | 18 | 13 | - |
| 文档 / Docs | 8 | - | - |
| **总计 / Total** | **64** | **40** | **1** |

### 代码行数 / Lines of Code

- 新增代码: ~7,400 行
- Lines added: ~7,400 lines

---

## 🧪 测试 / Testing

### 运行测试 / Run Tests

```bash
# 平台接口测试
cd flutter_boost_platform_interface
flutter test

# 主包测试  
cd flutter_boost
flutter test

# 示例应用
cd example
flutter run
```

### 测试覆盖 / Test Coverage

- ✅ CommonParams 编解码
- ✅ FlutterPage 编解码
- ✅ FlutterContainer 编解码
- ✅ StackInfo 编解码
- ✅ 平台实例管理

---

## 🔒 向后兼容性 / Backward Compatibility

### 保证 / Guarantees

✅ **API 兼容**: 所有公共 API 保持不变  
✅ **API Compatible**: All public APIs remain unchanged

✅ **使用方式**: 应用代码无需修改  
✅ **Usage**: Application code needs no changes

✅ **功能完整**: 所有现有功能保留  
✅ **Functionality**: All existing features preserved

✅ **性能**: 无性能影响  
✅ **Performance**: No performance impact

---

## 📚 深入阅读 / Further Reading

### 必读文档 / Must-Read

1. **[ARCHITECTURE.md](ARCHITECTURE.md)**
   - 完整的架构设计说明
   - Complete architecture design

2. **[FEDERATED_PLUGIN_MIGRATION.md](FEDERATED_PLUGIN_MIGRATION.md)**
   - 迁移指南和 FAQ
   - Migration guide and FAQ

### 开发者文档 / Developer Docs

3. **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)**
   - 实施细节和技术决策
   - Implementation details and technical decisions

4. **[FEDERATED_PLUGIN_CHECKLIST.md](FEDERATED_PLUGIN_CHECKLIST.md)**
   - 完整的验证清单
   - Complete verification checklist

---

## ❓ 常见问题 / FAQ

### Q: 我需要修改代码吗？
**A**: 不需要，完全向后兼容。

### Q: Do I need to modify my code?
**A**: No, it's fully backward compatible.

### Q: 性能会受影响吗？
**A**: 不会，只是改变了代码组织方式。

### Q: Will performance be affected?
**A**: No, it only changes code organization.

### Q: 如何贡献代码？
**A**: 参考 [ARCHITECTURE.md](ARCHITECTURE.md) 中的开发指南。

### Q: How to contribute?
**A**: See the development guide in [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 🤝 贡献 / Contributing

欢迎贡献代码！请参考：
- [如何提 Issue](docs/issue.md)
- [如何提 PR](docs/pr.md)

Welcome contributions! Please see:
- [How to Submit Issues](docs/issue.md)
- [How to Submit PRs](docs/pr.md)

---

## 📄 许可证 / License

MIT License - 详见 [LICENSE](LICENSE) 文件  
MIT License - See [LICENSE](LICENSE) file for details

---

## 🎉 致谢 / Acknowledgments

感谢阿里巴巴-闲鱼技术团队的支持！  
Thanks to the Alibaba-Xianyu Tech Team!

---

**最后更新 / Last Updated**: 2025-11-10  
**版本 / Version**: 5.0.2 (Federated)
