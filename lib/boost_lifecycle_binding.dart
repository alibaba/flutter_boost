import 'package:flutter/widgets.dart';

import 'boost_container.dart';
import 'logger.dart';
import 'page_visibility.dart';

class BoostLifecycleBinding {
  BoostLifecycleBinding._();

  static final BoostLifecycleBinding instance = BoostLifecycleBinding._();

  void containerDidPush(
      BoostContainer container, BoostContainer previousContainer) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidPush');
    PageVisibilityBinding.instance
        .dispatchPageCreateEvent(container.topPage.route);
  }

  void containerDidPop(
      BoostContainer container, BoostContainer previousContainer) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidPop');
    PageVisibilityBinding.instance
        .dispatchPageDestroyEvent(container.topPage.route);
  }

  void containerDidShow(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidShow');
    PageVisibilityBinding.instance
        .dispatchPageShowEvent(container.topPage.route);
  }

  void containerDidHide(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidHide');
    PageVisibilityBinding.instance
        .dispatchPageHideEvent(container.topPage.route);
  }

  void routeDidPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.routeDidPush');
    PageVisibilityBinding.instance.dispatchPageCreateEvent(route);
    PageVisibilityBinding.instance.dispatchPageShowEvent(route);
    PageVisibilityBinding.instance.dispatchPageHideEvent(previousRoute);
  }

  void routeDidPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.routeDidPop');
    PageVisibilityBinding.instance.dispatchPageHideEvent(route);
    PageVisibilityBinding.instance.dispatchPageShowEvent(previousRoute);
    PageVisibilityBinding.instance.dispatchPageDestroyEvent(route);
  }

  void appDidEnterForeground(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.appDidEnterForeground');
  }

  void appDidEnterBackground(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.appDidEnterBackground');
  }
}
