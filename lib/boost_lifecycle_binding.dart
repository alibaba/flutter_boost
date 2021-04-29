import 'package:flutter/widgets.dart';
import 'package:flutter_boost/boost_container.dart';
import 'package:flutter_boost/page_visibility.dart';

import 'logger.dart';

class BoostLifecycleBinding {
  BoostLifecycleBinding._();

  static final BoostLifecycleBinding instance = BoostLifecycleBinding._();

  void containerDidMoveToTop(
      BoostContainer container, BoostContainer previousContainer) {
    // Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidMoveToTop');
    // PageVisibilityBinding.instance
    //     .dispatchPageShowEvent(container.topPage.route);
    // if (previousContainer.topPage.route != null) {
    //   PageVisibilityBinding.instance
    //       .dispatchPageHideEvent(previousContainer.topPage.route);
    // }
  }

  void containerDidPush(
      BoostContainer container, BoostContainer previousContainer) {
    // Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidPush');
    // PageVisibilityBinding.instance
    //     .dispatchPageShowEvent(container.topPage.route);
    // if (previousContainer.topPage.route != null) {
    //   PageVisibilityBinding.instance
    //       .dispatchPageHideEvent(previousContainer.topPage.route);
    // }
  }

  void containerDidPop(
      BoostContainer container, BoostContainer previousContainer) {
    // Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidPop');
  }

  void containerDidHide(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidHide');
    PageVisibilityBinding.instance
        .dispatchPageHideEvent(container.topPage.route);

  }

  void containerDidShow(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.containerDidShow');
    PageVisibilityBinding.instance
        .dispatchPageShowEvent(container.topPage.route);
  }

  void appDidEnterForeground(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.appDidEnterForeground');
    PageVisibilityBinding.instance.dispatchPageShowEvent(
        container.topPage.route,
        isForegroundEvent: true);
  }

  void appDidEnterBackground(BoostContainer container) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.appDidEnterBackground');
    PageVisibilityBinding.instance.dispatchPageHideEvent(
        container.topPage.route,
        isBackgroundEvent: true);
  }

  void routeDidPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.routeDidPush');
    PageVisibilityBinding.instance.dispatchPageShowEvent(route);
    PageVisibilityBinding.instance.dispatchPageHideEvent(previousRoute);
  }

  void routeDidPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    Logger.log('boost_lifecycle: BoostLifecycleBinding.routeDidPop');
    PageVisibilityBinding.instance.dispatchPageHideEvent(route);
    PageVisibilityBinding.instance.dispatchPageShowEvent(previousRoute);
  }
}
