import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_container.dart';

final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
List<_ContainerOverlayEntry> _leastEntries;

void refreshOverlayEntries(List<BoostContainer<dynamic>> containers) {
  final OverlayState overlayState = overlayKey.currentState;

  if (overlayState == null) {
    return;
  }
  if (_leastEntries != null && _leastEntries.isNotEmpty) {
    for (_ContainerOverlayEntry entry in _leastEntries) {
      entry.remove();
    }
  }
  _leastEntries = containers
      .map<_ContainerOverlayEntry>((BoostContainer<dynamic> container) =>
          _ContainerOverlayEntry(container))
      .toList(growable: false);

  overlayState.insertAll(_leastEntries);
}

class _ContainerOverlayEntry extends OverlayEntry {
  _ContainerOverlayEntry(BoostContainer<dynamic> container)
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
