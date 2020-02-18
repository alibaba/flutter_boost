import 'package:flutter_test/flutter_test.dart';
import 'unit/boost_channel_test.dart' as boost_channel;
//import 'unit/boost_container_test.dart' as boost_container;

import 'unit/boost_page_route_test.dart' as boost_page_route;

import 'unit/container_coordinator_test.dart'
    as container_coordinator;

import 'unit/container_manager_test.dart'
    as container_manager;
import 'unit/flutter_boost_test.dart' as flutter_boost;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('all_test', () {
    boost_channel.main();
//    boost_container.main();
    boost_page_route.main();
    container_coordinator.main();
    container_manager.main();
    flutter_boost.main();
  });
}
