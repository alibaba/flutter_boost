import 'package:pigeon/pigeon.dart';

class CommonParams {
  String pageName;
  String uniqueId;
  Map<String, Object> arguments;
  bool opaque;
  String key;
}

class StackInfo {
  List<String> containers;
  Map<String, List<Map<String, Object>>> routes;
}

@HostApi()
abstract class NativeRouterApi {
  void pushNativeRoute(CommonParams param);
  void pushFlutterRoute(CommonParams param);
  @async
  void popRoute(CommonParams param);
  StackInfo getStackFromHost();
  void saveStackToHost(StackInfo stack);
  void sendEventToNative(CommonParams params);
}

@FlutterApi()
abstract class FlutterRouterApi {
  void pushRoute(CommonParams param);
  void popRoute(CommonParams param);
  void removeRoute(CommonParams param);
  void onForeground(CommonParams param);
  void onBackground(CommonParams param);
  void onNativeResult(CommonParams param);
  void onContainerShow(CommonParams param);
  void onContainerHide(CommonParams param);
  void sendEventToFlutter(CommonParams params);
  void onBackPressed();
}

void configurePigeon(PigeonOptions opts) {
  opts.dartOut = 'lib/src/messages.dart';
  opts.objcHeaderOut = 'ios/Classes/messages.h';
  opts.objcSourceOut = 'ios/Classes/messages.m';
  opts.objcOptions.prefix = 'FB';
  opts.javaOut =
      'android/src/main/java/com/idlefish/flutterboost/Messages.java';
}
