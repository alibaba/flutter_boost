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
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'container/boost_container.dart';
import 'container/container_coordinator.dart';
import 'container/container_coordinator.dart';
import 'container/container_manager.dart';

import 'channel/boost_channel.dart';
import 'container/container_coordinator.dart';
import 'observers_holders.dart';

export 'container/boost_container.dart';
export 'container/container_manager.dart';
export 'flutter_boost_api.dart';
export 'container/container_coordinator.dart' show BoostRouteSettings;

typedef Widget PageBuilder(String pageName, Map params, String uniqueId);

typedef Route PrePushRoute(String url, String uniqueId, Map params,
    Route route);

typedef void PostPushRoute(String url, String uniqueId, Map params, Route route,
    Future result);

typedef Route FlutterBoostRouteBuilder(Widget widget);




class FlutterBoost {
  static final FlutterBoost _instance = FlutterBoost();
  final GlobalKey<ContainerManagerState> containerManagerKey =
  GlobalKey<ContainerManagerState>();
  final ObserversHolder _observersHolder = ObserversHolder();
  final BoostChannel _boostChannel = BoostChannel();

  static FlutterBoost get singleton => _instance;

  static ContainerManagerState get containerManager =>
      _instance.containerManagerKey.currentState;

  static void onPageStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      singleton.channel.invokeMethod<Map>('pageOnStart').then((Map pageInfo) {
        if (pageInfo == null || pageInfo.isEmpty) return;

        if (pageInfo.containsKey("name") &&
            pageInfo.containsKey("params") &&
            pageInfo.containsKey("uniqueId")) {
          ContainerCoordinator.singleton.nativeContainerDidShow(
              pageInfo["name"], pageInfo["params"], pageInfo["uniqueId"]);
        }
      });
    });
  }

  static TransitionBuilder init({TransitionBuilder builder,
    PrePushRoute prePush,
    PostPushRoute postPush}) {
    if (Platform.isAndroid) {
      onPageStart();
    } else if (Platform.isIOS) {
      assert(() {
            () async {
          onPageStart();
        }();
        return true;
      }());
    }

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

  BoostChannel get channel => _boostChannel;

  FlutterBoost() {
    ContainerCoordinator(_boostChannel);
  }

  ///Register a default page builder.
  void registerDefaultPageBuilder(PageBuilder builder) {
    ContainerCoordinator.singleton.registerDefaultPageBuilder(builder);
  }

  ///Register a map builders
  void registerPageBuilders(Map<String, PageBuilder> builders) {
    ContainerCoordinator.singleton.registerPageBuilders(builders);
  }

  ///Register a route settings builder
  void registerRouteSettingsBuilder(BoostRouteSettingsBuilder builder) {
    ContainerCoordinator.singleton.registerRouteSettingsBuilder(builder);
  }

  Future<Map<dynamic, dynamic>> open(String url,
      {Map<String, dynamic> urlParams,
        Map<String, dynamic> exts}) {
    Map<String, dynamic> properties = new Map<String, dynamic>();
    properties["url"] = url;
    properties["urlParams"] = urlParams;
    properties["exts"] = exts;
    return channel.invokeMethod<Map<dynamic, dynamic>>('openPage', properties);
  }


  /**
   *
   * when flutter page->flutter page,do not open the new Activity Container
   *
   **/
  Future<Map<dynamic, dynamic>> openInCurrentContainer(String url,
      {Map<String, dynamic> urlParams,
        Map<String, dynamic> exts,
        FlutterBoostRouteBuilder routeBuilder}) {


    final BoostRouteSettings routeSettings = ContainerCoordinator.singleton.createRouteSettings(url,urlParams: urlParams,exts: exts);

    final Widget page = ContainerCoordinator.singleton.createPage(
        routeSettings.name, routeSettings.params, routeSettings.uniqueId);

    if (page == null ) {
      return open(url, urlParams: urlParams, exts: exts);
    }

    final Route<Map<dynamic, dynamic>> route = routeBuilder != null
        ? routeBuilder(page)
        : defaultRoute(page);

    FlutterBoost.containerManager?.onstageContainer?.multipleRouteMode = true;

    return FlutterBoost.containerManager?.onstageContainer?.push(route);

  }

  Route<Map<dynamic, dynamic>> defaultRoute(Widget page) {
    if (Platform.isIOS) {
      return CupertinoPageRoute<Map<dynamic, dynamic>> (
        builder: (BuildContext context) => page
      );
    }

    return MaterialPageRoute<Map<dynamic, dynamic>>(builder: (BuildContext context) => page);

//    PageRouteBuilder<Map<dynamic, dynamic>>(
//        pageBuilder: (BuildContext context,
//            Animation<double> animation,
//            Animation<double> secondaryAnimation,) =>
//        page)
  }

  /**
   * close flutter page but not close container if there has more than one page in contaienr
   */
  bool closeInCurrentContainer<T extends Object>([T result]) {
    return FlutterBoost.containerManager?.onstageContainer?.pop(result);
  }

  Future<bool> close(String id,
      {Map<String, dynamic> result, Map<String, dynamic> exts}) {

    //判断当前onStage的容器是不是通过openInCurrentContainer打开过界面
    if (FlutterBoost.containerManager?.onstageContainer?.multipleRouteMode ?? false) {
      return Future.value(closeInCurrentContainer(result));
    }

    return closeInternal(id, result: result, exts: exts);
  }

  Future<bool> closeInternal(String id,
      {Map<String, dynamic> result, Map<String, dynamic> exts}) {
    assert(id != null);

    BoostContainerSettings settings = containerManager?.onstageSettings;
    Map<String, dynamic> properties = new Map<String, dynamic>();

    if (exts == null) {
      exts = Map<String, dynamic>();
    }

    exts["params"] = settings.params;

    if (!exts.containsKey("animated")) {
      exts["animated"] = true;
    }

    properties["uniqueId"] = id;

    if (result != null) {
      properties["result"] = result;
    }

    if (exts != null) {
      properties["exts"] = exts;
    }
    return channel.invokeMethod<bool>('closePage', properties);

  }



  Future<bool> closeCurrent(
      {Map<String, dynamic> result, Map<String, dynamic> exts}) {
    BoostContainerSettings settings = containerManager?.onstageSettings;
    if (exts == null) {
      exts = Map<String, dynamic>();
    }
    exts["params"] = settings.params;
    if (!exts.containsKey("animated")) {
      exts["animated"] = true;
    }
    return close(settings.uniqueId, result: result, exts: exts);
  }

  Future<bool> closeByContext(BuildContext context,
      {Map<String, dynamic> result, Map<String, dynamic> exts}) {
    BoostContainerSettings settings = containerManager?.onstageSettings;
    if (exts == null) {
      exts = Map<String, dynamic>();
    }
    exts["params"] = settings.params;
    if (!exts.containsKey("animated")) {
      exts["animated"] = true;
    }
    return close(settings.uniqueId, result: result, exts: exts);
  }

  ///register for Container changed callbacks
  VoidCallback addContainerObserver(BoostContainerObserver observer) =>
      _observersHolder.addObserver<BoostContainerObserver>(observer);

  ///register for Container lifecycle callbacks
  VoidCallback addBoostContainerLifeCycleObserver(
      BoostContainerLifeCycleObserver observer) =>
      _observersHolder.addObserver<BoostContainerLifeCycleObserver>(observer);

  ///register callbacks for Navigators push & pop
  void addBoostNavigatorObserver(NavigatorObserver observer) =>
      ContainerNavigatorObserver.boostObservers.add(observer);
}
