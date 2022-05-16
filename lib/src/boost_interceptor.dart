import 'boost_navigator.dart';

/// The request object in Interceptor,which is to passed
class BoostInterceptorOption {
  BoostInterceptorOption(this.name,
      {this.uniqueId, this.isFromHost, this.arguments});

  /// Your page name in route table
  String name;

  /// Unique identifier for the route
  String uniqueId;

  /// Whether or not the flutter page was opened by host
  bool isFromHost;

  /// The arguments you want to pass in next page
  Map<String, dynamic> arguments;

  @override
  String toString() => "Instance of 'BoostInterceptorOption'(name:$name, "
      "isFromHost:$isFromHost, uniqueId:$uniqueId, arguments:$arguments)";
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
  InterceptorState get state => _state;
  InterceptorState _state;
}

/// Handler for push interceptor.
class PushInterceptorHandler extends _BaseHandler {
  /// Continue to call the next push interceptor.
  void next(BoostInterceptorOption options) {
    _state = InterceptorState<BoostInterceptorOption>(options);
  }

  /// Return the result directly!
  /// Other interceptor(s) will not be executed.
  ///
  /// [result]: Response object to return.
  void resolve(Object result) {
    _state = InterceptorState<Object>(result, InterceptorResultType.resolve);
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
  void onPrePush(
          BoostInterceptorOption option, PushInterceptorHandler handler) =>
      handler.next(option);

  /// The callback will be executed after the push have been finish.
  ///
  /// If have other interceptors, call [handler.next].
  ///
  /// If you want to complete the push finish event with some custom data，
  /// you can resolve a [result] object with [handler.resolve].
  void onPostPush(
          BoostInterceptorOption option, PushInterceptorHandler handler) =>
      handler.next(option);
}
