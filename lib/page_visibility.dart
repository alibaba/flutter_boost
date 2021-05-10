import 'package:flutter/material.dart';

import 'logger.dart';

///observer for all pages visibility
class GlobalPageVisibilityObserver {
  void onPageCreate(Route<dynamic> route) {}

  void onPageShow(Route<dynamic> route) {}

  void onPageHide(Route<dynamic> route) {}

  void onPageDestroy(Route<dynamic> route) {}

  void onForground(Route<dynamic> route) {}

  void onBackground(Route<dynamic> route) {}
}

///observer for single page visibility
class PageVisibilityObserver {
  void onPageCreate() {}

  void onPageShow() {}

  void onPageHide() {}

  void onPageDestroy() {}

  void onForeground() {}

  void onBackground() {}
}

class PageVisibilityBinding {
  PageVisibilityBinding._();

  static final PageVisibilityBinding instance = PageVisibilityBinding._();

  ///listeners for single page event
  final Map<Route<dynamic>, Set<PageVisibilityObserver>> _listeners =
      <Route<dynamic>, Set<PageVisibilityObserver>>{};

  ///listeners for all pages event
  final Set<GlobalPageVisibilityObserver> _globalListeners =
      <GlobalPageVisibilityObserver>{};

  /// Registers the given object and route as a binding observer.
  void addObserver(PageVisibilityObserver observer, Route<dynamic> route) {
    assert(observer != null);
    assert(route != null);
    final observers =
        _listeners.putIfAbsent(route, () => <PageVisibilityObserver>{});
    observers.add(observer);
    Logger.log(
        'page_visibility, #addObserver, $observers, ${route.settings.name}');
  }

  /// Unregisters the given observer.
  void removeObserver(PageVisibilityObserver observer) {
    assert(observer != null);
    for (final route in _listeners.keys) {
      final observers = _listeners[route];
      observers?.remove(observer);
    }
    Logger.log('page_visibility, #removeObserver, $observer');
  }

  ///Register [observer] to [_globalListeners] set
  void addGlobalObserver(GlobalPageVisibilityObserver observer) {
    assert(observer != null);
    _globalListeners.add(observer);
    Logger.log('page_visibility, #addGlobalObserver, $observer');
  }

  ///Register [observer] from [_globalListeners] set
  void removeGlobalObserver(GlobalPageVisibilityObserver observer) {
    assert(observer != null);
    _globalListeners.remove(observer);
    Logger.log('page_visibility, #removeGlobalObserver, $observer');
  }

  void dispatchPageCreateEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final observers = _listeners[route]?.toList();
    if (observers != null) {
      for (var observer in observers) {
        try {
          observer.onPageCreate();
        } on Exception catch (e) {
          Logger.log(e.toString());
        }
      }
    }
    Logger.log(
        'page_visibility, #dispatchPageShowEvent, ${route.settings.name}');

    dispatchGlobalPageCreateEvent(route);
  }

  void dispatchPageShowEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final observers = _listeners[route]?.toList();
    if (observers != null) {
      for (var observer in observers) {
        try {
          observer.onPageShow();
        } on Exception catch (e) {
          Logger.log(e.toString());
        }
      }
    }
    Logger.log(
        'page_visibility, #dispatchPageShowEvent, ${route.settings.name}');

    dispatchGlobalPageShowEvent(route);
  }

  void dispatchPageHideEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final observers = _listeners[route]?.toList();
    if (observers != null) {
      for (var observer in observers) {
        try {
          observer.onPageHide();
        } on Exception catch (e) {
          Logger.log(e.toString());
        }
      }
    }
    Logger.log(
        'page_visibility, #dispatchPageHideEvent, ${route.settings.name}');

    dispatchGlobalPageHideEvent(route);
  }

  void dispatchPageDestroyEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final observers = _listeners[route]?.toList();
    if (observers != null) {
      for (var observer in observers) {
        try {
          observer.onPageDestroy();
        } on Exception catch (e) {
          Logger.log(e.toString());
        }
      }
    }

    Logger.log(
        'page_visibility, #dispatchPageDestroyEvent, ${route.settings.name}');

    dispatchGlobalPageDestroyEvent(route);
  }

  void dispatchPageForgroundEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final observers = _listeners[route]?.toList();
    if (observers != null) {
      for (var observer in observers) {
        try {
          observer.onForeground();
        } on Exception catch (e) {
          Logger.log(e.toString());
        }
      }
    }

    Logger.log(
        'page_visibility, #dispatchPageForgroundEvent, ${route.settings.name}');

    dispatchGlobalForgroundEvent(route);
  }

  void dispatchPageBackgroundEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final observers = _listeners[route]?.toList();
    if (observers != null) {
      for (var observer in observers) {
        try {
          observer.onBackground();
        } on Exception catch (e) {
          Logger.log(e.toString());
        }
      }
    }

    Logger.log(
        'page_visibility, #dispatchPageBackgroundEvent, ${route.settings.name}');

    dispatchGlobalBackgroundEvent(route);
  }

  void dispatchGlobalPageCreateEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }
    final globalObserversList = _globalListeners.toList();

    for (var observer in globalObserversList) {
      observer.onPageCreate(route);
    }

    Logger.log('page_visibility, #dispatchGlobalPageCreateEvent, '
        '${route.settings.name}');
  }

  void dispatchGlobalPageShowEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }
    final globalObserversList = _globalListeners.toList();

    for (var observer in globalObserversList) {
      observer.onPageShow(route);
    }

    Logger.log('page_visibility, #dispatchGlobalPageShowEvent, '
        '${route.settings.name}');
  }

  void dispatchGlobalPageHideEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }
    final globalObserversList = _globalListeners.toList();

    for (var observer in globalObserversList) {
      observer.onPageHide(route);
    }

    Logger.log('page_visibility, #dispatchGlobalPageHideEvent, '
        '${route.settings.name}');
  }

  void dispatchGlobalPageDestroyEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final globalObserversList = _globalListeners.toList();
    for (var observer in globalObserversList) {
      observer.onPageDestroy(route);
    }

    Logger.log('page_visibility, #dispatchGlobalPageDestroyEvent, '
        '${route.settings.name}');
  }

  void dispatchGlobalForgroundEvent(Route<dynamic> route) {
    final globalObserversList = _globalListeners.toList();
    for (var observer in globalObserversList) {
      observer.onForground(route);
    }

    Logger.log('page_visibility, #dispatchGlobalForgroudEvent');
  }

  void dispatchGlobalBackgroundEvent(Route<dynamic> route) {
    final globalObserversList = _globalListeners.toList();
    for (var observer in globalObserversList) {
      observer.onBackground(route);
    }

    Logger.log('page_visibility, #dispatchGlobalBackgroundEvent');
  }
}
