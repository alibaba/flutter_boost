import 'package:flutter/material.dart';
import 'package:flutter_boost/logger.dart';

///observer for all pages visibility
abstract class GlobalPageVisiblityObserver {
  void onPageCreate(Route<dynamic> route);

  void onPageShow(Route<dynamic> route, {bool isForegroundEvent = false});

  void onPageHide(Route<dynamic> route, {bool isBackgroundEvent = false});

  void onPageDestroy(Route<dynamic> route);
}

///observer for single page visibility
abstract class PageVisibilityObserver {
  void onPageCreate();

  void onPageShow({bool isForegroundEvent});

  void onPageHide({bool isBackgroundEvent});

  void onPageDestroy();
}

class PageVisibilityBinding {
  PageVisibilityBinding._();

  static final PageVisibilityBinding instance = PageVisibilityBinding._();

  ///listeners for single page event
  final Map<Route<dynamic>, Set<PageVisibilityObserver>> _listeners =
      <Route<dynamic>, Set<PageVisibilityObserver>>{};

  ///listeners for all pages event
  final Set<GlobalPageVisiblityObserver> _globalListeners =
      <GlobalPageVisiblityObserver>{};

  /// Registers the given object and route as a binding observer.
  void addObserver(PageVisibilityObserver observer, Route<dynamic> route) {
    assert(observer != null);
    assert(route != null);
    final Set<PageVisibilityObserver> observers =
        _listeners.putIfAbsent(route, () => <PageVisibilityObserver>{});
    if (observers.add(observer)) {
      observer.onPageCreate();
      // dispatchGlobalCreateEvent(route);
      observer.onPageShow();
      // dispatchGlobalPageShowEvent(route);
    }
    Logger.log(
        'page_visibility, #addObserver, $observers, ${route.settings.name}');
  }

  /// Unregisters the given observer.
  void removeObserver(PageVisibilityObserver observer) {
    assert(observer != null);
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      observers?.remove(observer);
    }
    Logger.log('page_visibility, #removeObserver, $observer');
  }

  ///Register [observer] to [_globalListeners] set
  void addGlobalObserver(GlobalPageVisiblityObserver observer) {
    assert(observer != null);
    _globalListeners.add(observer);

    Logger.log('page_visibility, #addGlobalObserver, $observer');
  }

  ///Register [observer] from [_globalListeners] set
  void removeGlobalObserver(GlobalPageVisiblityObserver observer) {
    assert(observer != null);

    _globalListeners.remove(observer);

    Logger.log('page_visibility, #removeGlobalObserver, $observer');
  }

  void dispatchPageShowEvent(Route<dynamic> route, {bool isForegroundEvent = false}) {
    if (route == null) {
      return;
    }

    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        try {
          observer.onPageShow(isForegroundEvent:isForegroundEvent);
        } catch (e) {
          Logger.log(e);
        }
      }
    }
    Logger.log(
        'page_visibility, #dispatchPageShowEvent, ${route.settings.name}');

    dispatchGlobalPageShowEvent(route, isForegroundEvent: isForegroundEvent);
  }

  void dispatchPageHideEvent(Route<dynamic> route, {bool isBackgroundEvent = false}) {
    if (route == null) {
      return;
    }

    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        try {
          observer.onPageHide(isBackgroundEvent:isBackgroundEvent);
        } catch (e) {
          Logger.log(e);
        }
      }
    }
    Logger.log(
        'page_visibility, #dispatchPageHideEvent, ${route.settings.name}');

    dispatchGlobalPageHideEvent(route, isBackgroundEvent: isBackgroundEvent);
  }

  void dispatchPageDestoryEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        try {
          observer.onPageDestroy();
        } catch (e) {
          Logger.log(e);
        }
      }
    }

    Logger.log(
        'page_visibility, #dispatchPageDestoryEvent, ${route.settings.name}');

    dispatchGlobalPageDestroyEvent(route);
  }

  // void dispatchBackgroundEvent(Route<dynamic> route) {
  //   if (route == null) {
  //     return;
  //   }
  //
  //   final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
  //   if (observers != null) {
  //     for (PageVisibilityObserver observer in observers) {
  //       try {
  //         observer.onPageHide(isBackgroundEvent: true);
  //       } catch (e) {
  //         Logger.log(e);
  //       }
  //     }
  //   }
  //   Logger.log(
  //       'page_visibility, #dispatchBackgroundEvent, ${route.settings.name}');
  //
  //   dispatchGlobalPageHideEvent(route, isBackgroundEvent: true);
  // }

  // void dispatchForegroundEvent(Route<dynamic> route) {
  //   if (route == null) {
  //     return;
  //   }
  //
  //   final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
  //   if (observers != null) {
  //     for (PageVisibilityObserver observer in observers) {
  //       try {
  //         observer.onPageShow(isForegroundEvent: true);
  //       } catch (e) {
  //         Logger.log(e);
  //       }
  //     }
  //   }
  //   Logger.log(
  //       'page_visibility, #dispatchForegroundEvent, ${route.settings.name}');
  //   dispatchGlobalPageShowEvent(route, isForegroundEvent: true);
  // }

  void dispatchGlobalCreateEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }
    final List<GlobalPageVisiblityObserver> globalObserversList =
        _globalListeners.toList();

    for (GlobalPageVisiblityObserver observer in globalObserversList) {
      observer.onPageCreate(route);
    }

    Logger.log(
        'page_visibility, #dispatchGlobalCreateEvent, ${route.settings.name}');
  }

  void dispatchGlobalPageShowEvent(Route<dynamic> route,
      {bool isForegroundEvent = false}) {
    if (route == null) {
      return;
    }
    final List<GlobalPageVisiblityObserver> globalObserversList =
        _globalListeners.toList();

    for (GlobalPageVisiblityObserver observer in globalObserversList) {
      observer.onPageShow(route, isForegroundEvent: isForegroundEvent);
    }

    Logger.log(
        'page_visibility, #dispatchGlobalPageShowEvent, ${route.settings.name}');
  }

  void dispatchGlobalPageHideEvent(Route<dynamic> route,
      {bool isBackgroundEvent = false}) {
    if (route == null) {
      return;
    }
    final List<GlobalPageVisiblityObserver> globalObserversList =
        _globalListeners.toList();

    for (GlobalPageVisiblityObserver observer in globalObserversList) {
      observer.onPageHide(route, isBackgroundEvent: isBackgroundEvent);
    }

    Logger.log(
        'page_visibility, #dispatchGlobalPageHideEvent, ${route.settings.name}');
  }

  void dispatchGlobalPageDestroyEvent(Route<dynamic> route,
      {bool isBackgroundEvent = false}) {
    if (route == null) {
      return;
    }
    final List<GlobalPageVisiblityObserver> globalObserversList =
        _globalListeners.toList();

    for (GlobalPageVisiblityObserver observer in globalObserversList) {
      observer.onPageDestroy(route);
    }

    Logger.log(
        'page_visibility, #dispatchGlobalPageDestroyEvent, ${route.settings.name}');
  }
}
