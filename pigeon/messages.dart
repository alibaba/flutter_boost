// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  input: 'pigeon/messages.dart',
  dartOut: 'lib/src/messages.dart',
  copyrightHeader: 'pigeon/copyright.txt',
  javaOptions: JavaOptions(package: 'com.idlefish.flutterboost'),
  javaOut: 'android/src/main/java/com/idlefish/flutterboost/Messages.java',
  objcOptions: ObjcOptions(prefix: 'FB'),
  objcHeaderOut: 'ios/Classes/messages.h',
  objcSourceOut: 'ios/Classes/messages.m',
))
class CommonParams {
  bool? opaque;
  String? key;
  String? pageName;
  String? uniqueId;
  Map<String?, Object?>? arguments;
}

// TODO: [pigeon] Generics are supported, but can currently only
// be used with nullable types (example: List<int?>).
// https://pub.dev/packages/pigeon
class StackInfo {
  List<String?>? ids;
  Map<String?, FlutterContainer?>? containers;
}

class FlutterContainer {
  List<FlutterPage?>? pages;
}

class FlutterPage {
  bool? withContainer;
  String? pageName;
  String? uniqueId;
  Map<String?, Object?>? arguments;
}

@HostApi()
abstract class NativeRouterApi {
  void pushNativeRoute(CommonParams param);
  void pushFlutterRoute(CommonParams param);
  @async
  void popRoute(CommonParams param);
  StackInfo getStackFromHost();
  void saveStackToHost(StackInfo stack);
  void sendEventToNative(CommonParams params);
}

@FlutterApi()
abstract class FlutterRouterApi {
  void pushRoute(CommonParams param);
  void popRoute(CommonParams param);
  void removeRoute(CommonParams param);
  void onForeground(CommonParams param);
  void onBackground(CommonParams param);
  void onNativeResult(CommonParams param);
  void onContainerShow(CommonParams param);
  void onContainerHide(CommonParams param);
  void sendEventToFlutter(CommonParams param);
  void onBackPressed();
}
