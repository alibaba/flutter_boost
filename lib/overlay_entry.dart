import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_container.dart';

final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
void refreshOverlayEntries(List<BoostContainer> containers) {
  final OverlayState overlayState = overlayKey.currentState;
  if (overlayState == null) {
    return;
  }

  overlayState.insertAll(containers
      .map<_ContainerOverlayEntry>((BoostContainer container) =>
          _ContainerOverlayEntry(container))
      .toList(growable: false));
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
