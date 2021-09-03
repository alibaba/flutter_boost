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
  ContainerOverlayEntry(BoostContainer container)
      : containerUniqueId = container.pageInfo.uniqueId,
        super(
            builder: (ctx) => BoostContainerWidget(container: container),
            opaque: true,
            maintainState: true);

  /// This overlay's id, which is the same as the it's related container
  final String containerUniqueId;

  @override
  String toString() {
    return 'ContainerOverlayEntry: containerId:$containerUniqueId';
  }
}

/// Creates a [ContainerOverlayEntry] for the given [BoostContainer].
typedef ContainerOverlayEntryFactory = ContainerOverlayEntry Function(
    BoostContainer container);

class ContainerOverlay {
  ContainerOverlay._();
  static final ContainerOverlay instance = ContainerOverlay._();

  List<ContainerOverlayEntry> _lastEntries = <ContainerOverlayEntry>[];
  static ContainerOverlayEntryFactory _overlayEntryFactory;

  /// Sets a custom [ContainerOverlayEntryFactory].
  static set overlayEntryFactory(ContainerOverlayEntryFactory entryFactory) {
    _overlayEntryFactory = entryFactory;
  }

  static ContainerOverlayEntryFactory get overlayEntryFactory {
    return _overlayEntryFactory ??=
        ((container) => ContainerOverlayEntry(container));
  }

  ///Refresh an specific entry instead of all of entries to enhance the performace
  ///
  ///[container] : The container you want to operate, it is related with
  ///              internal [OverlayEntry]
  ///[mode] : The [BoostSpecificEntryRefreshMode] you want to choose
  void refreshSpecificOverlayEntries(
      BoostContainer container, BoostSpecificEntryRefreshMode mode) {
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
