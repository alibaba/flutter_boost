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
    PageVisibilityBinding.instance
        .dispatchPageCreateEvent(container.topPage.route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onContainerDidPush(container, previousContainer);
      }
    }
  }

  void containerDidPop(
      BoostContainer container, BoostContainer previousContainer) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidPop');
    PageVisibilityBinding.instance
        .dispatchPageDestroyEvent(container.topPage.route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onContainerDidPop(container, previousContainer);
      }
    }
  }

  void containerDidShow(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidShow');
    PageVisibilityBinding.instance
        .dispatchPageShowEvent(container.topPage.route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onContainerDidShow(container);
      }
    }
  }

  void containerDidHide(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidHide');
    PageVisibilityBinding.instance
        .dispatchPageHideEvent(container?.topPage.route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onContainerDidHide(container);
      }
    }
  }

  void routeDidPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.routeDidPush');
    PageVisibilityBinding.instance.dispatchPageCreateEvent(route);
    PageVisibilityBinding.instance.dispatchPageShowEvent(route);
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
    PageVisibilityBinding.instance.dispatchPageDestroyEvent(route);
    if (_observerList != null && _observerList.isNotEmpty) {
      for (BoostLifecycleObserver observer in _observerList) {
        observer.onRouteDidPop(route, previousRoute);
      }
    }
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
