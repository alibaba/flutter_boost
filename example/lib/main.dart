import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

import 'case/asset_image_route.dart';
import 'case/bottom_navigation_bar_demo.dart';
import 'case/counter_demo.dart';
import 'case/dual_screen.dart';
import 'case/flutter_rebuild_demo.dart';
import 'case/flutter_to_flutter_sample.dart';
import 'case/hero_animation.dart';
import 'case/image_cache_route.dart';
import 'case/image_pick.dart';
import 'case/media_query.dart';
import 'case/native_view_demo.dart';
import 'case/platform_view_perf.dart';
import 'case/popUntil.dart';
import 'case/pushreplace.dart';
import 'case/radial_hero_animation.dart';
import 'case/return_data.dart';
import 'case/rotation_transition.dart';
import 'case/selection_screen.dart';
import 'case/show_dialog_demo.dart';
import 'case/simple_webview_demo.dart';
import 'case/state_restoration.dart';
import 'case/system_ui_overlay_style.dart';
import 'case/transparent_widget.dart';
import 'case/webview_flutter_demo.dart';
import 'case/willpop.dart';
import 'flutter_page.dart';
import 'simple_page_widgets.dart';
import 'tab/simple_widget.dart';

void main(List<String> args) {
  PageVisibilityBinding.instance
      .addGlobalObserver(AppGlobalPageVisibilityObserver());
  CustomFlutterBinding();
  runApp(MyApp());
  print('dartEntrypointArgs: $args');
}

class AppGlobalPageVisibilityObserver extends GlobalPageVisibilityObserver {
  @override
  void onPagePush(Route<dynamic> route) {
    Logger.log(
        'boost_lifecycle: AppGlobalPageVisibilityObserver.onPageCreate route:${route.settings.name}');
  }

  @override
  void onPageShow(Route<dynamic> route) {
    Logger.log(
        'boost_lifecycle: AppGlobalPageVisibilityObserver.onPageShow route:${route.settings.name}');
  }

  @override
  void onPageHide(Route<dynamic> route) {
    Logger.log(
        'boost_lifecycle: AppGlobalPageVisibilityObserver.onPageHide route:${route.settings.name}');
  }

  @override
  void onPagePop(Route<dynamic> route) {
    Logger.log(
        'boost_lifecycle: AppGlobalPageVisibilityObserver.onPageDestroy route:${route.settings.name}');
  }

  @override
  void onForeground(Route route) {
    Logger.log(
        'boost_lifecycle: AppGlobalPageVisibilityObserver.onForeground route:${route.settings.name}');
  }

  @override
  void onBackground(Route<dynamic> route) {
    Logger.log(
        'boost_lifecycle: AppGlobalPageVisibilityObserver.onBackground route:${route.settings.name}');
  }
}

class CustomFlutterBinding extends WidgetsFlutterBinding
    with BoostFlutterBinding {}

class CustomInterceptor1 extends BoostInterceptor {
  @override
  void onPrePush(
      BoostInterceptorOption option, PushInterceptorHandler handler) {
    Logger.log('CustomInterceptor#onPrePush1~~~, $option');
    // Add extra arguments
    option.arguments!['CustomInterceptor1'] = "1";
    super.onPrePush(option, handler);
  }

  @override
  void onPostPush(
      BoostInterceptorOption option, PushInterceptorHandler handler) {
    Logger.log('CustomInterceptor#onPostPush1~~~, $option');
    handler.next(option);
  }
}

class CustomInterceptor2 extends BoostInterceptor {
  @override
  void onPrePush(
      BoostInterceptorOption option, PushInterceptorHandler handler) {
    Logger.log('CustomInterceptor#onPrePush2~~~, $option');
    // Add extra arguments
    option.arguments!['CustomInterceptor2'] = "2";
    if (!option.isFromHost! && option.name == "interceptor") {
      handler.resolve(<String, dynamic>{'result': 'xxxx'});
    } else {
      handler.next(option);
    }
  }

