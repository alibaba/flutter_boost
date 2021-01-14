import 'package:pigeon/pigeon.dart';

class CommonParams {
  String pageName;
  String uniqueId;
  bool openContainer;
  Map<String, String> arguments;
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
  void popRoute(CommonParams param);
}

void configurePigeon(PigeonOptions opts) {
  opts.dartOut = 'lib/messages.dart';
  opts.objcHeaderOut = 'ios/Classes/messages.h';
  opts.objcSourceOut = 'ios/Classes/messages.m';
  opts.objcOptions.prefix = 'FB';
  opts.javaOut = 'android/src/main/java/com/idlefish/flutterboost/Messages.java';
}
