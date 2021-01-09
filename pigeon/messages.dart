import 'package:pigeon/pigeon.dart';

class CommonParams {
  String pageName;
  String uniqueId;
  String groupName;
  bool openContainer;
  Map<String, dynamic> arguments;
}

@HostApi()
abstract class NativeRouterApi {
  void pushNativeRoute(CommonParams param);
  void pushFlutterRoute(CommonParams param);
  void popRoute(CommonParams param);
}

@FlutterApi()
abstract class FlutterRouterApi {
  void pushRoute(CommonParams param);
  void pushOrShowRoute(CommonParams param);
  void showTabRoute(CommonParams param);
  void popRoute();
}

void configurePigeon(PigeonOptions opts) {
  opts.dartOut = 'lib/messages.dart';
  opts.objcHeaderOut = 'ios/Classes/messages.h';
  opts.objcSourceOut = 'ios/Classes/messages.m';
  opts.objcOptions.prefix = 'HR';
  opts.javaOut = 'android/src/main/java/com/idlefish/flutterboost/Messages.java';
}
