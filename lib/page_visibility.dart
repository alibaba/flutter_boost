import 'package:flutter/material.dart';
import 'package:flutter_boost/logger.dart';

abstract class PageVisibilityObserver {
  void onPageCreate();
  void onPageShow({bool isForegroundEvent});
  void onPageHide({bool isBackgroundEvent});
  void onPageDestory();

  String uniqueId();
}

class PageVisibilityBinding {
  PageVisibilityBinding._();
  static final PageVisibilityBinding instance = PageVisibilityBinding._();

  final Map<Route<dynamic>, Set<PageVisibilityObserver>> _listeners =
      <Route<dynamic>, Set<PageVisibilityObserver>>{};

  /// Registers the given object and route as a binding observer.
  void addObserver(PageVisibilityObserver observer, Route<dynamic> route) {
    assert(observer != null);
    assert(route != null);
    final Set<PageVisibilityObserver> observers =
        _listeners.putIfAbsent(route, () => <PageVisibilityObserver>{});
    if (observers.add(observer)) {
      observer.onPageCreate();
      observer.onPageShow();
    }
    Logger.log('page_visibility, #addObserver, $observer, $route');
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

  void dispatchPageShowEventForRoute(Route<dynamic> route) {
    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        observer.onPageShow();
      }
    }
    Logger.log('page_visibility, #dispatchPageShowEventForRoute, $route');
  }

  void dispatchPageHideEventForRoute(Route<dynamic> route) {
    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        observer.onPageHide();
      }
    }
    Logger.log('page_visibility, #dispatchPageHideEventForRoute, $route');
  }

  void dispatchPageShowEvent(String uniqueId) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      for (PageVisibilityObserver observer in observers) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageShow();
        }
      }
    }
    Logger.log('page_visibility, #dispatchPageShowEvent, $uniqueId');
  }

  void dispatchPageHideEvent(String uniqueId) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      for (PageVisibilityObserver observer in observers) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageHide();
        }
      }
    }
    Logger.log('page_visibility, #dispatchPageHideEvent, $uniqueId');
  }

  void dispatchPageDestoryEvent(String uniqueId) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      for (PageVisibilityObserver observer in observers) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageDestory();
        }
      }
    }
    Logger.log('page_visibility, #dispatchPageDestoryEvent, $uniqueId');
  }

  void dispatchBackgroundEvent(String uniqueId) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      for (PageVisibilityObserver observer in observers) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageHide(isBackgroundEvent: true);
        }
      }
    }
    Logger.log('page_visibility, #dispatchBackgroundEvent, $uniqueId');
  }

  void dispatchForegroundEvent(String uniqueId) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      for (PageVisibilityObserver observer in observers) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageShow(isForegroundEvent: true);
        }
      }
    }
    Logger.log('page_visibility, #dispatchForegroundEvent, $uniqueId');
  }
}
