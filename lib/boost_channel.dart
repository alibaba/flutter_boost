import 'package:flutter/services.dart';

abstract class FlutterRouterApi {
  void pushRoute(String pageName, Map arguments);

  void popRoute();

  void pushOrShowRoute(
      String pageName, String uniqueId, Map arguments, bool openContainer);

  void showTabRoute(String groupName, String pageName, String uniqueId, Map arguments);

  static void setup(FlutterRouterApi api) {
    {
      const BasicMessageChannel<dynamic> channel = BasicMessageChannel<dynamic>(
          'FlutterRouterApi.pushRoute', StandardMessageCodec());
      channel.setMessageHandler((dynamic message) async {
        final Map<dynamic, dynamic> mapMessage =
            message as Map<dynamic, dynamic>;
        final String pageName = mapMessage['pageName'];
        final Map arguments = mapMessage['arguments'];
        api.pushRoute(pageName, arguments);
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
    {
      const BasicMessageChannel<dynamic> channel = BasicMessageChannel<dynamic>(
          'FlutterRouterApi.pushOrShowRoute', StandardMessageCodec());
      channel.setMessageHandler((dynamic message) async {
        final Map<dynamic, dynamic> mapMessage =
            message as Map<dynamic, dynamic>;
        final String pageName = mapMessage['pageName'];
        final String uniqueId = mapMessage['uniqueId'];
        final bool openContainer = mapMessage['openContainer'];
        final Map arguments = mapMessage['arguments'];

        api.pushOrShowRoute(pageName, uniqueId, arguments, openContainer);
      });
    }
    {
      const BasicMessageChannel<dynamic> channel = BasicMessageChannel<dynamic>(
          'FlutterRouterApi.showTabRoute', StandardMessageCodec());
      channel.setMessageHandler((dynamic message) async {
        final Map<dynamic, dynamic> mapMessage =
            message as Map<dynamic, dynamic>;
        final String groupName = mapMessage['groupName'];
        final String pageName = mapMessage['pageName'];
        final String uniqueId = mapMessage['uniqueId'];
        final Map arguments = mapMessage['arguments'];

        api.showTabRoute(groupName, pageName, uniqueId, arguments);
      });
    }
  }
}

///
///
/// Native测接口
///
class NativeRouterApi {
  Future<void> pushNativeRoute(
      String pageName, String uniqueId, Map arguments) async {
    final Map<dynamic, dynamic> requestMap = <dynamic, dynamic>{};
    requestMap['pageName'] = pageName;
    requestMap['uniqueId'] = uniqueId;
    requestMap['arguments'] = arguments;

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
    requestMap['pageName'] = pageName;
    requestMap['uniqueId'] = uniqueId;
    requestMap['arguments'] = arguments;
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

  Future<void> popRoute(String pageName, String uniqueId, Map arguments) async {
    final Map<dynamic, dynamic> requestMap = <dynamic, dynamic>{};
    requestMap['pageName'] = pageName;
    requestMap['uniqueId'] = uniqueId;
    requestMap['arguments'] = arguments;
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
