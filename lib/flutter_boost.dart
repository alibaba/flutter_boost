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
import 'package:flutter_boost/messaging/service/navigation_service.dart';
import 'package:flutter_boost/container/boost_container.dart';
import 'package:flutter_boost/container/container_manager.dart';
import 'package:flutter_boost/messaging/page_result_mediator.dart';
import 'package:flutter_boost/router/router.dart';

import 'container/container_coordinator.dart';
import 'messaging/base/message_dispatcher.dart';
import 'messaging/handlers/did_disappear_page_container_handler.dart';
import 'messaging/handlers/did_show_page_container_handler.dart';
import 'messaging/handlers/did_init_page_container_handler.dart';
import 'messaging/handlers/on_native_page_result_handler.dart';
import 'messaging/handlers/will_dealloc_page_container_handler.dart';
import 'messaging/handlers/will_show_page_container_handler.dart';
import 'messaging/handlers/will_disappear_page_container_handler.dart';
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
  final PageResultMediator _resultMediator = PageResultMediator();
  final Router _router = Router();

  final MethodChannel _methodChannel = MethodChannel('flutter_boost');
  final MessageDispatcher _dispatcher = MessageDispatcher();

  FlutterBoost() {
    _router.resultMediator = _resultMediator;

    //Config message handlers
    NavigationService.methodChannel = _methodChannel;
    _dispatcher.registerHandler(DidDisappearPageContainerHandler());
    _dispatcher.registerHandler(DidInitPageContainerHandler());
    _dispatcher.registerHandler(DidShowPageContainerHandler());
    _dispatcher.registerHandler(OnNativePageResultHandler());
    _dispatcher.registerHandler(WillDeallocPageContainerHandler());
    _dispatcher.registerHandler(WillShowPageContainerHandler());
    _dispatcher.registerHandler(WillDisappearPageContainerHandler());
    _methodChannel.setMethodCallHandler((MethodCall call){
      _dispatcher.dispatch(call);
    });

  }

  static FlutterBoost get singleton => _instance;

  static ContainerManagerState get containerManager =>
      _instance.containerManagerKey.currentState;

  static TransitionBuilder init(
      {TransitionBuilder builder,
      PrePushRoute prePush,
      PostPushRoute postPush}) {
    return (BuildContext context, Widget child) {
      assert(child is Navigator, 'child must be Navigator, what is wrong?');

      //Logger.log('Running flutter boost opt!');

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

  ///Register a default page builder.
  void registerDefaultPageBuilder(PageBuilder builder) {
    ContainerCoordinator.singleton.registerDefaultPageBuilder(builder);
  }

  ///Register page builder for a key.
  void registerPageBuilder(String pageName, PageBuilder builder) {
    ContainerCoordinator.singleton.registerPageBuilder(pageName, builder);
  }

  ///Register a map builders
  void registerPageBuilders(Map<String, PageBuilder> builders) {
    ContainerCoordinator.singleton.registerPageBuilders(builders);
  }

  Future<bool> openPage(String url, Map params,
      {bool animated, PageResultHandler resultHandler}) {
    return _router.openPage(url, params,
        animated: animated, resultHandler: resultHandler);
  }

  Future<bool> closePage(String url, String pageId, Map params,
      {bool animated}) {
    return _router.closePage(url, pageId, params, animated: animated);
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
        await NavigationService.pageOnStart(<dynamic, dynamic>{});
    if (pageInfo == null || pageInfo.isEmpty) return;

    if (pageInfo.containsKey("name") &&
        pageInfo.containsKey("params") &&
        pageInfo.containsKey("uniqueId")) {
      ContainerCoordinator.singleton.nativeContainerDidShow(
          pageInfo["name"], pageInfo["params"], pageInfo["uniqueId"]);
    }
  }


  bool onPageResult(String key, Map resultData, Map params) {

    if(_resultMediator.isResultId(key)){
      _resultMediator.onPageResult(key, resultData,params);
    }else{
      containerManager?.containerStateOf(key)?.performOnResult(resultData);
    }
    return true;

  }

  VoidCallback setPageResultHandler(String key, PageResultHandler handler) {
    return _resultMediator.setPageResultHandler(key, handler);
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
