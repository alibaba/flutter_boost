import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

mixin _BoostLifeCycle {
  @protected
  void onContainerInit() {}

  @protected
  void onContainerAppear() {}

  @protected
  void onContainerWillDisAppear() {}

  @protected
  void onContainerDisAppear() {}

  @protected
  void onContainerForeground() {}

  @protected
  void onContainerBackground() {}

  @protected
  @mustCallSuper
  void onContainerDestroy() {}
}

/// In iOS platform, root widget of native container sometimes
/// do not cal `dispose` when native container was destroyed.
/// To fix this, add BoostLifeCycleState as parent widget and
/// override onWidgetDisposed function.
abstract class BoostLifeCycleState<T extends StatefulWidget> extends State<T>
    with _BoostLifeCycle {
  String _boostUniqueId;

  String _boostPageName;

  String get boostUniqueId => _boostUniqueId;

  String get boostPageName => _boostPageName;

  bool _disposed = false;

  _handleLifeCycle(
      ContainerLifeCycle lifeCycle, BoostContainerSettings settings) {
    if (settings.uniqueId != boostUniqueId) return;
    if (lifeCycle == ContainerLifeCycle.Init) {
      onContainerInit();
    } else if (lifeCycle == ContainerLifeCycle.Appear) {
      onContainerAppear();
    } else if (lifeCycle == ContainerLifeCycle.WillDisappear) {
      onContainerWillDisAppear();
    } else if (lifeCycle == ContainerLifeCycle.Disappear) {
      onContainerDisAppear();
    } else if (lifeCycle == ContainerLifeCycle.Foreground) {
      onContainerForeground();
    } else if (lifeCycle == ContainerLifeCycle.Background) {
      onContainerBackground();
    } else if (lifeCycle == ContainerLifeCycle.Destroy) {
      onContainerDestroy();
      onWidgetDisposed();
    }
  }

  @override
  void initState() {
    super.initState();
    _boostUniqueId = FlutterBoost.containerManager?.onstageSettings?.uniqueId;
    _boostPageName = FlutterBoost.containerManager?.onstageSettings?.name;
    FlutterBoost.singleton.observersHolder
        .addObserver<BoostContainerLifeCycleObserver>(_handleLifeCycle);
  }
  
  @protected
  @mustCallSuper
  void onWidgetDisposed() {
    if (_disposed) return;
    _disposed = true;
    FlutterBoost.singleton.observersHolder
        .removeObserver<BoostContainerLifeCycleObserver>(_lifeCycleListener);
  }

  @override
  void dispose() {
    onWidgetDisposed();
    super.dispose();
  }
}
