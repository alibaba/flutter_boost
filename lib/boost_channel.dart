import 'package:flutter/services.dart';

abstract class FlutterRouterApi {

  void pushRoute(String pageName, String uniqueId, Map arguments);

  void popRoute();

  static void setup(FlutterRouterApi api) {
    {
      const BasicMessageChannel<dynamic> channel = BasicMessageChannel<dynamic>(
          'FlutterRouterApi.pushRoute', StandardMessageCodec());
      channel.setMessageHandler((dynamic message) async {
        final Map<dynamic, dynamic> mapMessage =
            message as Map<dynamic, dynamic>;
        String pageName = mapMessage["pageName"];
        String uniqueId = mapMessage["uniqueId"];
        Map arguments = mapMessage["arguments"];
        api.pushRoute(pageName, uniqueId, arguments);
      });
    }
    {
      const BasicMessageChannel<dynamic> channel = BasicMessageChannel<dynamic>(
          'FlutterRouterApi.popRoute', StandardMessageCodec());
      channel.setMessageHandler((dynamic message) async {
        final Map<dynamic, dynamic> mapMessage =
            message as Map<dynamic, dynamic>;
        api.popRoute();
      });
    }
  }
}

class NativeRouterApi {
  Future<void> pushNativeRoute(
      String pageName, String uniqueId, Map arguments) async {
    final Map<dynamic, dynamic> requestMap = <dynamic, dynamic>{};
    requestMap["pageName"] = pageName;
    requestMap["uniqueId"] = uniqueId;
    requestMap["arguments"] = arguments;

    const BasicMessageChannel<dynamic> channel = BasicMessageChannel<dynamic>(
        'NativeRouterApi.pushNativeRoute', StandardMessageCodec());

    final Map<dynamic, dynamic> replyMap = await channel.send(requestMap);
    if (replyMap == null) {
      throw PlatformException(
          code: 'error',
          message: 'Unable to establish connection on channel.',
          details: null);
    } else if (replyMap['error'] != null) {
      final Map<dynamic, dynamic> error = replyMap['error'];
      throw PlatformException(
          code: error['code'],
          message: error['message'],
          details: error['details']);
    } else {
      // noop
    }
  }

  Future<void> pushFlutterRoute(
      String pageName, String uniqueId, Map arguments) async {
    final Map<dynamic, dynamic> requestMap = <dynamic, dynamic>{};
    requestMap["pageName"] = pageName;
    requestMap["uniqueId"] = uniqueId;
    requestMap["arguments"] = arguments;
    const BasicMessageChannel<dynamic> channel = BasicMessageChannel<dynamic>(
        'NativeRouterApi.pushFlutterRoute', StandardMessageCodec());

    final Map<dynamic, dynamic> replyMap = await channel.send(requestMap);
    if (replyMap == null) {
      throw PlatformException(
          code: 'error',
          message: 'Unable to establish connection on channel.',
          details: null);
    } else if (replyMap['error'] != null) {
      final Map<dynamic, dynamic> error = replyMap['error'];
      throw PlatformException(
          code: error['code'],
          message: error['message'],
          details: error['details']);
    } else {
      // noop
    }
  }

  Future<void> popRoute(String pageName, String uniqueId) async {
    final Map<dynamic, dynamic> requestMap = <dynamic, dynamic>{};
    requestMap["pageName"] = pageName;
    requestMap["uniqueId"] = uniqueId;

    const BasicMessageChannel<dynamic> channel = BasicMessageChannel<dynamic>(
        'NativeRouterApi.popRoute', StandardMessageCodec());

    final Map<dynamic, dynamic> replyMap = await channel.send(requestMap);
    if (replyMap == null) {
      throw PlatformException(
          code: 'error',
          message: 'Unable to establish connection on channel.',
          details: null);
    } else if (replyMap['error'] != null) {
      final Map<dynamic, dynamic> error = replyMap['error'];
      throw PlatformException(
          code: error['code'],
          message: error['message'],
          details: error['details']);
    } else {
      // noop
    }
  }
}
