import 'dart:async';

import 'package:flutter_boost/boost_navigator.dart';

///The request object in Interceptor,which is to passed
class BoostInterceptorOption {
  BoostInterceptorOption(this.name, this.arguments);

  ///your page name in route table
  String name;

  ///the arguments you want to pass in next page
  Map<String, dynamic> arguments;

  @override
  String toString() =>
      "Instance of 'BoostInterceptorOption'(name:$name, arguments:$arguments)";
}

enum InterceptorResultType {
  next,
  resolve,
}

class InterceptorState<T> {
  InterceptorState(this.data, [this.type = InterceptorResultType.next]);

  T data;
  InterceptorResultType type;
}

class _BaseHandler {
  // ignore: always_specify_types
  final _completer = Completer<InterceptorState>();

  // ignore: always_specify_types
  Future<InterceptorState> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;
}

/// Handler for push interceptor.
class PushInterceptorHandler extends _BaseHandler {
  /// Continue to call the next push interceptor.
  void next(BoostInterceptorOption options) {
    _completer.complete(InterceptorState<BoostInterceptorOption>(options));
  }

  /// Return the result directly!
  /// Other request interceptor(s) will not be executed.
  ///
  /// [result]: Response object to return.
  void resolve(Object result) {
    _completer.complete(
      InterceptorState<Object>(
        result,
        InterceptorResultType.resolve,
      ),
    );
  }
}

///The Interceptor to intercept the [push] method in [BoostNavigator]
class BoostInterceptor {
  /// The callback will be executed before the push is initiated.
  ///
  /// If you want to continue the push, call [handler.next].
  ///
  /// If you want to complete the push with some custom data，
  /// you can resolve a [result] object with [handler.resolve].
  ///
  void onPush(BoostInterceptorOption option, PushInterceptorHandler handler) =>
      handler.next(option);
}
