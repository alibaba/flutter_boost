// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import
import 'dart:async';
import 'dart:typed_data' show ByteData, Uint8List, Int32List, Int64List, Float64List;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show WriteBuffer, ReadBuffer;
import 'package:flutter/services.dart';

const String _flutterBoostBridgeName = 'com.idlefish.flutterboost.direct.FlutterBoostRouterApi';
const int _fastMessageKindRequest = 0;
const int _fastMessageKindReply = 1;
const int _methodPushNativeRoute = 1;
const int _methodPushFlutterRoute = 2;
const int _methodPopNativeRoute = 3;
const int _methodGetStackFromHost = 4;
const int _methodSaveStackToHost = 5;
const int _methodSendEventToNative = 6;
const int _methodPushRoute = 101;
const int _methodPopRoute = 102;
const int _methodRemoveRoute = 103;
const int _methodOnForeground = 104;
const int _methodOnBackground = 105;
const int _methodOnNativeResult = 106;
const int _methodOnContainerShow = 107;
const int _methodOnContainerHide = 108;
const int _methodSendEventToFlutter = 109;
const int _methodOnBackPressed = 110;

class _NativeFastBridgeClient {
  _NativeFastBridgeClient._();

  static int _nextReplyId = 1;
  static final Map<int, Completer<Object?>> _pendingReplies = <int, Completer<Object?>>{};

  static Future<Object?> invokeNative(int method, Object? message, MessageCodec<Object?> codec) {
    final int replyId = _nextReplyId++;
    final Completer<Object?> completer = Completer<Object?>.sync();
    _pendingReplies[replyId] = completer;
    ui.NativeFastMessageBridge.invokeNative(
      _flutterBoostBridgeName,
      method,
      _encodeMessage(codec, message),
      replyId,
    );
    return completer.future;
  }

  static void handleReply(int replyId, Uint8List payload) {
    final Completer<Object?>? completer = _pendingReplies.remove(replyId);
    if (completer == null) {
      return;
    }
    completer.complete(_decodeMessage(NativeRouterApi.codec, payload));
  }
}

Uint8List? _encodeMessage(MessageCodec<Object?> codec, Object? message) {
  final ByteData? data = codec.encodeMessage(message);
  if (data == null) {
    return null;
  }
  return Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes);
}

Object? _decodeMessage(MessageCodec<Object?> codec, Uint8List payload) {
  if (payload.isEmpty) {
    return null;
  }
  return codec.decodeMessage(ByteData.view(payload.buffer, payload.offsetInBytes, payload.lengthInBytes));
}

PlatformException _platformExceptionFromReply(Map<Object?, Object?>? replyMap) {
  if (replyMap == null) {
    return PlatformException(
      code: 'channel-error',
      message: 'Unable to establish connection on native fast bridge.',
    );
  }
  final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
  return PlatformException(
    code: (error['code'] as String?)!,
    message: error['message'] as String?,
    details: error['details'],
  );
}

class CommonParams {
  CommonParams({
    this.opaque,
    this.key,
    this.pageName,
    this.uniqueId,
    this.arguments,
  });

  bool? opaque;
  String? key;
  String? pageName;
  String? uniqueId;
  Map<String?, Object?>? arguments;

  Object encode() {
    final Map<Object?, Object?> valueMap = <Object?, Object?>{};
    valueMap['opaque'] = opaque;
    valueMap['key'] = key;
    valueMap['pageName'] = pageName;
    valueMap['uniqueId'] = uniqueId;
    valueMap['arguments'] = arguments;
    return valueMap;
  }

  static CommonParams decode(Object message) {
    final Map<Object?, Object?> valueMap = message as Map<Object?, Object?>;
    return CommonParams(
      opaque: valueMap['opaque'] as bool?,
      key: valueMap['key'] as String?,
      pageName: valueMap['pageName'] as String?,
      uniqueId: valueMap['uniqueId'] as String?,
      arguments: (valueMap['arguments'] as Map<Object?, Object?>?)?.cast<String?, Object?>(),
    );
  }
}

