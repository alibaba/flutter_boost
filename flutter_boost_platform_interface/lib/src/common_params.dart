// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Common parameters used for cross-platform communication.
class CommonParams {
  CommonParams({
    this.opaque,
    this.key,
    this.pageName,
    this.uniqueId,
    this.arguments,
  });

  bool? opaque;
  String? key;
  String? pageName;
  String? uniqueId;
  Map<String?, Object?>? arguments;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['opaque'] = opaque;
    pigeonMap['key'] = key;
    pigeonMap['pageName'] = pageName;
    pigeonMap['uniqueId'] = uniqueId;
    pigeonMap['arguments'] = arguments;
    return pigeonMap;
  }

  static CommonParams decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return CommonParams(
      opaque: pigeonMap['opaque'] as bool?,
      key: pigeonMap['key'] as String?,
      pageName: pigeonMap['pageName'] as String?,
      uniqueId: pigeonMap['uniqueId'] as String?,
      arguments: (pigeonMap['arguments'] as Map<Object?, Object?>?)?.cast<String?, Object?>(),
    );
  }
}
