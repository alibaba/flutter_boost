import 'package:flutter/material.dart';

enum ChangeReason {
  unknown,
  routePushed,
  routePopped,
  routeReorder,
  viewPushed,
  viewPopped,
  foreground,
  background,
}

abstract class PageVisibilityObserver {
  void onPageShow(ChangeReason reason);
  void onPageHide(ChangeReason reason);

  String uniqueId() {
    return null;
  }
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
      observer.onPageShow(ChangeReason.routePushed);
    }
  }

  /// Unregisters the given observer.
  void removeObserver(PageVisibilityObserver observer) {
    assert(observer != null);
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      observers?.remove(observer);
    }
  }

  void dispatchPageShowEventForRoute(
      Route<dynamic> route, ChangeReason reason) {
    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        observer.onPageShow(reason);
      }
    }
  }

  void dispatchPageHideEventForRoute(
      Route<dynamic> route, ChangeReason reason) {
    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        observer.onPageHide(reason);
      }
    }
  }

  void dispatchPageShowEvent(String uniqueId, ChangeReason reason) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      for (PageVisibilityObserver observer in observers) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageShow(reason);
        }
      }
    }
  }

  void dispatchPageHideEvent(String uniqueId, ChangeReason reason) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      for (PageVisibilityObserver observer in observers) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageHide(reason);
        }
      }
    }
  }

  void dispatchBackgroundEvent(String uniqueId) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      for (PageVisibilityObserver observer in observers) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageHide(ChangeReason.background);
        }
      }
    }
  }

  void dispatchForegroundEvent(String uniqueId) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      for (PageVisibilityObserver observer in observers) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageShow(ChangeReason.foreground);
        }
      }
    }
  }
}