  @override
  void onPostPush(
      BoostInterceptorOption option, PushInterceptorHandler handler) {
    Logger.log('CustomInterceptor#onPostPush2~~~, $option');
    handler.next(option);
  }
}

class CustomInterceptor3 extends BoostInterceptor {
  @override
  void onPrePush(
      BoostInterceptorOption option, PushInterceptorHandler handler) {
    Logger.log('CustomInterceptor#onPrePush3~~~, $option');
    // Replace arguments
    // option.arguments = <String, dynamic>{'CustomInterceptor3': '3'};
    handler.next(option);
  }

  @override
  void onPostPush(
      BoostInterceptorOption option, PushInterceptorHandler handler) {
    Logger.log('CustomInterceptor#onPostPush3~~~, $option');
    handler.next(option);
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static Map<String, FlutterBoostRouteFactory> routerMap = {
    // '/': (settings, uniqueId) {
    //   return PageRouteBuilder<dynamic>(
    //       settings: settings, pageBuilder: (_, __, ___) => Container());
    // },
    'embedded': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => EmbeddedFirstRouteWidget());
    },
    'presentFlutterPage': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => FlutterIndexRoute(
                params: settings.arguments as Map<dynamic, dynamic>?,
                uniqueId: uniqueId,
              ));
    },
    'imagepick': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => const ImagePickerPage(title: "xxx"));
    },
    'imageCache': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) =>
              const ImageCacheRoute(title: "ImageCache Example"));
    },
    'assetImageRoute': (settings, uniqueId) {
      Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
      bool? precache = args?['precache'];
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) =>
              AssetImageRoute(precache: precache ?? false));
    },
    'interceptor': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) =>
              const ImagePickerPage(title: "interceptor"));
    },
    'firstFirst': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => FirstFirstRouteWidget());
    },
    'willPop': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
        settings: settings,
        pageBuilder: (_, __, ___) => const WillPopRoute(),
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0),
              end: Offset.zero,
            ).animate(animation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-1.0, 0),
              ).animate(secondaryAnimation),
              child: child,
            ),
          );
        },
      );
    },
    'counter': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) =>
              const CounterPage(title: "Counter Demo"));
    },
    'dualScreen': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => const DualScreen());
    },
    'hero_animation': (settings, uniqueId) {
      return MaterialPageRoute(
          settings: settings, builder: (_) => const HeroAnimation());
    },
    'returnData': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => ReturnDataWidget());
    },
    'transparentWidget': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          barrierColor: Colors.black12,
          transitionDuration: const Duration(),
          reverseTransitionDuration: const Duration(),
          opaque: false,
          settings: settings,
          pageBuilder: (_, __, ___) => TransparentWidget());
    },
    'radialExpansion': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => RadialExpansionDemo());
    },
    'selectionScreen': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => SelectionScreen());
    },
    'secondStateful': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SecondStatefulRouteWidget());
    },
    'platformView': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => PlatformRouteWidget());
    },
    'popUntilView': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => PopUntilRoute());
    },

    ///可以在native层通过 getContainerParams 来传递参数
    'flutterPage': (settings, uniqueId) {
      debugPrint('flutterPage settings:$settings, uniqueId:$uniqueId');
      return PageRouteBuilder<dynamic>(
        settings: settings,
        pageBuilder: (_, __, ___) => FlutterIndexRoute(
          params: settings.arguments as Map<dynamic, dynamic>?,
          uniqueId: uniqueId,
        ),
        // transitionsBuilder: (BuildContext context, Animation<double> animation,
        //     Animation<double> secondaryAnimation, Widget child) {
        //   return SlideTransition(
        //     position: Tween<Offset>(
        //       begin: const Offset(1.0, 0),
        //       end: Offset.zero,
        //     ).animate(animation),
        //     child: SlideTransition(
        //       position: Tween<Offset>(
        //         begin: Offset.zero,
        //         end: const Offset(-1.0, 0),
        //       ).animate(secondaryAnimation),
        //       child: child,
        //     ),
        //   );
        // },
      );
    },
    'showDialog': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => ShowDialogDemo());
    },
    'tab_friend': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SimpleWidget(
              uniqueId,
              settings.arguments as Map<dynamic, dynamic>?,
              "This is a flutter fragment"));
    },
    'tab_message': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SimpleWidget(
              uniqueId,
              settings.arguments as Map<dynamic, dynamic>?,
              "This is a flutter fragment"));
    },
    'tab_flutter1': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SimpleWidget(
              uniqueId,
              settings.arguments as Map<dynamic, dynamic>?,
              "This is a custom FlutterView"));
    },
    'tab_flutter2': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SimpleWidget(
              uniqueId,
              settings.arguments as Map<dynamic, dynamic>?,
              "This is a custom FlutterView"));
    },

    'f2f_first': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => F2FFirstPage());
    },
    'f2f_second': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => F2FSecondPage());
    },
    'webview': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => WebViewExample());
    },
    'platformview/listview': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => PlatformViewPerf());
    },
    'platformview/animation': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => NativeViewExample());
    },
    'platformview/simplewebview': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => SimpleWebView());
    },
    'state_restoration': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => StateRestorationDemo());
    },
    'rotation_transition': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => RotationTranDemo());
    },
    'bottom_navigation': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => const BottomNavigationPage());
    },
    'system_ui_overlay_style': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) {
            bool? isDark;
            if (settings.arguments is Map<String, dynamic>?) {
              isDark = (settings.arguments as Map<String, dynamic>)['isDark'];
            }
            return SystemUiOverlayStyleDemo(isDark: isDark);
          });
    },
    'mediaquery': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => MediaQueryRouteWidget(
                params: settings.arguments as Map<dynamic, dynamic>?,
                uniqueId: uniqueId,
              ));
    },

    ///使用 BoostCacheWidget包裹你的页面时，可以解决push pageA->pageB->pageC 过程中，pageA，pageB 会多次 rebuild 的问题
    'flutterRebuildDemo': (settings, uniqueId) {
      return MaterialPageRoute(
          settings: settings,
          builder: (ctx) {
            return BoostCacheWidget(
              uniqueId: uniqueId!,
              builder: (_) => const FlutterRebuildDemo(),
            );
          });
    },
    'flutterRebuildPageA': (settings, uniqueId) {
      return MaterialPageRoute(
          settings: settings,
          builder: (ctx) {
            return BoostCacheWidget(
              uniqueId: uniqueId!,
              builder: (_) => const FlutterRebuildPageA(),
            );
          });
    },
    'flutterRebuildPageB': (settings, uniqueId) {
      return MaterialPageRoute(
          settings: settings,
          builder: (ctx) {
            return BoostCacheWidget(
              uniqueId: uniqueId!,
              builder: (_) => const FlutterRebuildPageB(),
            );
          });
    },
    'pushReplacement': (settings, uniqueId) {
      return MaterialPageRoute(
          settings: settings,
          builder: (ctx) {
            var m = settings.arguments as Map<dynamic, dynamic>?;
            return PushReplacementWidget(index: m!['index'] ?? 1,);
          });
    },
  };

  Route<dynamic>? routeFactory(RouteSettings settings, String? uniqueId) {
    FlutterBoostRouteFactory? func = routerMap[settings.name!];
    if (func == null) {
      return null;
    }
    return func(settings, uniqueId);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(routeFactory,
        // 如果自定了appBuilder，需要将传入的参数添加到widget层次结构中去，
        // 否则会导致FluttBoost初始化失败。
        appBuilder: (child) => MaterialApp(
              home: child,
            ),
        interceptors: [
          CustomInterceptor1(),
          CustomInterceptor2(),
          CustomInterceptor3(),
        ]);
  }
}

class BoostNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('boost-didPush${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('boost-didPop${route.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('boost-didRemove${route.settings.name}');
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('boost-didStartUserGesture${route.settings.name}');
  }
}
