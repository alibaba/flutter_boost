import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'logger.dart';

///Observer for all pages visibility
class GlobalPageVisibilityObserver {
  void onPagePush(Route<dynamic> route) {}

  void onPageShow(Route<dynamic> route) {}

  void onPageHide(Route<dynamic> route) {}

  void onPagePop(Route<dynamic> route) {}

  void onForeground(Route<dynamic> route) {}

  void onBackground(Route<dynamic> route) {}
}

///Observer for single page visibility
class PageVisibilityObserver {
  ///
  /// Tip:If you want to do things when page is created,
  /// please in your [StatefulWidget]'s [State]
  /// and write your code in [initState] method to initialize
  ///
  /// And If you want to do things when page is destory,
  /// please write code in the [dispose] method
  ///

  /// It can be regarded as Android "onResume" or iOS "viewDidAppear"
  void onPageShow() {}

  /// It can be regarded as Android "onStop" or iOS "viewDidDisappear"
  void onPageHide() {}

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

  void dispatchPagePushEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    ///just dispatch for global observers
    dispatchGlobalPagePushEvent(route);
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

  ///When page show first time,we should dispatch event in [FrameCallback]
  ///to avoid the page can't receive the show event
  void dispatchPageShowEventOnPageShowFirstTime(Route<dynamic> route) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      dispatchPageShowEvent(route);
    });
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

  void dispatchPagePopEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    ///just dispatch for global observers
    dispatchGlobalPagePopEvent(route);
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

    Logger.log('page_visibility, '
        '#dispatchPageBackgroundEvent, ${route.settings.name}');

    dispatchGlobalBackgroundEvent(route);
  }

  void dispatchGlobalPagePushEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }
    final globalObserversList = _globalListeners.toList();

    for (var observer in globalObserversList) {
      observer.onPagePush(route);
    }

    Logger.log('page_visibility, #dispatchGlobalPagePushEvent, '
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

  void dispatchGlobalPagePopEvent(Route<dynamic> route) {
    if (route == null) {
      return;
    }

    final globalObserversList = _globalListeners.toList();
    for (var observer in globalObserversList) {
      observer.onPagePop(route);
    }

    Logger.log('page_visibility, #dispatchGlobalPagePopEvent, '
        '${route.settings.name}');
  }

  void dispatchGlobalForgroundEvent(Route<dynamic> route) {
    final globalObserversList = _globalListeners.toList();
    for (var observer in globalObserversList) {
      observer.onForeground(route);
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
