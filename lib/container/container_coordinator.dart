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

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../channel/boost_channel.dart';
import '../flutter_boost.dart';
import '../support/logger.dart';
import 'boost_container.dart';

class ContainerCoordinator {
  ContainerCoordinator(BoostChannel channel) : assert(_instance == null) {
    _instance = this;

    channel
      ..addEventListener(
        'lifecycle',
        (String name, Map<String, dynamic> arguments) =>
            _onChannelEvent(arguments),
      )
      ..addMethodHandler((MethodCall call) => _onMethodCall(call));
  }

  static ContainerCoordinator get singleton => _instance;

  static ContainerCoordinator _instance;

  final Map<String, PageBuilder> _pageBuilders = <String, PageBuilder>{};
  PageBuilder _defaultPageBuilder;

  BoostContainerSettings _createContainerSettings(
    String name,
    Map<String, dynamic> params,
    String pageId,
  ) {
    Widget page;

    final BoostContainerSettings routeSettings = BoostContainerSettings(
        uniqueId: pageId,
        name: name,
        params: params,
        builder: (BuildContext ctx) {
          // Try to build a page using keyed builder.
          if (_pageBuilders[name] != null) {
            page = _pageBuilders[name](name, params, pageId);
          }

          // Build a page using default builder.
          if (page == null && _defaultPageBuilder != null) {
            page = _defaultPageBuilder(name, params, pageId);
          }

          assert(page != null);
          Logger.log('build widget:$page for page:$name($pageId)');

          return page;
        });

    return routeSettings;
  }

  /// Register a default page builder.
  void registerDefaultPageBuilder(PageBuilder builder) {
    _defaultPageBuilder = builder;
  }

  /// Register page builder for a key.
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

  Future<dynamic> _onChannelEvent(dynamic event) {
    if (event is Map<String, dynamic>) {
      final Map<String, dynamic> map = event;
      final String type = map['type'] as String;

      Logger.log('onEvent $type');

      switch (type) {
        // Handler back key pressed event.
        case 'backPressedCallback':
          final String id = map['uniqueId'] as String;
          FlutterBoost.containerManager
              ?.containerStateOf(id)
              ?.performBackPressed();
          break;
        // Enter foreground
        case 'foreground':
          FlutterBoost.containerManager?.setForeground();
          break;
        // Enter background
        case 'background':
          FlutterBoost.containerManager?.setBackground();
          break;
        // Schedule a frame.
        case 'scheduleFrame':
          WidgetsBinding.instance.scheduleForcedFrame();
          Future<dynamic>.delayed(
            const Duration(milliseconds: 250),
            () => WidgetsBinding.instance.scheduleFrame(),
          );
          break;
      }
    }

    return Future<dynamic>(() {});
  }

  Future<dynamic> _onMethodCall(MethodCall call) {
    Logger.log('onMetohdCall ${call.method}');

    final String pageName = call.arguments['pageName'] as String;
    final Map<String, dynamic> params =
        (call.arguments['params'] as Map<dynamic, dynamic>)
            ?.cast<String, dynamic>();
    final String uniqueId = call.arguments['uniqueId'] as String;

    switch (call.method) {
      case 'didInitPageContainer':
        _nativeContainerDidInit(pageName, params, uniqueId);
        break;
      case 'willShowPageContainer':
        _nativeContainerWillShow(pageName, params, uniqueId);
        break;
      case 'didShowPageContainer':
        nativeContainerDidShow(pageName, params, uniqueId);
        break;
      case 'willDisappearPageContainer':
        _nativeContainerWillDisappear(pageName, params, uniqueId);
        break;
      case 'didDisappearPageContainer':
        _nativeContainerDidDisappear(pageName, params, uniqueId);
        break;
      case 'willDeallocPageContainer':
        _nativeContainerWillDealloc(pageName, params, uniqueId);
        break;
      case 'onNativePageResult':
        break;
    }

    return Future<dynamic>(() {});
  }

