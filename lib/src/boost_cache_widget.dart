import 'package:flutter/widgets.dart';

///带有缓存功能的 widget，解决：
///1.由于外部路由 overlay 导致page rebuild 问题；
///2.由于内部路由 navigator2.0 带来的 page rebuild 问题；
class BoostCacheWidget extends StatefulWidget {
  final String uniqueId;
  final WidgetBuilder builder;

  const BoostCacheWidget({@required this.uniqueId, @required this.builder, Key key})
      : assert(builder != null),
        assert(uniqueId != null),
        super(key: key);

  @override
  _BoostCacheWidgetState createState() => _BoostCacheWidgetState();
}

class _BoostCacheWidgetState extends State<BoostCacheWidget> {
  Widget cacheWidget;
  BoostCacheWidget oldWidget;

  @override
  Widget build(BuildContext context) {
    final bool shouldUpdate = oldWidget?.uniqueId != widget.uniqueId;
    if (shouldUpdate) {
      oldWidget = widget;
      cacheWidget = widget.builder(context);
    }
    return cacheWidget;
  }
}
