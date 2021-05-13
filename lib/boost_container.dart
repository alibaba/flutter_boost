import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'boost_navigator.dart';
import 'flutter_boost_app.dart';

class BoostContainer {
  BoostContainer({this.key, this.pageInfo}) {
    pages.add(BoostPage.create(pageInfo));
  }

  static BoostContainer of(BuildContext context) {
    final state = context.findAncestorStateOfType<BoostContainerState>();
    return state.container;
  }

  final LocalKey key;

  final PageInfo pageInfo;

  final List<BoostPage<dynamic>> _pages = <BoostPage<dynamic>>[];

  List<BoostPage<dynamic>> get pages => _pages;

  BoostPage<dynamic> get topPage => pages.last;

  int get size => pages.length;

  NavigatorState get navigator => _navKey.currentState;
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  void refresh() {
    if (_refreshListener != null) {
      _refreshListener();
    }
  }

  VoidCallback _refreshListener;
}

class BoostContainerWidget extends StatefulWidget {
  BoostContainerWidget({LocalKey key, this.container})
      : super(key: container.key);

  final BoostContainer container;

  @override
  State<StatefulWidget> createState() => BoostContainerState();

  @override
  // ignore: invalid_override_of_non_virtual_member
  bool operator ==(Object other) {
    if (other is BoostContainerWidget) {
      BoostContainerWidget otherWidget = other;
      return this.container.pageInfo.uniqueId ==
          otherWidget.container.pageInfo.uniqueId;
    }
    return super == other;
  }

  @override
  // ignore: invalid_override_of_non_virtual_member
  int get hashCode => container.pageInfo.uniqueId.hashCode;
}

class BoostContainerState extends State<BoostContainerWidget> {
  BoostContainer get container => widget.container;

  void _updatePagesList() {
    container.pages.removeLast();
  }

  @override
  void initState() {
    super.initState();
    container._refreshListener = refreshContainer;
  }

  @override
  void didUpdateWidget(covariant BoostContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      oldWidget.container._refreshListener = null;
      container._refreshListener = refreshContainer;
    }
  }

  void refreshContainer() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.container._navKey,
      pages: List<Page<dynamic>>.of(widget.container.pages),
      onPopPage: (route, result) {
        if (route.didPop(result)) {
          _updatePagesList();
          return true;
        }
        return false;
      },
      observers: <NavigatorObserver>[
        BoostNavigatorObserver(),
      ],
    );
  }

  @override
  void dispose() {
    container._refreshListener = null;
    super.dispose();
  }
}