  bool _nativeContainerWillShow(
    String name,
    Map<String, dynamic> params,
    String pageId,
  ) {
    if (FlutterBoost.containerManager?.containsContainer(pageId) != true) {
      FlutterBoost.containerManager?.pushContainer(
        _createContainerSettings(name, params, pageId),
      );
    }

    // TODO(unknown): 需要验证android代码是否也可以移到这里
    if (Platform.isIOS) {
      try {
        final SemanticsOwner owner =
            WidgetsBinding.instance.pipelineOwner?.semanticsOwner;
        final SemanticsNode root = owner?.rootSemanticsNode;
        root?.detach();
        root?.attach(owner);
      } catch (e) {
        assert(false, e.toString());
      }
    }
    return true;
  }

  bool nativeContainerDidShow(
    String name,
    Map<String, dynamic> params,
    String pageId,
  ) {
    FlutterBoost.containerManager
        ?.showContainer(_createContainerSettings(name, params, pageId));

    //对无障碍辅助模式的兼容
    try {
      final SemanticsOwner owner =
          WidgetsBinding.instance.pipelineOwner?.semanticsOwner;
      final SemanticsNode root = owner?.rootSemanticsNode;
      root?.detach();
      root?.attach(owner);
    } catch (e) {
      assert(false, e.toString());
    }

    performContainerLifeCycle(
      _createContainerSettings(name, params, pageId),
      ContainerLifeCycle.Appear,
    );

    Logger.log(
      'native containner did show-$name,\n'
      'manager dump:\n'
      '${FlutterBoost.containerManager?.dump()}',
    );

    return true;
  }

  bool _nativeContainerWillDisappear(
    String name,
    Map<String, dynamic> params,
    String pageId,
  ) {
    performContainerLifeCycle(
      _createContainerSettings(name, params, pageId),
      ContainerLifeCycle.WillDisappear,
    );
    return true;
  }

  bool _nativeContainerDidDisappear(
    String name,
    Map<String, dynamic> params,
    String pageId,
  ) {
    performContainerLifeCycle(
      _createContainerSettings(name, params, pageId),
      ContainerLifeCycle.Disappear,
    );

    Logger.log(
      'native containner did disappear-$name,\n'
      'manager dump:\n'
      '${FlutterBoost.containerManager?.dump()}',
    );
    return true;
  }

  bool _nativeContainerDidInit(
    String name,
    Map<String, dynamic> params,
    String pageId,
  ) {
    performContainerLifeCycle(
      _createContainerSettings(name, params, pageId),
      ContainerLifeCycle.Init,
    );

    Logger.log(
      'native containner did init-$name,\n'
      'manager dump:\n'
      '${FlutterBoost.containerManager?.dump()}',
    );
    return true;
  }

  bool _nativeContainerWillDealloc(
      String name, Map<String, dynamic> params, String pageId) {
    try {
      performContainerLifeCycle(
        _createContainerSettings(name, params, pageId),
        ContainerLifeCycle.Destroy,
      );
    } catch (e) {
      Logger.log('nativeContainerWillDealloc error: $e');
    }
    FlutterBoost.containerManager?.remove(pageId);

    Logger.log(
      'native containner dealloc for $name, \n'
      'manager dump:\n'
      '${FlutterBoost.containerManager?.dump()}',
    );

    return true;
  }

  static void performContainerLifeCycle(
    BoostContainerSettings settings,
    ContainerLifeCycle lifeCycle,
  ) {
    final Set<BoostContainerLifeCycleObserver> observers = FlutterBoost
        .singleton.observersHolder
        .observersOf<BoostContainerLifeCycleObserver>();

    for (final BoostContainerLifeCycleObserver observer in observers) {
      observer(lifeCycle, settings);
    }

    Logger.log(
      'BoostContainerLifeCycleObserver'
      'container:${settings.name}'
      'lifeCycle:$lifeCycle',
    );
  }
}
