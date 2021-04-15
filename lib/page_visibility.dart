import 'package:flutter/material.dart';
import 'package:flutter_boost/logger.dart';

abstract class PageVisibilityObserver {
  void onPageCreate();
  void onPageShow({bool isForegroundEvent});
  void onPageHide({bool isBackgroundEvent});
  void onPageDestroy();
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

  void dispatchPageShowEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        try {
          observer.onPageShow();
        } catch (e) {
          Logger.log(e);
        }
      }
    }
    Logger.log(
        'page_visibility, #dispatchPageShowEvent, ${route.settings.name}');
  }

  void dispatchPageHideEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        try {
          observer.onPageHide();
        } catch (e) {
          Logger.log(e);
        }
      }
    }
    Logger.log(
        'page_visibility, #dispatchPageHideEvent, ${route.settings.name}');
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
  }

  void dispatchBackgroundEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        try {
          observer.onPageHide(isBackgroundEvent: true);
        } catch (e) {
          Logger.log(e);
        }
      }
    }
    Logger.log(
        'page_visibility, #dispatchBackgroundEvent, ${route.settings.name}');
  }

  void dispatchForegroundEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final List<PageVisibilityObserver> observers = _listeners[route]?.toList();
    if (observers != null) {
      for (PageVisibilityObserver observer in observers) {
        try {
          observer.onPageShow(isForegroundEvent: true);
        } catch (e) {
          Logger.log(e);
        }
      }
    }
    Logger.log(
        'page_visibility, #dispatchForegroundEvent, ${route.settings.name}');
  }
}
