import 'package:flutter/widgets.dart';

/// Widget with caching function, solve：
///1.Page rebuild caused by overlay；
///2.Page rebuild caused by navigator2.0；
class BoostCacheWidget extends StatefulWidget {
  final String uniqueId;
  final WidgetBuilder builder;

  const BoostCacheWidget(
      {@required this.uniqueId, @required this.builder, Key key})
      : assert(builder != null),
        assert(uniqueId != null),
        super(key: key);

  @override
  _BoostCacheWidgetState createState() => _BoostCacheWidgetState();
}

class _BoostCacheWidgetState extends State<BoostCacheWidget> {
  Widget _cacheWidget;
  String _oldUniqueId;

  @override
  Widget build(BuildContext context) {
    final bool shouldUpdate = _oldUniqueId != widget.uniqueId;
    if (shouldUpdate) {
      _oldUniqueId = widget.uniqueId;
      _cacheWidget = widget.builder(context);
    }
    return _cacheWidget;
  }
}
