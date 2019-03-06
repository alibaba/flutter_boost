/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 Alibaba Group
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_boost/container/container_coordinator.dart';
import 'package:xservice_kit/ServiceCallHandler.dart';
import 'package:xservice_kit/ServiceGateway.dart';

class NavigationService_didShowPageContainer extends ServiceCallHandler {
  static void regsiter() {
    ServiceGateway.sharedInstance()
        .registerHandler(new NavigationService_didShowPageContainer());
  }

  @override
  String name() {
    return "didShowPageContainer";
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
    return ContainerCoordinator.singleton
        .nativeContainerDidShow(pageName, params, uniqueId);
  }
}
