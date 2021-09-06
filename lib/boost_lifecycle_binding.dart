import 'package:flutter/widgets.dart';

import 'boost_container.dart';
import 'logger.dart';
import 'page_visibility.dart';

/// Observer for Container
mixin BoostLifecycleObserver {
  void onContainerDidPush(
      BoostContainer container, BoostContainer previousContainer) {}

  void onContainerDidShow(BoostContainer container) {}

  void onContainerDidHide(BoostContainer container) {}

  void onContainerDidPop(
      BoostContainer container, BoostContainer previousContainer) {}

  void onRouteDidPush(Route<dynamic> route, Route<dynamic> previousRoute) {}

  void onRouteDidPop(Route<dynamic> route, Route<dynamic> previousRoute) {}

  void onAppDidEnterForeground(BoostContainer container) {}

  void onAppDidEnterBackground(BoostContainer container) {}
}

class BoostLifecycleBinding {
  BoostLifecycleBinding._();

  static final BoostLifecycleBinding instance = BoostLifecycleBinding._();

  final List<BoostLifecycleObserver> _observerList = <BoostLifecycleObserver>[];

  List<NavigatorObserver> navigatorObserverList = <NavigatorObserver>[];

  /// This set contains all of the ids that has been shown.
  /// It is to solve the quesition that the page can't receive onPageShow
  /// callback event when showing on screen first time.
  /// Because it is not be added to [PageVisibilityBinding] before
  /// dispatching [containerDidShow] event
  Set<String> hasShownPageIds = <String>{};


  void addNavigatorObserver(NavigatorObserver observer) {
    navigatorObserverList.add(observer);
  }

  bool removeNavigatorObserver(NavigatorObserver observer) {
    return navigatorObserverList.remove(observer);
  }

  void addBoostLifecycleObserver(BoostLifecycleObserver observer) {
    _observerList.add(observer);
  }

  bool removeBoostLifecycleObserver(BoostLifecycleObserver observer) {
    return _observerList.remove(observer);
  }

  void containerDidPush(
      BoostContainer container, BoostContainer previousContainer) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidPush');
    PageVisibilityBinding.instance.dispatchPagePushEvent(container.topPage.route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onContainerDidPush(container, previousContainer);
      }
    }
  }

  void containerDidPop(
      BoostContainer container, BoostContainer previousContainer) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidPop');
    PageVisibilityBinding.instance.dispatchPagePopEvent(container.topPage.route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onContainerDidPop(container, previousContainer);
      }
    }

    // When container pop,remove the id from set to avoid
    // this id still remain in the set
    final id = container.pageInfo.uniqueId;
    hasShownPageIds.remove(id);
  }

  void containerDidShow(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidShow');
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onContainerDidShow(container);
      }
    }

    final id = container?.pageInfo?.uniqueId;
    assert(id != null);
    if (!hasShownPageIds.contains(id)) {
      hasShownPageIds.add(id);

      // This case indicates it is the first time that this container show
      // So we should dispatch event using
      // PageVisibilityBinding.dispatchPageShowEventOnPageShowFirstTime
      // to ensure the page will receive callback
      PageVisibilityBinding.instance
          .dispatchPageShowEventOnPageShowFirstTime(container.topPage.route);
    } else {
      PageVisibilityBinding.instance
          .dispatchPageShowEvent(container.topPage.route);
    }
  }

  void containerDidHide(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidHide');
    PageVisibilityBinding.instance.dispatchPageHideEvent(container?.topPage?.route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onContainerDidHide(container);
      }
    }
  }

  void routeDidPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.routeDidPush');
    PageVisibilityBinding.instance.dispatchPagePushEvent(route);
    PageVisibilityBinding.instance
        .dispatchPageShowEventOnPageShowFirstTime(route);
    PageVisibilityBinding.instance.dispatchPageHideEvent(previousRoute);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onRouteDidPush(route, previousRoute);
      }
    }
  }

  void routeDidPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.routeDidPop');
    PageVisibilityBinding.instance.dispatchPageHideEvent(route);
    PageVisibilityBinding.instance.dispatchPageShowEvent(previousRoute);
    PageVisibilityBinding.instance.dispatchPagePopEvent(route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onRouteDidPop(route, previousRoute);
      }
    }
  }

  void routeDidRemove(Route<dynamic> route) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.routeDidRemove');
    PageVisibilityBinding.instance.dispatchPagePopEvent(route);
  }

  void appDidEnterForeground(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.appDidEnterForeground');
    PageVisibilityBinding.instance
        .dispatchPageForgroundEvent(container.topPage.route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onAppDidEnterForeground(container);
      }
    }
  }

  void appDidEnterBackground(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.appDidEnterBackground');
    PageVisibilityBinding.instance
        .dispatchPageBackgroundEvent(container.topPage.route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onAppDidEnterBackground(container);
      }
    }
  }
}
