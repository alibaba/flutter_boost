import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xservice_kit/ServiceCallHandler.dart';
import 'package:xservice_kit/ServiceGateway.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost/AIOService/NavigationService/service/NavigationService.dart';

class NavigationService_canPop extends ServiceCallHandler {
  static void regsiter() {
    ServiceGateway.sharedInstance()
        .registerHandler(new NavigationService_canPop());
  }

  @override
  String name() {
    return "canPop";
  }

  @override
  String service() {
    return "NavigationService";
  }

  @override
  Future<bool> onMethodCall(MethodCall call) {
    return onCall(call.arguments["pageName"], call.arguments["params"],
        call.arguments["uniqueId"]);
  }

//==============================================Do not edit code above!

  Future<bool> onCall(String pageName, Map params, String uniqueId) async {
    NavigatorState navigator = FlutterBoost.containerManager.onstageContainer;
    bool canPop = navigator.canPop();
    NavigationService.flutterCanPop(canPop);
    return true;
  }
}