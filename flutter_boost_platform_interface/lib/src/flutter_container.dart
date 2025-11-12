// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'flutter_page.dart';

/// Represents a container for Flutter pages.
class FlutterContainer {
  FlutterContainer({
    this.pages,
  });

  List<FlutterPage?>? pages;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['pages'] = pages?.map((FlutterPage? page) => page?.encode()).toList();
    return pigeonMap;
  }

  static FlutterContainer decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return FlutterContainer(
      pages: (pigeonMap['pages'] as List<Object?>?)?.map((Object? page) => 
        page != null ? FlutterPage.decode(page) : null).toList(),
    );
  }
}
