import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_container.dart';

final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
List<_ContainerOverlayEntry> _lastEntries = <_ContainerOverlayEntry>[];

///The Entry refresh mode,which indicates different situation
enum BoostSpecificEntryRefreshMode {
  ///Just add an new entry
  add,

  ///remove a specific entry from entries list
  remove,

  ///move an existing entry to top
  moveToTop,
}

///Refresh an specific entry instead of all of entries to enhance the performace
///
///[container] : The container you want to operate,it is related with internal [OverlayEntry]
///[mode] : The [BoostSpecificEntryRefreshMode] you want to choose
void refreshSpecificOverlayEntries(
    BoostContainer container, BoostSpecificEntryRefreshMode mode) {
  //Get OverlayState from global key
  final OverlayState overlayState = overlayKey.currentState;
  if (overlayState == null) {
    return;
  }

  final bool hasScheduledFrame = SchedulerBinding.instance.hasScheduledFrame;
  final bool framesEnabled = SchedulerBinding.instance.framesEnabled;

  //deal with different situation
  switch (mode) {
    case BoostSpecificEntryRefreshMode.add:
      final _ContainerOverlayEntry entry = _ContainerOverlayEntry(container);
      _lastEntries.add(entry);
      overlayState.insert(entry);
      break;
    case BoostSpecificEntryRefreshMode.remove:
      if (_lastEntries.isNotEmpty) {
        //Find the entry matching the container
        final _ContainerOverlayEntry entryToRemove =
            _lastEntries.singleWhere((_ContainerOverlayEntry element) {
          return element.containerUniqueId == container.pageInfo.uniqueId;
        });

        //remove from the list and overlay
        _lastEntries.remove(entryToRemove);
        entryToRemove.remove();
      }
      break;
    case BoostSpecificEntryRefreshMode.moveToTop:
      final _ContainerOverlayEntry existingEntry =
          _lastEntries.singleWhere((_ContainerOverlayEntry element) {
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

  // https://github.com/alibaba/flutter_boost/issues/1056
  // Ensure this frame is refreshed after schedule frame，otherwise the PageState.dispose may not be called
  if (hasScheduledFrame || !framesEnabled) {
    SchedulerBinding.instance.scheduleWarmUpFrame();
  }
}

///Refresh all of overlayEntries
void refreshAllOverlayEntries(List<BoostContainer> containers) {
  final OverlayState overlayState = overlayKey.currentState;
  if (overlayState == null) {
    return;
  }

  if (_lastEntries != null && _lastEntries.isNotEmpty) {
    for (_ContainerOverlayEntry entry in _lastEntries) {
      entry.remove();
    }
  }

  _lastEntries = containers
      .map<_ContainerOverlayEntry>(
          (BoostContainer container) => _ContainerOverlayEntry(container))
      .toList(growable: true);

  final bool hasScheduledFrame = SchedulerBinding.instance.hasScheduledFrame;
  final bool framesEnabled = SchedulerBinding.instance.framesEnabled;

  overlayState.insertAll(_lastEntries);

  // https://github.com/alibaba/flutter_boost/issues/1056
  // Ensure this frame is refreshed after schedule frame，otherwise the PageState.dispose may not be called
  if (hasScheduledFrame || !framesEnabled) {
    SchedulerBinding.instance.scheduleWarmUpFrame();
  }
}

class _ContainerOverlayEntry extends OverlayEntry {
  _ContainerOverlayEntry(BoostContainer container)
      : containerUniqueId = container.pageInfo.uniqueId,
        super(
            builder: (BuildContext ctx) => container,

            ///Why the "opaque" is false and "maintainState" is true ? ?
            ///reason video link:  https://www.youtube.com/watch?v=Ya3k828Brt4
            opaque: false,
            maintainState: true);

  ///This overlay's id,which is the same as the it's related container
  final String containerUniqueId;

  @override
  String toString() {
    return '_ContainerOverlayEntry: containerId:$containerUniqueId';
  }
}
