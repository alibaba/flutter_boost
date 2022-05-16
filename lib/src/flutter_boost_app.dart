import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'boost_channel.dart';
import 'boost_container.dart';
import 'boost_flutter_binding.dart';
import 'boost_flutter_router_api.dart';
import 'boost_interceptor.dart';
import 'boost_lifecycle_binding.dart';
import 'boost_navigator.dart';
import 'boost_operation_queue.dart';
import 'container_overlay.dart';
import 'logger.dart';
import 'messages.dart';

typedef FlutterBoostAppBuilder = Widget Function(Widget home);

class FlutterBoostApp extends StatefulWidget {
  FlutterBoostApp(
    FlutterBoostRouteFactory routeFactory, {
    Key key,
    FlutterBoostAppBuilder appBuilder,
    String initialRoute,

    ///interceptors is to intercept push operation now
    List<BoostInterceptor> interceptors,
  })  : appBuilder = appBuilder ?? _defaultAppBuilder,
        interceptors = interceptors ?? <BoostInterceptor>[],
        initialRoute = initialRoute ?? '/',
        super(key: key) {
    BoostNavigator.instance.routeFactory = routeFactory;
  }

  final FlutterBoostAppBuilder appBuilder;
  final String initialRoute;

  ///A list of [BoostInterceptor],to intercept operations when push
  final List<BoostInterceptor> interceptors;

  /// default builder for app
  static Widget _defaultAppBuilder(Widget home) {
    /// use builder param instead of home,to avoid Navigator.pop
    return MaterialApp(home: home, builder: (_, __) => home);
  }

  @override
  State<StatefulWidget> createState() => FlutterBoostAppState();
}

class FlutterBoostAppState extends State<FlutterBoostApp> {
  static const String _appLifecycleChangedKey = "app_lifecycle_changed_key";

  final Map<String, Completer<Object>> _pendingResult =
      <String, Completer<Object>>{};

  List<BoostContainer> get containers => _containers;
  final List<BoostContainer> _containers = <BoostContainer>[];

  /// All interceptors from widget
  List<BoostInterceptor> get interceptors => widget.interceptors;

  BoostContainer get topContainer =>
      containers.isNotEmpty ? containers.last : null;

  NativeRouterApi get nativeRouterApi => _nativeRouterApi;
  NativeRouterApi _nativeRouterApi;

  BoostFlutterRouterApi get boostFlutterRouterApi => _boostFlutterRouterApi;
  BoostFlutterRouterApi _boostFlutterRouterApi;

  final Set<int> _activePointers = <int>{};

  ///Things about method channel
  final Map<String, List<EventListener>> _listenersTable =
      <String, List<EventListener>>{};

  VoidCallback _lifecycleStateListenerRemover;

