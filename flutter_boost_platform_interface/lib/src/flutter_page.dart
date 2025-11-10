// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Represents a Flutter page in the navigation stack.
class FlutterPage {
  FlutterPage({
    this.withContainer,
    this.pageName,
    this.uniqueId,
    this.arguments,
  });

  bool? withContainer;
  String? pageName;
  String? uniqueId;
  Map<String?, Object?>? arguments;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['withContainer'] = withContainer;
    pigeonMap['pageName'] = pageName;
    pigeonMap['uniqueId'] = uniqueId;
    pigeonMap['arguments'] = arguments;
    return pigeonMap;
  }

  static FlutterPage decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return FlutterPage(
      withContainer: pigeonMap['withContainer'] as bool?,
      pageName: pigeonMap['pageName'] as String?,
      uniqueId: pigeonMap['uniqueId'] as String?,
      arguments: (pigeonMap['arguments'] as Map<Object?, Object?>?)?.cast<String?, Object?>(),
    );
  }
}
