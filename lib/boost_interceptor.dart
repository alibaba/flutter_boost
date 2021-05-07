import 'package:flutter_boost/boost_navigator.dart';

///The Interceptor to intercept the [push] method in [BoostNavigator]
abstract class BoostInterceptor {
  ///The callback of BoostInterceptor for push new page method
  Future<void> onPush(BoostInterceptorOption option);
}

///The request object in Interceptor,which is to passed
class BoostInterceptorOption {
  BoostInterceptorOption({this.isBlocked, this.name, this.arguments});

  ///Indicates the [BoostInterceptorRequest] is blocked or not.
  ///If [isBlocked] , the push operation will be blocked and nothing will happen.
  bool isBlocked = false;

  ///your page name in route table
  String name;

  ///the arguments you want to pass in next page
  Map<String, dynamic> arguments;
}
