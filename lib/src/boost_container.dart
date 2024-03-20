// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'boost_channel.dart';
import 'boost_navigator.dart';
import 'flutter_boost_app.dart';

/// This class is an abstraction of native containers
/// Each of which has a bunch of pages in the [NavigatorExt]
class BoostContainer extends ChangeNotifier {
  BoostContainer({this.key, required this.pageInfo}) {
    _pages.add(BoostPage.create(pageInfo));
  }

  static BoostContainer? of(BuildContext context) {
    final state = context.findAncestorStateOfType<BoostContainerState>();
    return state?.container;
  }

  /// The local key
  final LocalKey? key;

  /// The pageInfo for this container
  final PageInfo pageInfo;

  /// A list of page in this container
  final List<BoostPage<dynamic>> _pages = <BoostPage<dynamic>>[];

  /// Getter for a list that cannot be changed
  List<BoostPage<dynamic>> get pages => List.unmodifiable(_pages);

  /// To get the top page in this container
  BoostPage<dynamic> get topPage => pages.last;

  /// Number of pages
  int numPages() => pages.length;

  /// The navigator used in this container
  NavigatorState? get navigator => _navKey.currentState;

  /// The [GlobalKey] to get the [NavigatorExt] in this container
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  /// intercept page's backPressed event
  VoidCallback? backPressedHandler;

  /// add a [BoostPage] in this container and return its future result
  Future<T>? addPage<T extends Object?>(BoostPage page) {
    if (numPages() == 1) {
      /// disable the native slide pop gesture
      /// only iOS will receive this event ,Android will do nothing
      BoostChannel.instance.disablePopGesture(containerId: pageInfo.uniqueId!);
    }
    _pages.add(page);
    notifyListeners();
    return page.popped.then((value) => value as T);
  }

  /// remove a specific [BoostPage]
  void removePage(BoostPage? page, {dynamic result}) {
    if (page != null) {
      if (removePageInternal(page, result: result)) {
        notifyListeners();
      }
    }
  }

  bool removePageInternal(BoostPage page, {dynamic result}) {
    if (numPages() == 2) {
      /// enable the native slide pop gesture
      /// only iOS will receive this event, Android will do nothing
      BoostChannel.instance.enablePopGesture(containerId: pageInfo.uniqueId!);
    }
    bool retVal = _pages.remove(page);
    if (retVal) {
      page.didComplete(result);
    }
    return retVal;
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'BoostContainer')}(name:${pageInfo.pageName},'
      ' pages:$pages)';
}

/// The Widget build for a [BoostContainer]
///
/// It overrides the "==" and "hashCode",
/// to avoid rebuilding when its parent element call element.updateChild
class BoostContainerWidget extends StatefulWidget {
  BoostContainerWidget({LocalKey? key, required this.container})
      : super(key: container.key);

  /// The container this widget belong
  final BoostContainer container;

  @override
  State<BoostContainerWidget> createState() => BoostContainerState();

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
    container.addListener(_onRouteChanged);
  }

  @override
  void didUpdateWidget(covariant BoostContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      oldWidget.container.removeListener(_onRouteChanged);
      container.addListener(_onRouteChanged);
    }
  }

  ///just refresh
  void _onRouteChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
        controller: HeroController(),
        child: NavigatorExt(
          key: container._navKey,
          pages: List<Page<dynamic>>.of(container.pages),
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
    container.removeListener(_onRouteChanged);
    super.dispose();
  }
}

/// This class is make user call
/// "Navigator.pop()" is equal to BoostNavigator.instance.pop()
class NavigatorExt extends Navigator {
  const NavigatorExt({
    Key? key,
    required List<Page<dynamic>> pages,
    PopPageCallback? onPopPage,
    required List<NavigatorObserver> observers,
  }) : super(
            key: key, pages: pages, onPopPage: onPopPage, observers: observers);

  @override
  NavigatorState createState() => NavigatorExtState();
}

class NavigatorExtState extends NavigatorState {
  @override
  Future<T?> pushNamed<T extends Object?>(String routeName,
      {Object? arguments}) {
    if (arguments == null) {
      return BoostNavigator.instance
          .push(routeName)
          .then((value) => value as T);
    }

    if (arguments is Map<String, dynamic>) {
      return BoostNavigator.instance
          .push(routeName, arguments: arguments)
          .then((value) => value as T);
    }

    if (arguments is Map) {
      return BoostNavigator.instance
          .push(routeName, arguments: Map<String, dynamic>.from(arguments))
          .then((value) => value as T);
    } else {
      assert(false, "arguments should be Map<String,dynamic> or Map");
      return BoostNavigator.instance
          .push(routeName)
          .then((value) => value as T);
    }
  }

  @override
  void pop<T extends Object?>([T? result]) {
    // Taking over container page
    if (!canPop()) {
      BoostNavigator.instance.pop(result ?? {});
    } else {
      super.pop(result);
    }
  }
}
