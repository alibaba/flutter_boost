import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'boost_navigator.dart';
import 'flutter_boost_app.dart';

class BoostContainer {
  BoostContainer({this.key, this.pageInfo}) {
    _pages.add(BoostPage.create(pageInfo));
  }

  static BoostContainer of(BuildContext context) {
    final state = context.findAncestorStateOfType<BoostContainerState>();
    return state.container;
  }

  final LocalKey key;

  final PageInfo pageInfo;

  final List<BoostPage<dynamic>> _pages = <BoostPage<dynamic>>[];

  /// Getter for a list that cannot be changed
  List<BoostPage<dynamic>> get pages => List.unmodifiable(_pages);

  BoostPage<dynamic> get topPage => pages.last;

  /// Number of pages
  int numPages() => pages.length;

  Future<T> addPage<T extends Object>(BoostPage page) {
    if (page != null) {
      _pages.add(page);
      refresh();
      return page.popped;
    }
    return null;
  }

  void removePage(BoostPage page, {dynamic result}) {
    if (page != null) {
      _pages.remove(page);
      refresh();
      page.didComplete(result);
    }
  }

  NavigatorState get navigator => _navKey.currentState;
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  void refresh() {
    if (_refreshListener != null) {
      _refreshListener();
    }
  }

  VoidCallback _refreshListener;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'BoostContainer')}(name:${pageInfo.pageName},'
      ' pages:$pages)';
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
      var otherWidget = other;
      return container.pageInfo.uniqueId ==
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

  void _updatePagesList(BoostPage page, dynamic result) {
    assert(container.topPage == page);
    container.removePage(page, result: result);
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
    return HeroControllerScope(
        controller: HeroController(),
        child: NavigatorExt(
          key: widget.container._navKey,
          pages: List<Page<dynamic>>.of(widget.container.pages),
          onPopPage: (route, result) {
            if (route.didPop(result)) {
              assert(route.settings is BoostPage);
              _updatePagesList(route.settings as BoostPage, result);
              return true;
            }
            return false;
          },
          observers: <NavigatorObserver>[
            BoostNavigatorObserver(),
          ],
        ));
  }

  @override
  void dispose() {
    container._refreshListener = null;
    super.dispose();
  }
}

class NavigatorExt extends Navigator {
  NavigatorExt({
    Key key,
    List<Page<dynamic>> pages,
    PopPageCallback onPopPage,
    List<NavigatorObserver> observers,
  }) : super(
            key: key, pages: pages, onPopPage: onPopPage, observers: observers);

  @override
  NavigatorState createState() => NavigatorExtState();
}

class NavigatorExtState extends NavigatorState {
  @override
  void pop<T extends Object>([T result]) {
    // Taking over container page
    if (!canPop()) {
      BoostNavigator.instance.pop(result);
    } else {
      super.pop(result);
    }
  }
}
