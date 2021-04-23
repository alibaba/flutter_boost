import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_container.dart';

final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
List<_ContainerOverlayEntry> _lastEntries;

void refreshOverlayEntries(List<BoostContainer> containers) {
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
      .toList(growable: false);

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
      : super(
            builder: (BuildContext ctx) => container,
            opaque: true,
            maintainState: true);
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
