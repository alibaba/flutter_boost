
import 'dart:async';
import 'dart:typed_data' show Uint8List, Int32List, Int64List, Float64List;

import 'package:flutter/services.dart';

class CommonParams {
  String pageName;
  String uniqueId;
  Map<Object, Object> arguments;
  bool opaque;
  String key;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['pageName'] = pageName;
    pigeonMap['uniqueId'] = uniqueId;
    pigeonMap['arguments'] = arguments;
    pigeonMap['opaque'] = opaque;
    pigeonMap['key'] = key;
    return pigeonMap;
  }

  static CommonParams decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return CommonParams()
      ..pageName = pigeonMap['pageName'] as String
      ..uniqueId = pigeonMap['uniqueId'] as String
      ..arguments = pigeonMap['arguments'] as Map<Object, Object>
      ..opaque = pigeonMap['opaque'] as bool
      ..key = pigeonMap['key'] as String;
  }
}

class StackInfo {
  List<Object> containers;
  Map<Object, Object> routes;

  Object encode() {
    final Map<Object, Object> pigeonMap = <Object, Object>{};
    pigeonMap['containers'] = containers;
    pigeonMap['routes'] = routes;
    return pigeonMap;
  }

  static StackInfo decode(Object message) {
    final Map<Object, Object> pigeonMap = message as Map<Object, Object>;
    return StackInfo()
      ..containers = pigeonMap['containers'] as List<Object>
      ..routes = pigeonMap['routes'] as Map<Object, Object>;
  }
}

abstract class FlutterRouterApi {
  void pushRoute(CommonParams arg);
  void popRoute(CommonParams arg);
  void removeRoute(CommonParams arg);
  void onForeground(CommonParams arg);
  void onBackground(CommonParams arg);
  void onNativeResult(CommonParams arg);
  void onContainerShow(CommonParams arg);
  void onContainerHide(CommonParams arg);
  void sendEventToFlutter(CommonParams arg);
  void onBackPressed();
  static void setup(FlutterRouterApi api) {
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.pushRoute', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.FlutterRouterApi.pushRoute was null. Expected CommonParams.');
          final CommonParams input = CommonParams.decode(message);
          api.pushRoute(input);
          return;
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.popRoute', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.FlutterRouterApi.popRoute was null. Expected CommonParams.');
          final CommonParams input = CommonParams.decode(message);
          api.popRoute(input);
          return;
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.removeRoute', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.FlutterRouterApi.removeRoute was null. Expected CommonParams.');
          final CommonParams input = CommonParams.decode(message);
          api.removeRoute(input);
          return;
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.onForeground', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.FlutterRouterApi.onForeground was null. Expected CommonParams.');
          final CommonParams input = CommonParams.decode(message);
          api.onForeground(input);
          return;
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.onBackground', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.FlutterRouterApi.onBackground was null. Expected CommonParams.');
          final CommonParams input = CommonParams.decode(message);
          api.onBackground(input);
          return;
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.onNativeResult', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.FlutterRouterApi.onNativeResult was null. Expected CommonParams.');
          final CommonParams input = CommonParams.decode(message);
          api.onNativeResult(input);
          return;
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.onContainerShow', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.FlutterRouterApi.onContainerShow was null. Expected CommonParams.');
          final CommonParams input = CommonParams.decode(message);
          api.onContainerShow(input);
          return;
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.onContainerHide', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.FlutterRouterApi.onContainerHide was null. Expected CommonParams.');
          final CommonParams input = CommonParams.decode(message);
          api.onContainerHide(input);
          return;
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.sendEventToFlutter', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.FlutterRouterApi.sendEventToFlutter was null. Expected CommonParams.');
          final CommonParams input = CommonParams.decode(message);
          api.sendEventToFlutter(input);
          return;
        });
      }
    }
    {
      const BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
          'dev.flutter.pigeon.FlutterRouterApi.onBackPressed', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object message) async {
          // ignore message
          api.onBackPressed();
          return;
        });
      }
    }
  }
}

class NativeRouterApi {
  /// Constructor for [NativeRouterApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NativeRouterApi({BinaryMessenger binaryMessenger}) : _binaryMessenger = binaryMessenger;

  final BinaryMessenger _binaryMessenger;

  Future<void> pushNativeRoute(CommonParams arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.NativeRouterApi.pushNativeRoute', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      // noop
    }
  }

  Future<void> pushFlutterRoute(CommonParams arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.NativeRouterApi.pushFlutterRoute', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      // noop
    }
  }

  Future<void> popRoute(CommonParams arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.NativeRouterApi.popRoute', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      // noop
    }
  }

  Future<StackInfo> getStackFromHost() async {
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.NativeRouterApi.getStackFromHost', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(null) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      return StackInfo.decode(replyMap['result']);
    }
  }

  Future<void> saveStackToHost(StackInfo arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.NativeRouterApi.saveStackToHost', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      // noop
    }
  }

  Future<void> sendEventToNative(CommonParams arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object> channel = BasicMessageChannel<Object>(
        'dev.flutter.pigeon.NativeRouterApi.sendEventToNative', const StandardMessageCodec(), binaryMessenger: _binaryMessenger);
    final Map<Object, Object> replyMap =
        await channel.send(encoded) as Map<Object, Object>;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object, Object> error = (replyMap['error'] as Map<Object, Object>);
      throw PlatformException(
        code: (error['code'] as String),
        message: error['message'] as String,
        details: error['details'],
      );
    } else {
      // noop
    }
  }
}
