import 'package:flutter_boost/boost_navigator.dart';

///The Interceptor to intercept the [push] method in [BoostNavigator]
abstract class BoostInterceptor {
  ///The callback of BoostInterceptor for push new page method
  ///the result indicates wherther the page operation will be blocked,
  ///If you return true,nothing will happen,otherwise new page will push
  ///
  ///[request] the [BoostInterceptorRequest] which contains the name and arguments
  Future<void> onPush(BoostInterceptorResponse response);
}

///The request object in Interceptor,which is to passed
class BoostInterceptorResponse {
  BoostInterceptorResponse({this.isBlocked, this.name, this.arguments});

  ///Indicates the [BoostInterceptorRequest] is blocked or not.
  ///If [isBlocked] , the push operation will be blocked and nothing will happen.
  bool isBlocked = false;

  ///your page name in route table
  String name;

  ///the arguments you want to pass in next page
  Map<String, dynamic> arguments;
}