  @override
  void initState() {
    assert(
        BoostFlutterBinding.instance != null,
        'BoostFlutterBinding is not initialized，'
        'please refer to "class CustomFlutterBinding" in example project');
    _nativeRouterApi = NativeRouterApi();
    _boostFlutterRouterApi = BoostFlutterRouterApi(this);

    /// create the container matching the initial route
    final BoostContainer initialContainer =
        _createContainer(PageInfo(pageName: widget.initialRoute));
    _containers.add(initialContainer);
    super.initState();

    // Make sure that the widget in the tree that matches [overlayKey]
    // is already mounted, or [refreshOnPush] will fail.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // try to restore routes from host when hot restart.
      assert(() {
        _restoreStackForHotRestart();
        return true;
      }());

      refreshOnPush(initialContainer);
      _boostFlutterRouterApi.isEnvReady = true;
      _addAppLifecycleStateEventListener();
      BoostOperationQueue.instance.runPendingOperations();
    });
  }

  ///Setup the AppLifecycleState change event launched from native
  ///Here,the [AppLifecycleState] is depends on the native container's num
  ///if container num >= 1,the state == [AppLifecycleState.resumed]
  ///else state == [AppLifecycleState.paused]
  void _addAppLifecycleStateEventListener() {
    _lifecycleStateListenerRemover = BoostChannel.instance
        .addEventListener(_appLifecycleChangedKey, (key, arguments) {
      //we just deal two situation,resume and pause
      //and 0 is resumed
      //and 2 is paused

      final int index = arguments["lifecycleState"];

      if (index == AppLifecycleState.resumed.index) {
        BoostFlutterBinding.instance
            .changeAppLifecycleState(AppLifecycleState.resumed);
      } else if (index == AppLifecycleState.paused.index) {
        BoostFlutterBinding.instance
            .changeAppLifecycleState(AppLifecycleState.paused);
      }
      return;
    });
  }

  @override
  void dispose() {
    _lifecycleStateListenerRemover.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.appBuilder(WillPopScope(
        onWillPop: () async {
          final canPop = topContainer.navigator.canPop();
          if (canPop) {
            topContainer.navigator.pop();
            return true;
          }
          return false;
        },
        child: Listener(
            onPointerDown: _handlePointerDown,
            onPointerUp: _handlePointerUpOrCancel,
            onPointerCancel: _handlePointerUpOrCancel,
            child: Overlay(
              key: overlayKey,
              initialEntries: const <OverlayEntry>[],
            ))));
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers.add(event.pointer);
  }

  void _handlePointerUpOrCancel(PointerEvent event) {
    _activePointers.remove(event.pointer);
  }

  void _cancelActivePointers() {
    _activePointers.toList().forEach(WidgetsBinding.instance.cancelPointer);
  }

  String _createUniqueId(String pageName) {
    return '${DateTime.now().millisecondsSinceEpoch}_$pageName';
  }

  BoostContainer _createContainer(PageInfo pageInfo) {
    pageInfo.uniqueId ??= _createUniqueId(pageInfo.pageName);
    return BoostContainer(
        key: ValueKey<String>(pageInfo.uniqueId), pageInfo: pageInfo);
  }

  Future<void> _saveStackForHotRestart() async {
    final stack = StackInfo();
    stack.containers = <String>[];
    for (var container in containers) {
      stack.containers.add(container.pageInfo.uniqueId);
      stack.routes = <String, List<Map<String, Object>>>{};
      final params = <Map<String, Object>>[];
      for (var page in container.pages) {
        final param = <String, Object>{};
        param['pageName'] = page.pageInfo.pageName;
        param['uniqueId'] = page.pageInfo.uniqueId;
        param['arguments'] = page.pageInfo.arguments;
        params.add(param);
      }
      stack.routes[container.pageInfo.uniqueId] = params;
    }
    await nativeRouterApi.saveStackToHost(stack);
    Logger.log(
        '_saveStackForHotRestart, ${stack?.containers}, ${stack?.routes}');
  }

  Future<void> _restoreStackForHotRestart() async {
    final stack = await nativeRouterApi.getStackFromHost();
    if (stack != null && stack.containers != null) {
      for (String uniqueId in stack.containers) {
        var withContainer = true;
        final List<Object> routeList = stack.routes[uniqueId];
        if (routeList != null) {
          for (Map<Object, Object> route in routeList) {
            var pageName = route['pageName'] as String;
            var uniqueId = route['uniqueId'] as String;
            var arguments = Map<String, dynamic>.from(
                route['arguments'] ?? <String, dynamic>{});
            withContainer
                ? pushContainer(pageName,
                    uniqueId: uniqueId, arguments: arguments)
                : pushPage(pageName, uniqueId: uniqueId, arguments: arguments);
            withContainer = false;
          }
        }
      }
    }
    Logger.log(
        '_restoreStackForHotRestart, ${stack?.containers}, ${stack?.routes}');
  }

  Future<T> pushWithInterceptor<T extends Object>(
      String name, bool isFromHost, bool isFlutterPage,
      {Map<String, dynamic> arguments,
      String uniqueId,
      bool withContainer,
      bool opaque = true}) {
    Logger.log('pushWithInterceptor, uniqueId=$uniqueId, name=$name');
    var pushOption = BoostInterceptorOption(name,
        uniqueId: uniqueId,
        isFromHost: isFromHost,
        arguments: arguments ?? <String, dynamic>{});
    var state = InterceptorState<BoostInterceptorOption>(pushOption);
    for (var interceptor in interceptors) {
      final pushHandler = PushInterceptorHandler();
      interceptor.onPrePush(state.data, pushHandler);
      state = pushHandler.state;
      if (state.type != InterceptorResultType.next) {
        Logger.log('The page was intercepted by user. name:$name, '
            'isFromHost=$isFromHost, isFlutterPage=$isFlutterPage');
        return Future<T>.value(state.data as T);
      }
    }

    if (state.data is BoostInterceptorOption) {
      assert(state.type == InterceptorResultType.next);
      pushOption = state.data;
      if (isFromHost) {
        pushContainer(name,
            uniqueId: pushOption.uniqueId,
            isFromHost: isFromHost,
            arguments: pushOption.arguments);
      } else {
        if (isFlutterPage) {
          return pushWithResult(pushOption.name,
              uniqueId: pushOption.uniqueId,
              arguments: pushOption.arguments,
              withContainer: withContainer,
              opaque: opaque);
        } else {
          final params = CommonParams()
            ..pageName = pushOption.name
            ..arguments = pushOption.arguments;
          nativeRouterApi.pushNativeRoute(params);
          return pendNativeResult(pushOption.name);
        }
      }
    } else {
      Logger.log(
          'Oops, Unrecognized parameter type: ${state.data.runtimeType}');
    }
    return Future<void>.value();
  }

  Future<T> pushWithResult<T extends Object>(String pageName,
      {String uniqueId,
      Map<String, dynamic> arguments,
      bool withContainer,
      bool opaque = true}) {
    uniqueId ??= _createUniqueId(pageName);
    if (withContainer) {
      final completer = Completer<T>();
      final params = CommonParams()
        ..pageName = pageName
        ..uniqueId = uniqueId
        ..opaque = opaque
        ..arguments = arguments ?? <String, dynamic>{};
      nativeRouterApi.pushFlutterRoute(params);
      _pendingResult[uniqueId] = completer;
      return completer.future;
    } else {
      return pushPage(pageName, uniqueId: uniqueId, arguments: arguments);
    }
  }

  Future<T> pushPage<T extends Object>(String pageName,
      {String uniqueId, Map<String, dynamic> arguments}) {
    Logger.log('pushPage, uniqueId=$uniqueId, name=$pageName,'
        ' arguments:$arguments, $topContainer');
    final pageInfo = PageInfo(
        pageName: pageName,
        uniqueId: uniqueId ?? _createUniqueId(pageName),
        arguments: arguments,
        withContainer: false);
    assert(topContainer != null);
    var result = topContainer.addPage(BoostPage.create(pageInfo));
    _pushFinish(pageName, uniqueId: uniqueId, arguments: arguments);
    return result;
  }

  void pushContainer(String pageName,
      {String uniqueId,
      bool isFromHost = false,
      Map<String, dynamic> arguments}) {
    _cancelActivePointers();
    final existed = _findContainerByUniqueId(uniqueId);
    if (existed != null) {
      if (topContainer?.pageInfo?.uniqueId != uniqueId) {
        containers.remove(existed);
        containers.add(existed);

        //move the overlayEntry which matches this existing container to the top
        refreshOnMoveToTop(existed);
      }
    } else {
      final pageInfo = PageInfo(
          pageName: pageName,
          uniqueId: uniqueId ?? _createUniqueId(pageName),
          arguments: arguments,
          withContainer: true);
      final container = _createContainer(pageInfo);
      final previousContainer = topContainer;
      containers.add(container);
      BoostLifecycleBinding.instance
          .containerDidPush(container, previousContainer);

      // Add a new overlay entry with this container
      refreshOnPush(container);
    }

    _pushFinish(pageName,
        uniqueId: uniqueId, isFromHost: isFromHost, arguments: arguments);
    Logger.log('pushContainer, uniqueId=$uniqueId, existed=$existed,'
        ' arguments:$arguments, $containers');
  }

  void _pushFinish(String pageName,
      {String uniqueId,
      bool isFromHost = false,
      Map<String, dynamic> arguments}) {
    var pushOption = BoostInterceptorOption(pageName,
        uniqueId: uniqueId,
        isFromHost: isFromHost,
        arguments: arguments ?? <String, dynamic>{});
    var state = InterceptorState<BoostInterceptorOption>(pushOption);
    for (var interceptor in interceptors) {
      final pushHandler = PushInterceptorHandler();
      interceptor.onPostPush(state.data, pushHandler);
      state = pushHandler.state;
      if (state.type != InterceptorResultType.next) {
        break;
      }
    }
  }

  Future<bool> popWithResult<T extends Object>([T result]) async {
    final uniqueId = topContainer?.topPage?.pageInfo?.uniqueId;
    _completePendingResultIfNeeded(uniqueId, result: result);
    return await pop(result: result);
  }

  Future<bool> removeWithResult(
      [String uniqueId, Map<String, dynamic> result]) async {
    _completePendingResultIfNeeded(uniqueId, result: result);
    return await pop(uniqueId: uniqueId, result: result);
  }

  void popUntil({String route, String uniqueId}) async {
    BoostContainer targetContainer;
    BoostPage targetPage;
    int popUntilIndex = containers.length;
    if (uniqueId != null) {
      for (int index = containers.length - 1; index >= 0; index--) {
        for (BoostPage page in containers[index].pages) {
          if (uniqueId == page.pageInfo.uniqueId ||
              uniqueId == containers[index].pageInfo.uniqueId) {
            //uniqueId优先级更高，优先匹配
            targetContainer = containers[index];
            targetPage = page;
            break;
          }
        }
        if (targetContainer != null) {
          popUntilIndex = index;
          break;
        }
      }
    }

    if (targetContainer == null && route != null) {
      for (int index = containers.length - 1; index >= 0; index--) {
        for (BoostPage page in containers[index].pages) {
          if (route == page.name) {
            targetContainer = containers[index];
            targetPage = page;
            break;
          }
        }
        if (targetContainer != null) {
          popUntilIndex = index;
          break;
        }
      }
    }

    if (targetContainer != null && targetContainer != topContainer) {
      /// containers item index would change when call 'nativeRouterApi.popRoute' method with sync.
      /// clone containers keep original item index.
      List<BoostContainer> _containersTemp = [...containers];
      for (int index = _containersTemp.length - 1;
          index > popUntilIndex;
          index--) {
        BoostContainer container = _containersTemp[index];
        final params = CommonParams()
          ..pageName = container.pageInfo.pageName
          ..uniqueId = container.pageInfo.uniqueId
          ..arguments = {"animated": false};
        await nativeRouterApi.popRoute(params);
      }

      if (targetContainer.topPage != targetPage) {
        Future<void>.delayed(
            const Duration(milliseconds: 50),
            () => targetContainer?.navigator
                ?.popUntil(ModalRoute.withName(targetPage.name)));
      }
    } else {
      topContainer?.navigator?.popUntil(ModalRoute.withName(targetPage.name));
    }
  }

  Future<bool> pop(
      {String uniqueId, Object result, bool onBackPressed = false}) async {
    BoostContainer container;
    if (uniqueId != null) {
      container = _findContainerByUniqueId(uniqueId);
      if (container == null) {
        Logger.error('uniqueId=$uniqueId not found');
        return false;
      }
      if (container != topContainer) {
        await _removeContainer(container);
        return true;
      }
    } else {
      container = topContainer;
    }

    final currentPage = topContainer?.topPage?.pageInfo?.uniqueId;
    assert(currentPage != null);
    _completePendingResultIfNeeded(currentPage);

    // 1.If uniqueId == null,indicate we simply call BoostNavigaotor.pop(),
    // so we call navigator?.maybePop();
    // 2.If uniqueId is topPage's uniqueId, so we navigator?.maybePop();
    // 3.If uniqueId is not topPage's uniqueId, so we will remove an existing
    // page in container.
    if (uniqueId == null ||
        uniqueId == container.pages.last.pageInfo.uniqueId) {
      final handled = onBackPressed
          ? await _performBackPressed(container, result)
          : container?.navigator?.canPop();
      if (handled != null) {
        if (!handled) {
          assert(container.pageInfo.withContainer);
          final params = CommonParams()
            ..pageName = container.pageInfo.pageName
            ..uniqueId = container.pageInfo.uniqueId
            ..arguments =
                (result is Map<String, dynamic>) ? result : <String, dynamic>{};
          await nativeRouterApi.popRoute(params);
        } else {
          if (!onBackPressed) {
            container.navigator.pop(result);
          }
        }
      }
    } else {
      final page = container.pages.singleWhere(
          (entry) => entry.pageInfo.uniqueId == uniqueId,
          orElse: () => null);
      container.removePage(page);
    }

    Logger.log('pop container, uniqueId=$uniqueId, result:$result, $container');
    return true;
  }

  Future<bool> _performBackPressed(
      BoostContainer container, Object result) async {
    if (container?.backPressedHandler != null) {
      container.backPressedHandler.call();
      return true;
    } else {
      return await container?.navigator?.maybePop(result);
    }
  }

  Future<void> _removeContainer(BoostContainer container) async {
    if (container.pageInfo.withContainer) {
      Logger.log('_removeContainer ,  uniqueId=${container.pageInfo.uniqueId}');
      final params = CommonParams()
        ..pageName = container.pageInfo.pageName
        ..uniqueId = container.pageInfo.uniqueId
        ..arguments = container.pageInfo.arguments;
      return await _nativeRouterApi.popRoute(params);
    }
  }

  void onForeground() {
    if (topContainer != null) {
      BoostLifecycleBinding.instance.appDidEnterForeground(topContainer);
    }
  }

  void onBackground() {
    if (topContainer != null) {
      BoostLifecycleBinding.instance.appDidEnterBackground(topContainer);
    }
  }

  BoostContainer _findContainerByUniqueId(String uniqueId) {
    //Because first page can be removed from container.
    //So we find id in container's PageInfo
    //If we can't find a container matching this id,
    //we will traverse all pages in all containers
    //to find the page matching this id,and return its container
    //
    //If we can't find any container or page matching this id,we return null

    var result = containers.singleWhere(
        (element) => element.pageInfo.uniqueId == uniqueId,
        orElse: () => null);

    if (result != null) {
      return result;
    }

    return containers.singleWhere(
        (element) => element.pages
            .any((element) => element.pageInfo.uniqueId == uniqueId),
        orElse: () => null);
  }

  void remove(String uniqueId) {
    if (uniqueId == null) {
      return;
    }

    final container = _findContainerByUniqueId(uniqueId);
    if (container != null) {
      containers.remove(container);
      BoostLifecycleBinding.instance.containerDidPop(container, topContainer);

      //remove the overlayEntry matching this container
      refreshOnRemove(container);
    } else {
      for (var container in containers) {
        final page = container.pages.singleWhere(
            (entry) => entry.pageInfo.uniqueId == uniqueId,
            orElse: () => null);
        container.removePage(page);
      }
    }
    Logger.log('remove,  uniqueId=$uniqueId, $containers');
  }

  Future<T> pendNativeResult<T extends Object>(String pageName) {
    final completer = Completer<T>();
    final initiatorPage = topContainer?.topPage?.pageInfo?.uniqueId;
    final key = '$initiatorPage#$pageName';
    _pendingResult[key] = completer;
    Logger.log('pendNativeResult, key:$key, size:${_pendingResult.length}');
    return completer.future;
  }

  void onNativeResult(CommonParams params) {
    final initiatorPage = topContainer?.topPage?.pageInfo?.uniqueId;
    final key = '$initiatorPage#${params.pageName}';
    if (_pendingResult.containsKey(key)) {
      _pendingResult[key].complete(params.arguments);
      _pendingResult.remove(key);
    }
    Logger.log('onNativeResult, key:$key, result:${params.arguments}');
  }

  void _completePendingResultIfNeeded<T extends Object>(String uniqueId,
      {T result}) {
    if (uniqueId != null && _pendingResult.containsKey(uniqueId)) {
      _pendingResult[uniqueId].complete(result);
      _pendingResult.remove(uniqueId);
    }
  }

  void onContainerShow(CommonParams params) {
    final container = _findContainerByUniqueId(params.uniqueId);
    BoostLifecycleBinding.instance.containerDidShow(container);
  }

  void onContainerHide(CommonParams params) {
    final container = _findContainerByUniqueId(params.uniqueId);
    BoostLifecycleBinding.instance.containerDidHide(container);
  }

  ///
  ///Methods below are about Custom events with native side
  ///

  ///Calls when Native send event to flutter(here)
  void onReceiveEventFromNative(CommonParams params) {
    //Get the name and args from native
    var key = params.key;
    Map args = params.arguments;
    assert(key != null);

    //Get all of listeners matching this key
    final listeners = _listenersTable[key];

    if (listeners == null) return;

    for (final listener in listeners) {
      listener(key, args);
    }
  }

  ///Add event listener in flutter side with a [key] and [listener]
  VoidCallback addEventListener(String key, EventListener listener) {
    assert(key != null && listener != null);

    var listeners = _listenersTable[key];
    if (listeners == null) {
      listeners = [];
      _listenersTable[key] = listeners;
    }

    listeners.add(listener);

    return () {
      listeners.remove(listener);
    };
  }

  ///Interal methods below

  PageInfo getTopPageInfo() {
    return topContainer?.topPage?.pageInfo;
  }

  int pageSize() {
    var count = 0;
    for (var container in containers) {
      count += container.numPages();
    }
    return count;
  }

  ///
  ///======== refresh method below ===============
  ///

  void refreshOnPush(BoostContainer container) {
    ContainerOverlay.instance.refreshSpecificOverlayEntries(
        container, BoostSpecificEntryRefreshMode.add);
    assert(() {
      _saveStackForHotRestart();
      return true;
    }());
  }

  void refreshOnRemove(BoostContainer container) {
    ContainerOverlay.instance.refreshSpecificOverlayEntries(
        container, BoostSpecificEntryRefreshMode.remove);
    assert(() {
      _saveStackForHotRestart();
      return true;
    }());
  }

  void refreshOnMoveToTop(BoostContainer container) {
    ContainerOverlay.instance.refreshSpecificOverlayEntries(
        container, BoostSpecificEntryRefreshMode.moveToTop);
    assert(() {
      _saveStackForHotRestart();
      return true;
    }());
  }
}

