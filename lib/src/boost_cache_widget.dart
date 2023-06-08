// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// Widget with caching function, solve：
///1.Page rebuild caused by overlay；
///2.Page rebuild caused by navigator2.0；
class BoostCacheWidget extends StatefulWidget {
  final String uniqueId;
  final WidgetBuilder builder;

  const BoostCacheWidget(
      {required this.uniqueId, required this.builder, Key? key})
      : super(key: key);

  @override
  State<BoostCacheWidget> createState() => _BoostCacheWidgetState();
}

class _BoostCacheWidgetState extends State<BoostCacheWidget> {
  late Widget _cacheWidget;
  String? _oldUniqueId;

  @override
  Widget build(BuildContext context) {
    final bool shouldUpdate = _oldUniqueId != widget.uniqueId;
    if (shouldUpdate) {
      _oldUniqueId = widget.uniqueId;
      _cacheWidget = widget.builder(context);
    }
    return _cacheWidget;
  }
}