class StackInfo {
  StackInfo({
    this.ids,
    this.containers,
  });

  List<String?>? ids;
  Map<String?, FlutterContainer?>? containers;

  Object encode() {
    final Map<Object?, Object?> valueMap = <Object?, Object?>{};
    valueMap['ids'] = ids;
    valueMap['containers'] = containers;
    return valueMap;
  }

  static StackInfo decode(Object message) {
    final Map<Object?, Object?> valueMap = message as Map<Object?, Object?>;
    return StackInfo(
      ids: (valueMap['ids'] as List<Object?>?)?.cast<String?>(),
      containers: (valueMap['containers'] as Map<Object?, Object?>?)?.cast<String?, FlutterContainer?>(),
    );
  }
}

class FlutterContainer {
  FlutterContainer({
    this.pages,
  });

  List<FlutterPage?>? pages;

  Object encode() {
    final Map<Object?, Object?> valueMap = <Object?, Object?>{};
    valueMap['pages'] = pages;
    return valueMap;
  }

  static FlutterContainer decode(Object message) {
    final Map<Object?, Object?> valueMap = message as Map<Object?, Object?>;
    return FlutterContainer(
      pages: (valueMap['pages'] as List<Object?>?)?.cast<FlutterPage?>(),
    );
  }
}

class FlutterPage {
  FlutterPage({
    this.withContainer,
    this.pageName,
    this.uniqueId,
    this.arguments,
  });

  bool? withContainer;
  String? pageName;
  String? uniqueId;
  Map<String?, Object?>? arguments;

  Object encode() {
    final Map<Object?, Object?> valueMap = <Object?, Object?>{};
    valueMap['withContainer'] = withContainer;
    valueMap['pageName'] = pageName;
    valueMap['uniqueId'] = uniqueId;
    valueMap['arguments'] = arguments;
    return valueMap;
  }

  static FlutterPage decode(Object message) {
    final Map<Object?, Object?> valueMap = message as Map<Object?, Object?>;
    return FlutterPage(
      withContainer: valueMap['withContainer'] as bool?,
      pageName: valueMap['pageName'] as String?,
      uniqueId: valueMap['uniqueId'] as String?,
      arguments: (valueMap['arguments'] as Map<Object?, Object?>?)?.cast<String?, Object?>(),
    );
  }
}

class _NativeRouterApiCodec extends StandardMessageCodec {
  const _NativeRouterApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is CommonParams) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else 
    if (value is FlutterContainer) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else 
    if (value is FlutterPage) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else 
    if (value is StackInfo) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    } else 
{
      super.writeValue(buffer, value);
    }
  }
  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:       
        return CommonParams.decode(readValue(buffer)!);
      
      case 129:       
        return FlutterContainer.decode(readValue(buffer)!);
      
      case 130:       
        return FlutterPage.decode(readValue(buffer)!);
      
      case 131:       
        return StackInfo.decode(readValue(buffer)!);
      
      default:      
        return super.readValueOfType(type, buffer);
      
    }
  }
}

class NativeRouterApi {
  /// Constructor for [NativeRouterApi].  The [binaryMessenger] named argument is
  /// kept for source compatibility; FlutterBoost routes through the native fast
  /// bridge in this engine.
  NativeRouterApi({BinaryMessenger? binaryMessenger});

  static const MessageCodec<Object?> codec = _NativeRouterApiCodec();

