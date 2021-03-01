import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_container.dart';
import 'package:flutter_boost/flutter_boost_app.dart';

final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  List<_ContainerOverlayEntry> _leastEntries;

void refreshOverlayEntries( List<BoostContainer<dynamic>>  containers ) {
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
      .map<_ContainerOverlayEntry>(
          (BoostContainer container) => _ContainerOverlayEntry(container))
      .toList(growable: false);

  overlayState.insertAll(_leastEntries);

}

class _ContainerOverlayEntry extends OverlayEntry {
  bool _removed = false;
  _ContainerOverlayEntry(BoostContainer container)
      : super(
      builder: (BuildContext ctx) =>container,
      opaque: true,
      maintainState: true);

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