// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'flutter_container.dart';

/// Information about the navigation stack.
class StackInfo {
  StackInfo({
    this.ids,
    this.containers,
  });

  List<String?>? ids;
  Map<String?, FlutterContainer?>? containers;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['ids'] = ids;
    final Map<String?, Object?>? containersMap = containers?.map(
      (String? key, FlutterContainer? value) => MapEntry<String?, Object?>(
        key,
        value?.encode(),
      ),
    );
    pigeonMap['containers'] = containersMap;
    return pigeonMap;
  }

  static StackInfo decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    final Map<String?, FlutterContainer?>? containersMap = 
      (pigeonMap['containers'] as Map<Object?, Object?>?)?.map(
        (Object? key, Object? value) => MapEntry<String?, FlutterContainer?>(
          key as String?,
          value != null ? FlutterContainer.decode(value) : null,
        ),
      );
    return StackInfo(
      ids: (pigeonMap['ids'] as List<Object?>?)?.cast<String?>(),
      containers: containersMap,
    );
  }
}
