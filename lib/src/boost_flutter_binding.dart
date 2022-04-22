import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'logger.dart';

/// This class is to hook the Binding，to handle lifecycle events
mixin BoostFlutterBinding on WidgetsFlutterBinding {
  bool _appLifecycleStateLocked = true;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    changeAppLifecycleState(AppLifecycleState.resumed);
  }

  static BoostFlutterBinding get instance => _instance;
  static BoostFlutterBinding _instance;

  @override
  void handleAppLifecycleStateChanged(AppLifecycleState state) {
    // TODO(0xZOne): In order to be able to pause frame scheduling while the
    // Flutter container is in the background, we remove the restriction here.
    // if (_appLifecycleStateLocked) {
    //   return;
    // }
    Logger.log('boost_flutter_binding: '
        'handleAppLifecycleStateChanged ${state.toString()}');
    super.handleAppLifecycleStateChanged(state);
  }

  void changeAppLifecycleState(AppLifecycleState state) {
    if (SchedulerBinding.instance.lifecycleState == state) {
      return;
    }
    _appLifecycleStateLocked = false;
    handleAppLifecycleStateChanged(state);
    _appLifecycleStateLocked = true;
  }
}
