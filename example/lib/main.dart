import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost_example/case/flutter_to_flutter_sample.dart';
import 'package:flutter_boost_example/case/image_pick.dart';
import 'package:flutter_boost_example/case/media_query.dart';
import 'package:flutter_boost_example/case/popUntil.dart';
import 'package:flutter_boost_example/case/return_data.dart';
import 'package:flutter_boost_example/case/selection_screen.dart';
import 'package:flutter_boost_example/case/state_restoration.dart';
import 'package:flutter_boost_example/case/system_ui_overlay_style.dart';
import 'package:flutter_boost_example/case/transparent_widget.dart';
import 'package:flutter_boost_example/case/radial_hero_animation.dart';
import 'package:flutter_boost_example/case/webview_flutter_demo.dart';
import 'package:flutter_boost_example/case/willpop.dart';
import 'package:flutter_boost_example/flutter_page.dart';
import 'package:flutter_boost_example/simple_page_widgets.dart';
import 'package:flutter_boost_example/tab/simple_widget.dart';

void main() {
  PageVisibilityBinding.instance
      .addGlobalObserver(AppGlobalPageVisibilityObserver());
  CustomFlutterBinding();
  runApp(MyApp());
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
  void onPush(BoostInterceptorOption option, PushInterceptorHandler handler) {
    Logger.log('CustomInterceptor1~~~, $option');
    // Add extra arguments
    option.arguments['CustomInterceptor1'] = "1";
    super.onPush(option, handler);
  }
}

class CustomInterceptor2 extends BoostInterceptor {
  @override
  void onPush(BoostInterceptorOption option, PushInterceptorHandler handler) {
    Logger.log('CustomInterceptor2~~~, $option');
    // Add extra arguments
    option.arguments['CustomInterceptor2'] = "2";
    // handler.resolve(<String, dynamic>{'result': 'xxxx'});
    handler.next(option);
  }
}

class CustomInterceptor3 extends BoostInterceptor {
  @override
  void onPush(BoostInterceptorOption option, PushInterceptorHandler handler) {
    Logger.log('CustomInterceptor3~~~, $option');
    // Replace arguments
    option.arguments = <String, dynamic>{'CustomInterceptor3': '3'};
    handler.next(option);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
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
          pageBuilder: (_, __, ___) => FlutterRouteWidget(
                params: settings.arguments,
                uniqueId: uniqueId,
              ));
    },
    'imagepick': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => ImagePickerPage(title: "xxx"));
    },
    'firstFirst': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => FirstFirstRouteWidget());
    },
    'willPop': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings, pageBuilder: (_, __, ___) => WillPopRoute());
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
      print('flutterPage settings:$settings, uniqueId:$uniqueId');
      return PageRouteBuilder<dynamic>(
        settings: settings,
        pageBuilder: (_, __, ___) => FlutterRouteWidget(
          params: settings.arguments,
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
    'tab_friend': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SimpleWidget(
              uniqueId, settings.arguments, "This is a flutter fragment"));
    },
    'tab_message': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SimpleWidget(
              uniqueId, settings.arguments, "This is a flutter fragment"));
    },
    'tab_flutter1': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SimpleWidget(
              uniqueId, settings.arguments, "This is a custom FlutterView"));
    },
    'tab_flutter2': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SimpleWidget(
              uniqueId, settings.arguments, "This is a custom FlutterView"));
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
    'state_restoration': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => StateRestorationDemo());
    },
    'system_ui_overlay_style': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => SystemUiOverlayStyleDemo());
    },
    'mediaquery': (settings, uniqueId) {
      return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (_, __, ___) => MediaQueryRouteWidget(
                params: settings.arguments,
                uniqueId: uniqueId,
              ));
    },
  };

  Route<dynamic> routeFactory(RouteSettings settings, String uniqueId) {
    FlutterBoostRouteFactory func = routerMap[settings.name];
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
    return FlutterBoostApp(routeFactory, interceptors: [
      CustomInterceptor1(),
      CustomInterceptor2(),
      CustomInterceptor3()
    ]);
  }
}

class BoostNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didPush' + route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didPop' + route.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didRemove' + route.settings.name);
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
    print('boost-didStartUserGesture' + route.settings.name);
  }
}
