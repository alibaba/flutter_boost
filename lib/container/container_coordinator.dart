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
import 'package:flutter_boost/AIOService/NavigationService/service/NavigationService.dart';
import 'package:flutter_boost/container/boost_container.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost/messaging/native_page_container_event_handler.dart';
import 'package:flutter_boost/support/logger.dart';

class ContainerCoordinator implements NativePageContainerEventHandler {
  static final ContainerCoordinator singleton = ContainerCoordinator();

  final Map<String, PageBuilder> _pageBuilders = <String, PageBuilder>{};
  PageBuilder _defaultPageBuilder;

  ContainerCoordinator() {
    NavigationService.listenEvent(onChannelEvent);
  }

  BoostContainerSettings _createContainerSettings(
      String name, Map params, String pageId) {
    Widget page;

    final BoostContainerSettings routeSettings = BoostContainerSettings(
        uniqueId: pageId,
        name: name,
        params: params,
        builder: (BuildContext ctx) {
          //Try to build a page using keyed builder.
          if (_pageBuilders[name] != null) {
            page = _pageBuilders[name](name, params, pageId);
          }

          //Build a page using default builder.
          if (page == null && _defaultPageBuilder != null) {
            page = _defaultPageBuilder(name, params, pageId);
          }

          assert(page != null);
          Logger.log('build widget:$page for page:$name($pageId)');

          return page;
        });

    return routeSettings;
  }

  //Register a default page builder.
  void registerDefaultPageBuilder(PageBuilder builder) {
    _defaultPageBuilder = builder;
  }

  //Register page builder for a key.
  void registerPageBuilder(String pageName, PageBuilder builder) {
    if (pageName != null && builder != null) {
      _pageBuilders[pageName] = builder;
    }
  }

  void registerPageBuilders(Map<String, PageBuilder> builders) {
    if (builders?.isNotEmpty == true) {
      _pageBuilders.addAll(builders);
    }
  }

  void onChannelEvent(dynamic event) {
    if (event is Map) {
      Map map = event as Map;
      final String type = map['type'];

      switch (type) {
        //Handler back key pressed event.
        case 'backPressedCallback':
          {
            final String id = map['uniqueId'];
            FlutterBoost.containerManager
                ?.containerStateOf(id)
                ?.performBackPressed();
          }
          break;
        //Enter foregroud
        case 'foreground':
          {
            FlutterBoost.containerManager?.setForeground();
          }
          break;
        //Enter background
        case 'background':
          {
            FlutterBoost.containerManager?.setBackground();
          }
          break;
        //Schedule a frame.
        case 'scheduleFrame':
          {
            WidgetsBinding.instance.scheduleForcedFrame();
            Future<dynamic>.delayed(Duration(milliseconds: 250),
                () => WidgetsBinding.instance.scheduleFrame());
          }
          break;
      }
    }
  }

  //Messaging
  @override
  bool nativeContainerWillShow(String name, Map params, String pageId) {
    if (FlutterBoost.containerManager?.containsContainer(pageId) != true) {
      FlutterBoost.containerManager
          ?.pushContainer(_createContainerSettings(name, params, pageId));
    }

    return true;
  }

  @override
  bool nativeContainerDidShow(String name, Map params, String pageId) {
    FlutterBoost.containerManager
        ?.showContainer(_createContainerSettings(name, params, pageId));

    performContainerLifeCycle(_createContainerSettings(name, params, pageId),
        ContainerLifeCycle.Appear);

    Logger.log(
        'native containner did show,\nmanager dump:\n${FlutterBoost.containerManager?.dump()}');

    return true;
  }

  @override
  bool nativeContainerWillDisappear(String name, Map params, String pageId) {
    return true;
  }

  @override
  bool nativeContainerDidDisappear(String name, Map params, String pageId) {
    performContainerLifeCycle(_createContainerSettings(name, params, pageId),
        ContainerLifeCycle.Disappear);
    return true;
  }

  @override
  bool nativeContainerDidInit(String name, Map params, String pageId) {
    performContainerLifeCycle(_createContainerSettings(name, params, pageId),
        ContainerLifeCycle.Init);
    return true;
  }

  @override
  bool nativeContainerWillDealloc(String name, Map params, String pageId) {
    performContainerLifeCycle(_createContainerSettings(name, params, pageId),
        ContainerLifeCycle.Destroy);

    FlutterBoost.containerManager?.remove(pageId);

    Logger.log(
        'native containner dealloc, \nmanager dump:\n${FlutterBoost.containerManager?.dump()}');

    return true;
  }

  static void performContainerLifeCycle(
      BoostContainerSettings settings, ContainerLifeCycle lifeCycle) {
    for (BoostContainerLifeCycleObserver observer in FlutterBoost
        .singleton.observersHolder
        .observersOf<BoostContainerLifeCycleObserver>()) {
      observer(lifeCycle, settings);
    }

    Logger.log(
        'BoostContainerLifeCycleObserver container:${settings.name} lifeCycle:$lifeCycle');
  }
}