  Future<void> pushNativeRoute(CommonParams arg_param) async {
    final Map<Object?, Object?>? replyMap =
        await _NativeFastBridgeClient.invokeNative(_methodPushNativeRoute, <Object?>[arg_param], codec) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on native fast bridge.',
      );
    } else if (replyMap['error'] != null) {
      throw _platformExceptionFromReply(replyMap);
    } else {
      return;
    }
  }

  Future<void> pushFlutterRoute(CommonParams arg_param) async {
    final Map<Object?, Object?>? replyMap =
        await _NativeFastBridgeClient.invokeNative(_methodPushFlutterRoute, <Object?>[arg_param], codec) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on native fast bridge.',
      );
    } else if (replyMap['error'] != null) {
      throw _platformExceptionFromReply(replyMap);
    } else {
      return;
    }
  }

  Future<void> popRoute(CommonParams arg_param) async {
    final Map<Object?, Object?>? replyMap =
        await _NativeFastBridgeClient.invokeNative(_methodPopNativeRoute, <Object?>[arg_param], codec) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on native fast bridge.',
      );
    } else if (replyMap['error'] != null) {
      throw _platformExceptionFromReply(replyMap);
    } else {
      return;
    }
  }

  Future<StackInfo> getStackFromHost() async {
    final Map<Object?, Object?>? replyMap =
        await _NativeFastBridgeClient.invokeNative(_methodGetStackFromHost, null, codec) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on native fast bridge.',
      );
    } else if (replyMap['error'] != null) {
      throw _platformExceptionFromReply(replyMap);
    } else if (replyMap['result'] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyMap['result'] as StackInfo?)!;
    }
  }

  Future<void> saveStackToHost(StackInfo arg_stack) async {
    final Map<Object?, Object?>? replyMap =
        await _NativeFastBridgeClient.invokeNative(_methodSaveStackToHost, <Object?>[arg_stack], codec) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on native fast bridge.',
      );
    } else if (replyMap['error'] != null) {
      throw _platformExceptionFromReply(replyMap);
    } else {
      return;
    }
  }

  Future<void> sendEventToNative(CommonParams arg_params) async {
    final Map<Object?, Object?>? replyMap =
        await _NativeFastBridgeClient.invokeNative(_methodSendEventToNative, <Object?>[arg_params], codec) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on native fast bridge.',
      );
    } else if (replyMap['error'] != null) {
      throw _platformExceptionFromReply(replyMap);
    } else {
      return;
    }
  }
}

class _FlutterRouterApiCodec extends StandardMessageCodec {
  const _FlutterRouterApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is CommonParams) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else 
{
      super.writeValue(buffer, value);
    }
  }
  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:       
        return CommonParams.decode(readValue(buffer)!);
      
      default:      
        return super.readValueOfType(type, buffer);
      
    }
  }
}
abstract class FlutterRouterApi {
  static const MessageCodec<Object?> codec = _FlutterRouterApiCodec();

