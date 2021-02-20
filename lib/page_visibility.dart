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

  // Todo(rulong.crl): This function looks odd.
  String uniqueId() {
    return null;
  }
}

class PageVisibilityBinding {
  static PageVisibilityBinding _instance;
  final Map<Route<dynamic>, Set<PageVisibilityObserver>> _listeners =
      <Route<dynamic>, Set<PageVisibilityObserver>>{};

  PageVisibilityBinding._();

  static PageVisibilityBinding get instance {
    _instance ??= PageVisibilityBinding._();
    return _instance;
  }

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
  bool removeObserver(PageVisibilityObserver observer) {
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
      observers.forEach((observer) {
        observer.onPageShow(reason);
      });
    }
  }

  void dispatchPageHideEventForRoute(
      Route<dynamic> route, ChangeReason reason) {
    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      observers.forEach((observer) {
        observer.onPageHide(reason);
      });
    }
  }

  void dispatchPageShowEvent(String uniqueId, ChangeReason reason) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      observers.forEach((observer) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageShow(reason);
        }
      });
    }
  }

  void dispatchPageHideEvent(String uniqueId, ChangeReason reason) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      observers.forEach((observer) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageHide(reason);
        }
      });
    }
  }

  void dispatchBackgroundEvent(String uniqueId) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      observers.forEach((observer) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageHide(ChangeReason.foreground);
        }
      });
    }
  }

  void dispatchForegroundEvent(String uniqueId) {
    for (final Route<dynamic> route in _listeners.keys) {
      final Set<PageVisibilityObserver> observers = _listeners[route];
      observers.forEach((observer) {
        if (observer.uniqueId() == uniqueId) {
          observer.onPageShow(ChangeReason.foreground);
        }
      });
    }
  }
}