// ignore: must_be_immutable
class BoostPage<T> extends Page<T> {
  BoostPage({LocalKey key, this.pageInfo})
      : super(key: key, name: pageInfo.pageName, arguments: pageInfo.arguments);
  final PageInfo pageInfo;

  static BoostPage<dynamic> create(PageInfo pageInfo) {
    final page = BoostPage<dynamic>(key: UniqueKey(), pageInfo: pageInfo);
    page._route = BoostNavigator.instance.routeFactory(page, pageInfo.uniqueId);
    return page;
  }

  Route<T> _route;

  Route<T> get route => _route;

  /// A future that completes when this page is popped.
  Future<T> get popped => _popCompleter.future;
  final Completer<T> _popCompleter = Completer<T>();

  void didComplete(T result) {
    if (!_popCompleter.isCompleted) {
      _popCompleter.complete(result);
    }
  }

  @override
  String toString() => '${objectRuntimeType(this, 'BoostPage')}(name:$name,'
      ' uniqueId:${pageInfo.uniqueId}, arguments:$arguments)';

  @override
  Route<T> createRoute(BuildContext context) {
    return _route;
  }
}

class BoostNavigatorObserver extends NavigatorObserver {
  BoostNavigatorObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    //handle internal route but ignore dialog or abnormal route.
    //otherwise, the normal page will be affected.
    if (previousRoute != null && route?.settings?.name != null) {
      BoostLifecycleBinding.instance.routeDidPush(route, previousRoute);
    }