  void pushRoute(CommonParams param);
  void popRoute(CommonParams param);
  void removeRoute(CommonParams param);
  void onForeground(CommonParams param);
  void onBackground(CommonParams param);
  void onNativeResult(CommonParams param);
  void onContainerShow(CommonParams param);
  void onContainerHide(CommonParams param);
  void sendEventToFlutter(CommonParams param);
  Future<void> onBackPressed();
  static void setup(FlutterRouterApi? api, {BinaryMessenger? binaryMessenger}) {
    if (api == null) {
      ui.NativeFastMessageBridge.setMessageHandler(_flutterBoostBridgeName, null);
      return;
    }
    ui.NativeFastMessageBridge.setMessageHandler(_flutterBoostBridgeName,
        (int kind, int method, int replyId, Uint8List payload) {
      if (kind == _fastMessageKindReply) {
        _NativeFastBridgeClient.handleReply(replyId, payload);
        return;
      }
      assert(kind == _fastMessageKindRequest, 'Unknown native fast message kind: $kind.');
      final Object? message = _decodeMessage(codec, payload);
      try {
        switch (method) {
          case _methodPushRoute:
            assert(message != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.pushRoute was null.');
            final List<Object?> args = (message as List<Object?>?)!;
            final CommonParams? arg_param = (args[0] as CommonParams?);
            assert(arg_param != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.pushRoute was null, expected non-null CommonParams.');
            api.pushRoute(arg_param!);
            return;
          case _methodPopRoute:
            assert(message != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.popRoute was null.');
            final List<Object?> args = (message as List<Object?>?)!;
            final CommonParams? arg_param = (args[0] as CommonParams?);
            assert(arg_param != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.popRoute was null, expected non-null CommonParams.');
            api.popRoute(arg_param!);
            break;
          case _methodRemoveRoute:
            assert(message != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.removeRoute was null.');
            final List<Object?> args = (message as List<Object?>?)!;
            final CommonParams? arg_param = (args[0] as CommonParams?);
            assert(arg_param != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.removeRoute was null, expected non-null CommonParams.');
            api.removeRoute(arg_param!);
            break;
          case _methodOnForeground:
            assert(message != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onForeground was null.');
            final List<Object?> args = (message as List<Object?>?)!;
            final CommonParams? arg_param = (args[0] as CommonParams?);
            assert(arg_param != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onForeground was null, expected non-null CommonParams.');
            api.onForeground(arg_param!);
            break;
          case _methodOnBackground:
            assert(message != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onBackground was null.');
            final List<Object?> args = (message as List<Object?>?)!;
            final CommonParams? arg_param = (args[0] as CommonParams?);
            assert(arg_param != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onBackground was null, expected non-null CommonParams.');
            api.onBackground(arg_param!);
            break;
          case _methodOnNativeResult:
            assert(message != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onNativeResult was null.');
            final List<Object?> args = (message as List<Object?>?)!;
            final CommonParams? arg_param = (args[0] as CommonParams?);
            assert(arg_param != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onNativeResult was null, expected non-null CommonParams.');
            api.onNativeResult(arg_param!);
            break;
          case _methodOnContainerShow:
            assert(message != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onContainerShow was null.');
            final List<Object?> args = (message as List<Object?>?)!;
            final CommonParams? arg_param = (args[0] as CommonParams?);
            assert(arg_param != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onContainerShow was null, expected non-null CommonParams.');
            api.onContainerShow(arg_param!);
            break;
          case _methodOnContainerHide:
            assert(message != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onContainerHide was null.');
            final List<Object?> args = (message as List<Object?>?)!;
            final CommonParams? arg_param = (args[0] as CommonParams?);
            assert(arg_param != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.onContainerHide was null, expected non-null CommonParams.');
            api.onContainerHide(arg_param!);
            break;
          case _methodSendEventToFlutter:
            assert(message != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.sendEventToFlutter was null.');
            final List<Object?> args = (message as List<Object?>?)!;
            final CommonParams? arg_param = (args[0] as CommonParams?);
            assert(arg_param != null, 'Argument for com.idlefish.flutterboost.direct.FlutterRouterApi.sendEventToFlutter was null, expected non-null CommonParams.');
            api.sendEventToFlutter(arg_param!);
            break;
          case _methodOnBackPressed:
            api.onBackPressed().then((_) {
              ui.NativeFastMessageBridge.invokeNative(_flutterBoostBridgeName, 0, null, replyId);
            }).catchError((Object error) {
              final Object wrapped = <Object?, Object?>{'error': <Object?, Object?>{'code': error.runtimeType.toString(), 'message': error.toString(), 'details': null}};
              ui.NativeFastMessageBridge.invokeNative(_flutterBoostBridgeName, 0, _encodeMessage(codec, wrapped), replyId);
            });
            return;
          default:
            throw PlatformException(code: 'unknown-method', message: 'Unknown FlutterRouterApi method: $method.');
        }
        ui.NativeFastMessageBridge.invokeNative(_flutterBoostBridgeName, 0, null, replyId);
      } catch (error) {
        final Object wrapped = <Object?, Object?>{'error': <Object?, Object?>{'code': error.runtimeType.toString(), 'message': error.toString(), 'details': null}};
        ui.NativeFastMessageBridge.invokeNative(_flutterBoostBridgeName, 0, _encodeMessage(codec, wrapped), replyId);
      }
    });
  }
}
