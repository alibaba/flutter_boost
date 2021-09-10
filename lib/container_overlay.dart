import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'boost_container.dart';

final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

/// The Entry refresh mode, which indicates different situation
enum BoostSpecificEntryRefreshMode {
  ///Just add an new entry
  add,

  ///remove a specific entry from entries list
  remove,

  ///move an existing entry to top
  moveToTop,
}

class ContainerOverlayEntry extends OverlayEntry {
  ///This container for this [ContainerOverlayEntry]
  final BoostContainer container;

  ContainerOverlayEntry(this.container)
      : super(builder: (ctx) => BoostContainerWidget(container: container), opaque: true, maintainState: true);

  /// This overlay's id, which is the same as the it's related container
  String get containerUniqueId => container.pageInfo.uniqueId;

  @override
  String toString() {
    return 'ContainerOverlayEntry: containerId:$containerUniqueId';
  }
}

/// Creates a [ContainerOverlayEntry] for the given [BoostContainer].
typedef ContainerOverlayEntryFactory = ContainerOverlayEntry Function(BoostContainer container);

class ContainerOverlay {
  ContainerOverlay._();

  static final ContainerOverlay instance = ContainerOverlay._();

  /// All of the container entries in flutter boost app
  final List<ContainerOverlayEntry> _lastEntries = <ContainerOverlayEntry>[];

  /// get top container in this [ContainerOverlay],if [_lastEntries] is empty,return null
  /// else will return the last container
  BoostContainer get topContainer {
    if (_lastEntries.isEmpty) {
      return null;
    }
    return _lastEntries.last.container;
  }

  /// Containers in [ContainerOverlay] it is unmodifiable
  /// we can only modify containers
  /// using refresh method using [ContainerOverlay.refreshSpecificOverlayEntries]
  UnmodifiableListView<BoostContainer> get containers => UnmodifiableListView(_lastEntries.map((entry) {
        return entry.container;
  }).toList(growable: false));

  static ContainerOverlayEntryFactory _overlayEntryFactory;

  /// Sets a custom [ContainerOverlayEntryFactory].
  static set overlayEntryFactory(ContainerOverlayEntryFactory entryFactory) {
    _overlayEntryFactory = entryFactory;
  }

  static ContainerOverlayEntryFactory get overlayEntryFactory {
    return _overlayEntryFactory ??= ((container) => ContainerOverlayEntry(container));
  }

  ///Refresh an specific entry instead of all of entries to enhance the performace
  ///
  ///[container] : The container you want to operate, it is related with
  ///              internal [OverlayEntry]
  ///[mode] : The [BoostSpecificEntryRefreshMode] you want to choose
  void refreshSpecificOverlayEntries(BoostContainer container, BoostSpecificEntryRefreshMode mode) {
    //Get OverlayState from global key
    final overlayState = overlayKey.currentState;
    if (overlayState == null) {
      return;
    }

    //deal with different situation
    switch (mode) {
      case BoostSpecificEntryRefreshMode.add:
        final entry = overlayEntryFactory(container);
        _lastEntries.add(entry);
        overlayState.insert(entry);
        break;
      case BoostSpecificEntryRefreshMode.remove:
        if (_lastEntries.isNotEmpty) {
          //Find the entry matching the container
          final entryToRemove = _lastEntries.singleWhere((element) {
            return element.containerUniqueId == container.pageInfo.uniqueId;
          });

          //remove from the list and overlay
          _lastEntries.remove(entryToRemove);
          entryToRemove.remove();
          // https://github.com/alibaba/flutter_boost/issues/1056
          // Ensure this frame is refreshed after schedule frame,
          // otherwise the PageState.dispose may not be called
          SchedulerBinding.instance.scheduleWarmUpFrame();
        }
        break;
      case BoostSpecificEntryRefreshMode.moveToTop:
        final existingEntry = _lastEntries.singleWhere((element) {
          return element.containerUniqueId == container.pageInfo.uniqueId;
        });
        //remove the entry from list and overlay
        //and insert it to list'top and overlay 's top
        _lastEntries.remove(existingEntry);
        _lastEntries.add(existingEntry);
        existingEntry.remove();
        overlayState.insert(existingEntry);
        break;
    }
  }
}
