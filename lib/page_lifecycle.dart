// import 'dart:collection';
import 'package:flutter/material.dart';

enum ChangeReason {
  UNSPECIFIED,
  PUSH_ROUTE,
  PUSH_VIEW,
  POP_VIEW,
  POP_ROUTE,
  SWITCH_TAB,
  FOREGROUND,
  BACKGROUND,
}

abstract class PageLifecycleObserver {
  void onForeground();
  void onBackground();
  void onAppear(ChangeReason reason);
  void onDisappear(ChangeReason reason);

  // Todo(rulong.crl): This function looks odd.
  String uniqueId() {
    return null;
  }
}

class PageLifecycleBinding {
  static PageLifecycleBinding _instance;
  final List<PageLifecycleObserver> _observers = <PageLifecycleObserver>[];

  PageLifecycleBinding._();

  static PageLifecycleBinding get instance {
    _instance ??= PageLifecycleBinding._();
    return _instance;
  }

  /// Registers the given object as a binding observer.
  void addObserver(PageLifecycleObserver observer) => _observers.add(observer);

  /// Unregisters the given observer.
  bool removeObserver(PageLifecycleObserver observer) =>
      _observers.remove(observer);

  void onBackground(String uniqueId, String pageName) {
    _observers.forEach((observer) {
      if (observer.uniqueId() != null) {
        if (observer.uniqueId() == uniqueId) {
          observer.onBackground();
        }
      } else {
        if (observer is State) {
          RouteSettings settings =
              ModalRoute.of((observer as State).context).settings;
          if (settings.name == pageName) {
            observer.onBackground();
          }
        }
      }
    });
  }

  void onForeground(String uniqueId, String pageName) {
    _observers.forEach((observer) {
      if (observer.uniqueId() != null) {
        if (observer.uniqueId() == uniqueId) {
          observer.onForeground();
        }
      } else {
        if (observer is State) {
          RouteSettings settings =
              ModalRoute.of((observer as State).context).settings;
          if (settings.name == pageName) {
            observer.onForeground();
          }
        }
      }
    });
  }

  void onAppear(String uniqueId, String pageName, ChangeReason reason) {
    _observers.forEach((observer) {
      if (observer.uniqueId() != null) {
        if (observer.uniqueId() == uniqueId) {
          observer.onAppear(reason);
        }
      } else {
        if (observer is State) {
          RouteSettings settings =
              ModalRoute.of((observer as State).context).settings;
          if (settings.name == pageName) {
            observer.onAppear(reason);
          }
        }
      }
    });
  }

  void onDisappear(String uniqueId, String pageName, ChangeReason reason) {
    _observers.forEach((observer) {
      if (observer.uniqueId() != null) {
        if (observer.uniqueId() == uniqueId) {
          observer.onDisappear(reason);
        }
      } else {
        if (observer is State) {
          RouteSettings settings =
              ModalRoute.of((observer as State).context).settings;
          if (settings.name == pageName) {
            observer.onDisappear(reason);
          }
        }
      }
    });
  }
}
