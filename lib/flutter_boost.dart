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

import 'package:flutter/material.dart';
import 'package:flutter_boost/messaging/boost_message_channel.dart';
import 'package:flutter_boost/container/boost_container.dart';
import 'package:flutter_boost/container/container_manager.dart';
import 'package:flutter_boost/router/router.dart';

import 'container/container_coordinator.dart';
import 'observers_holders.dart';

export 'container/boost_container.dart';
export 'container/container_manager.dart';
import 'package:flutter/services.dart';

typedef Widget PageBuilder(String pageName, Map params, String uniqueId);

typedef Route PrePushRoute(
    String pageName, String uniqueId, Map params, Route route);

typedef void PostPushRoute(
    String pageName, String uniqueId, Map params, Route route, Future result);

class FlutterBoost {

  static final FlutterBoost _instance = FlutterBoost();
  final GlobalKey<ContainerManagerState> containerManagerKey =
      GlobalKey<ContainerManagerState>();
  final ObserversHolder _observersHolder = ObserversHolder();
  final Router _router = Router();
  final MethodChannel _methodChannel = MethodChannel('flutter_boost_method');

  int _callbackID = 0;

  static FlutterBoost get singleton => _instance;

  static ContainerManagerState get containerManager =>
      _instance.containerManagerKey.currentState;

  static TransitionBuilder init(
      {TransitionBuilder builder,
        PrePushRoute prePush,
        PostPushRoute postPush}) {
    return (BuildContext context, Widget child) {
      assert(child is Navigator, 'child must be Navigator, what is wrong?');

      final BoostContainerManager manager = BoostContainerManager(
          key: _instance.containerManagerKey,
          initNavigator: child,
          prePushRoute: prePush,
          postPushRoute: postPush);

      if (builder != null) {
        return builder(context, manager);
      } else {
        return manager;
      }
    };
  }

  ObserversHolder get observersHolder => _observersHolder;

  FlutterBoost() {
    BoostMessageChannel.methodChannel = _methodChannel;
    _methodChannel.setMethodCallHandler((MethodCall call){
      if(call.method == "__event__"){
        return BoostMessageChannel.handleEventCall(call);
      }else if(call.method == "didDisappearPageContainer"){
        String pageName = call.arguments["pageName"];
        Map params = call.arguments["params"];
        String uniqueId = call.arguments["uniqueId"];
        ContainerCoordinator.singleton
            .nativeContainerDidDisappear(pageName, params, uniqueId);
      }else if(call.method == "nativeContainerDidInit"){
        String pageName = call.arguments["pageName"];
        Map params = call.arguments["params"];
        String uniqueId = call.arguments["uniqueId"];
        ContainerCoordinator.singleton
            .nativeContainerDidInit(pageName, params, uniqueId);
      }else if(call.method == "didShowPageContainer"){
        String pageName = call.arguments["pageName"];
        Map params = call.arguments["params"];
        String uniqueId = call.arguments["uniqueId"];
        ContainerCoordinator.singleton
            .nativeContainerDidShow(pageName, params, uniqueId);
      }else if(call.method == "willDeallocPageContainer"){
        String pageName = call.arguments["pageName"];
        Map params = call.arguments["params"];
        String uniqueId = call.arguments["uniqueId"];
        ContainerCoordinator.singleton
            .nativeContainerWillDealloc(pageName, params, uniqueId);
      }else if(call.method == "willDisappearPageContainer"){
        String pageName = call.arguments["pageName"];
        Map params = call.arguments["params"];
        String uniqueId = call.arguments["uniqueId"];
        ContainerCoordinator.singleton
            .nativeContainerWillDisappear(pageName, params, uniqueId);
      }else if(call.method == "willShowPageContainer"){
        String pageName = call.arguments["pageName"];
        Map params = call.arguments["params"];
        String uniqueId = call.arguments["uniqueId"];
        ContainerCoordinator.singleton
            .nativeContainerWillShow(pageName, params, uniqueId);
      }
      return Future<dynamic>((){});
    });

  }

  ///Register a default page builder.
  void registerDefaultPageBuilder(PageBuilder builder) {
    ContainerCoordinator.singleton.registerDefaultPageBuilder(builder);
  }

  ///Register a map builders
  void registerPageBuilders(Map<String, PageBuilder> builders) {
    ContainerCoordinator.singleton.registerPageBuilders(builders);
  }

  Future<Map<dynamic,dynamic>> open(String url,{Map<String,dynamic> urlParams,Map<String,dynamic> exts}){
    if(urlParams == null) {
      urlParams = Map();
    }
    if(exts == null){
      exts = Map();
    }
    urlParams["__calback_id__"] = _callbackID;
    _callbackID += 2;
    return _router.open(url,urlParams: urlParams,exts: exts);
  }

  Future<bool> close(String id,{Map<String,dynamic> result,Map<String,dynamic> exts}){
    if(result == null) {
      result = Map();
    }
    if(exts == null){
      exts = Map();
    }
    return _router.close(id,result: result,exts: exts);
  }

  //Listen broadcast event from native.
  Function addEventListener(String name , EventListener listener){
    return BoostMessageChannel.addEventListener(name, listener);
  }

  //Send broadcast event to native.
  void sendEvent(String name , Map arguments){
    BoostMessageChannel.sendEvent(name, arguments);
  }

  Future<Map<String,dynamic>> openPage(String name, Map params,{bool animated}) {
    Map<String,dynamic> exts = Map();
    if(animated != null){
      exts["animated"] = animated;
    }else{
      exts["animated"] = true;
    }
    return open(name,urlParams: params , exts: exts);
  }

  Future<bool> closePage(String url, String id, Map params,
      {bool animated}) {

    Map<String,dynamic> exts = Map();
    if(animated != null){
      exts["animated"] = animated;
    }else{
      exts["animated"] = true;
    }

    if(url != null){
      exts["url"] = url;
    }

    if(params != null){
      exts["params"] = params;
    }

    return close(id, result: {} , exts: exts);
  }


  //Close currentPage page.
  Future<bool> closeCurPage(Map params) {
    return _router.closeCurPage(params);
  }

  Future<bool> closePageForContext(BuildContext context) {
    BoostContainerSettings settings = BoostContainer.of(context).settings;
    return closePage(settings.name, settings.uniqueId, settings.params,
        animated: true);
  }

  ///query current top page and show it
  static void handleOnStartPage() async {
    final Map<dynamic, dynamic> pageInfo =
        await BoostMessageChannel.pageOnStart(<dynamic, dynamic>{});
    if (pageInfo == null || pageInfo.isEmpty) return;

    if (pageInfo.containsKey("name") &&
        pageInfo.containsKey("params") &&
        pageInfo.containsKey("uniqueId")) {
      ContainerCoordinator.singleton.nativeContainerDidShow(
          pageInfo["name"], pageInfo["params"], pageInfo["uniqueId"]);
    }
  }


  ///register for Container changed callbacks
  VoidCallback addContainerObserver(BoostContainerObserver observer) =>
      _observersHolder.addObserver<BoostContainerObserver>(observer);

  ///register for Container lifecycle callbacks
  VoidCallback addBoostContainerLifeCycleObserver(
          BoostContainerLifeCycleObserver observer) =>
      _observersHolder.addObserver<BoostContainerLifeCycleObserver>(observer);

  ///register callbacks for Navigators push & pop
  VoidCallback addBoostNavigatorObserver(BoostNavigatorObserver observer) =>
      _observersHolder.addObserver<BoostNavigatorObserver>(observer);


}
