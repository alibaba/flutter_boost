import 'package:flutter_boost/container/boost_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/AIOService/NavigationService/service/NavigationService.dart';


class NavigatorCanPopObserver extends BoostNavigatorObserver{
  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    _noticeCanPopToNative(route);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    // TODO: implement didPop
    super.didPop(route, previousRoute);
    _noticeCanPopToNative(route);
  }
  
  

  _noticeCanPopToNative(Route route){
    bool canPop = route.navigator.canPop();
    NavigationService.flutterCanPop(canPop);
  }
}