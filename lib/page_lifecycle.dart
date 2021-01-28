import 'package:flutter/material.dart';

abstract class PageLifecycleObserver {
  void onForeground();
  void onBackground();

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

  void onBackground(String uniqueId) {
    _observers.forEach((observer) {
      if (observer.uniqueId() != null) {
        if (observer.uniqueId() == uniqueId) {
          observer.onBackground();
        }
      }
    });
  }

  void onForeground(String uniqueId) {
    _observers.forEach((observer) {
      if (observer.uniqueId() != null) {
        if (observer.uniqueId() == uniqueId) {
          observer.onForeground();
        }
      }
    });
  }
}
