/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 Alibaba Group
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../flutter_boost.dart';
import '../support/logger.dart';
import 'boost_container.dart';
import 'container_coordinator.dart';

enum ContainerOperation { Push, Onstage, Pop, Remove }

typedef BoostContainerObserver = void Function(
    ContainerOperation operation, BoostContainerSettings settings);

@immutable
class BoostContainerManager extends StatefulWidget {
  const BoostContainerManager({
    Key key,
    this.initNavigator,
    this.prePushRoute,
    this.postPushRoute,
  }) : super(key: key);

  final Navigator initNavigator;
  final PrePushRoute prePushRoute;
  final PostPushRoute postPushRoute;

  @override
  ContainerManagerState createState() => ContainerManagerState();

  static ContainerManagerState tryOf(BuildContext context) {
    final ContainerManagerState manager =
        context.findAncestorStateOfType<ContainerManagerState>();
    return manager;
  }

  static ContainerManagerState of(BuildContext context) {
    final ContainerManagerState manager =
        context.findAncestorStateOfType<ContainerManagerState>();
    assert(manager != null, 'not in flutter boost');
    return manager;
  }
}

class ContainerManagerState extends State<BoostContainerManager> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  final List<BoostContainer> _offstage = <BoostContainer>[];

  List<_ContainerOverlayEntry> _leastEntries;

  BoostContainer _onstage;
  bool _foreground = true;

  String _lastShownContainer;

  PrePushRoute get prePushRoute => widget.prePushRoute;

  PostPushRoute get postPushRoute => widget.postPushRoute;

  bool get foreground => _foreground;

  // Number of containers.
  int get containerCounts => _offstage.length;

  List<BoostContainer> get offstage => _offstage;

  // Setting for current visible container.
  BoostContainerSettings get onstageSettings => _onstage.settings;

  // Current visible container.
  BoostContainerState get onstageContainer => _stateOf(_onstage);

  BoostContainerState get subContainer =>
      _offstage.isEmpty ? null : _stateOf(_offstage.last);

  @override
  void initState() {
    super.initState();

    assert(widget.initNavigator != null);
    _onstage = BoostContainer.copy(widget.initNavigator);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void updateFocuse() {
    final BoostContainerState now = _stateOf(_onstage);
    if (now != null) {
      FocusScope.of(context).setFirstFocus(now.focusScopeNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: _overlayKey,
      initialEntries: const <OverlayEntry>[],
    );
  }

  BoostContainerState _stateOf(BoostContainer container) {
    if (container.key is GlobalKey<BoostContainerState>) {
      final GlobalKey<BoostContainerState> globalKey =
          container.key as GlobalKey<BoostContainerState>;
      return globalKey.currentState;
    }

    assert(
        false, 'key of BoostContainer must be GlobalKey<BoostContainerState>');
    return null;
  }

  void _onShownContainerChanged(String old, String now) {
    Logger.log('onShownContainerChanged old:$old now:$now');

    final Map<String, dynamic> properties = <String, dynamic>{};
    properties['newName'] = now;
    properties['oldName'] = old;

    FlutterBoost.singleton.channel
        .invokeMethod<dynamic>('onShownContainerChanged', properties);
  }

  void _refreshOverlayEntries() {
    final OverlayState overlayState = _overlayKey.currentState;

    if (overlayState == null) {
      return;
    }

    if (_leastEntries != null && _leastEntries.isNotEmpty) {
      for (final _ContainerOverlayEntry entry in _leastEntries) {
        entry.remove();
      }
    }

    final List<BoostContainer> containers = <BoostContainer>[];
    containers.addAll(_offstage);

    assert(_onstage != null, 'Should have a least one BoostContainer');
    containers.add(_onstage);

    _leastEntries = containers
        .map<_ContainerOverlayEntry>(
            (BoostContainer container) => _ContainerOverlayEntry(container))
        .toList(growable: false);

    overlayState.insertAll(_leastEntries);

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      final String now = _onstage.settings.uniqueId;
      if (_lastShownContainer != now) {
        final String old = _lastShownContainer;
        _lastShownContainer = now;
        _onShownContainerChanged(old, now);
      }
      updateFocuse();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
        Logger.log('_refreshOverlayEntries in addPostFrameCallback');
        _refreshOverlayEntries();
      });
    } else {
      Logger.log('_refreshOverlayEntries in setState');
      _refreshOverlayEntries();
    }

    fn();
    //return super.setState(fn);
  }

  void setForeground() {
    _foreground = true;
    ContainerCoordinator.performContainerLifeCycle(
        _onstage.settings, ContainerLifeCycle.Foreground);
  }

  void setBackground() {
    _foreground = false;
    ContainerCoordinator.performContainerLifeCycle(
        _onstage.settings, ContainerLifeCycle.Background);
  }

  //If container exists bring it to front else
  //create a container.
  void showContainer(BoostContainerSettings settings) {
    if (settings.uniqueId == _onstage.settings.uniqueId) {
      _onShownContainerChanged(null, settings.uniqueId);
      return;
    }

    final int index = _offstage.indexWhere((BoostContainer container) =>
        container.settings.uniqueId == settings.uniqueId);
    if (index > -1) {
      _offstage.add(_onstage);
      _onstage = _offstage.removeAt(index);

      setState(() {});

      for (final BoostContainerObserver observer in FlutterBoost
          .singleton.observersHolder
          .observersOf<BoostContainerObserver>()) {
        observer(ContainerOperation.Onstage, _onstage.settings);
      }
      Logger.log('ContainerObserver#2 didOnstage');
    } else {
      pushContainer(settings);
    }
  }

  BoostContainerState containerStateOf(String id) {
    if (id == _onstage.settings.uniqueId) {
      return _stateOf(_onstage);
    }

    final BoostContainer container = _offstage.firstWhere(
        (BoostContainer container) => container.settings.uniqueId == id,
        orElse: () => null);

    return container == null ? null : _stateOf(container);
  }

  bool containsContainer(String id) {
    if (id == _onstage.settings.uniqueId) {
      return true;
    }

    return _offstage
        .any((BoostContainer container) => container.settings.uniqueId == id);
  }

  void pushContainer(BoostContainerSettings settings) {
    assert(settings.uniqueId != _onstage.settings.uniqueId);
    assert(_offstage.every((BoostContainer container) =>
        container.settings.uniqueId != settings.uniqueId));

    _offstage.add(_onstage);
    _onstage = BoostContainer.obtain(widget.initNavigator, settings);

    setState(() {});

    for (final BoostContainerObserver observer in FlutterBoost
        .singleton.observersHolder
        .observersOf<BoostContainerObserver>()) {
      observer(ContainerOperation.Push, _onstage.settings);
    }
    Logger.log('ContainerObserver#2 didPush');
  }

  void pop() {
    assert(canPop());

    final BoostContainer old = _onstage;
    _onstage = _offstage.removeLast();
    setState(() {});

    final Set<BoostContainerObserver> observers = FlutterBoost
        .singleton.observersHolder
        .observersOf<BoostContainerObserver>();

    for (final BoostContainerObserver observer in observers) {
      observer(ContainerOperation.Pop, old.settings);
    }

    Logger.log('ContainerObserver#2 didPop');
  }

  void remove(String uniqueId) {
    if (_onstage.settings.uniqueId == uniqueId) {
      pop();
    } else {
      final BoostContainer container = _offstage.firstWhere(
        (BoostContainer container) => container.settings.uniqueId == uniqueId,
        orElse: () => null,
      );

      if (container != null) {
        _offstage.remove(container);
        setState(() {});

        final Set<BoostContainerObserver> observers = FlutterBoost
            .singleton.observersHolder
            .observersOf<BoostContainerObserver>();

        for (final BoostContainerObserver observer in observers) {
          observer(ContainerOperation.Remove, container.settings);
        }

        Logger.log('ContainerObserver#2 didRemove');
      }
    }
  }

  bool canPop() => _offstage.isNotEmpty;

  String dump() {
    String info;
    info = 'onstage#:\n  ${_onstage?.desc()}\noffstage#:';

    for (final BoostContainer container in _offstage.reversed) {
      info = '$info\n  ${container?.desc()}';
    }

    return info;
  }
}

class _ContainerOverlayEntry extends OverlayEntry {
  _ContainerOverlayEntry(BoostContainer container)
      : super(
          builder: (BuildContext ctx) => container,
          opaque: true,
          maintainState: true,
        );

  bool _removed = false;

  @override
  void remove() {
    assert(!_removed);
    if (_removed) {
      return;
    }
    _removed = true;
    super.remove();
  }
}