    final navigatorObserverList =
        BoostLifecycleBinding.instance.navigatorObserverList;
    if (navigatorObserverList != null && navigatorObserverList.isNotEmpty) {
      for (var observer in navigatorObserverList) {
        observer.didPush(route, previousRoute);
      }
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute != null && route?.settings?.name != null) {
      BoostLifecycleBinding.instance.routeDidPop(route, previousRoute);
    }

    final navigatorObserverList =
        BoostLifecycleBinding.instance.navigatorObserverList;
    if (navigatorObserverList != null && navigatorObserverList.isNotEmpty) {
      for (var observer in navigatorObserverList) {
        observer.didPop(route, previousRoute);
      }
    }

    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    final navigatorObserverList =
        BoostLifecycleBinding.instance.navigatorObserverList;
    if (navigatorObserverList != null && navigatorObserverList.isNotEmpty) {
      for (var observer in navigatorObserverList) {
        observer.didRemove(route, previousRoute);
      }
    }
    super.didRemove(route, previousRoute);
    if (route != null) {
      BoostLifecycleBinding.instance.routeDidRemove(route);
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    final navigatorObserverList =
        BoostLifecycleBinding.instance.navigatorObserverList;
    if (navigatorObserverList != null && navigatorObserverList.isNotEmpty) {
      for (var observer in navigatorObserverList) {
        observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
      }
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
    final navigatorObserverList =
        BoostLifecycleBinding.instance.navigatorObserverList;
    if (navigatorObserverList != null && navigatorObserverList.isNotEmpty) {
      for (var observer in navigatorObserverList) {
        observer.didStartUserGesture(route, previousRoute);
      }
    }
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    final navigatorObserverList =
        BoostLifecycleBinding.instance.navigatorObserverList;
    if (navigatorObserverList != null && navigatorObserverList.isNotEmpty) {
      for (var observer in navigatorObserverList) {
        observer.didStopUserGesture();
      }
    }
    super.didStopUserGesture();
  }
}
