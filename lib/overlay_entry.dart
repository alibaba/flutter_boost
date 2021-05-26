import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'boost_container.dart';

typedef FlutterBoostSetPreRenderCallback = void Function(OverlayEntry, bool);
void _defaultSetPreRenderCallback(OverlayEntry entry, bool value) {
  // For common flutter engine, does nothing.
}
///For custom flutter engine, Hummer provides API [OverlayEntry.preRender] to enable 
///pre-render an offstage OverlayEntry. If application demands this pre-rendering
///ability, it is the responsibility of application to override [setPreRenderCallback]
///to make use of the API, simply like:
///void overrideSetPreRenderCallback(OverlayEntry entry, bool value) {
///  entry.preRender = value;
///}
///setPreRenderCallback = overrideSetPreRenderCallback;
FlutterBoostSetPreRenderCallback setPreRenderCallback = _defaultSetPreRenderCallback;

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

  ///Add a new entry for pre-rendering
  preRender,
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

  final hasScheduledFrame = SchedulerBinding.instance.hasScheduledFrame;
  final framesEnabled = SchedulerBinding.instance.framesEnabled;

  //deal with different situation
  switch (mode) {
    case BoostSpecificEntryRefreshMode.add:
      final entry = _ContainerOverlayEntry(container);
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
      existingEntry.setPreRender(value: false);
      overlayState.insert(existingEntry);
      break;
    case BoostSpecificEntryRefreshMode.preRender:
      final entry = _ContainerOverlayEntry(container);
      entry.setPreRender(value: true);
      // Insert to the bottom for just pre-render.
      final first = _lastEntries.first;
      _lastEntries.insert(0, entry);
      overlayState.insert(entry, below: first);
      break;
  }

  // https://github.com/alibaba/flutter_boost/issues/1056
  // Ensure this frame is refreshed after schedule frame,
  // otherwise the PageState.dispose may not be called
  if (hasScheduledFrame || !framesEnabled) {
    SchedulerBinding.instance.scheduleWarmUpFrame();
  }
}

///Refresh all of overlayEntries
void refreshAllOverlayEntries(List<BoostContainer> containers) {
  final overlayState = overlayKey.currentState;
  if (overlayState == null) {
    return;
  }

  if (_lastEntries != null && _lastEntries.isNotEmpty) {
    for (var entry in _lastEntries) {
      entry.remove();
    }
  }

  _lastEntries = containers
      .map<_ContainerOverlayEntry>(
          (container) => _ContainerOverlayEntry(container))
      .toList(growable: true);

  final hasScheduledFrame = SchedulerBinding.instance.hasScheduledFrame;
  final framesEnabled = SchedulerBinding.instance.framesEnabled;

  overlayState.insertAll(_lastEntries);

  // https://github.com/alibaba/flutter_boost/issues/1056
  // Ensure this frame is refreshed after schedule frame，
  // otherwise the PageState.dispose may not be called
  if (hasScheduledFrame || !framesEnabled) {
    SchedulerBinding.instance.scheduleWarmUpFrame();
  }
}

class _ContainerOverlayEntry extends OverlayEntry {
  _ContainerOverlayEntry(BoostContainer container)
      : containerUniqueId = container.pageInfo.uniqueId,
        super(
            builder: (ctx) => BoostContainerWidget(container: container),
            opaque: true,
            maintainState: true);

  ///Effective for Hummer only, see comments of [setPreRenderCallback].
  void setPreRender({@required bool value}) {
    assert(value != null);
    setPreRenderCallback(this, value);
  }

  ///This overlay's id,which is the same as the it's related container
  final String containerUniqueId;

  @override
  String toString() {
    return '_ContainerOverlayEntry: containerId:$containerUniqueId';
  }
}
