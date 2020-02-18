import 'package:flutter_test/flutter_test.dart';
import 'package:boost_test/unit/boost_channel_test.dart' as boost_channel;
import 'package:boost_test/unit/boost_container_test.dart' as boost_container;

import 'package:boost_test/unit/boost_page_route_test.dart' as boost_page_route;

import 'package:boost_test/unit/container_coordinator_test.dart'
    as container_coordinator;

import 'package:boost_test/unit/container_manager_test.dart'
    as container_manager;
import 'package:boost_test/unit/flutter_boost_test.dart' as flutter_boost;


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('all_test', () {
    boost_channel.main();
    boost_container.main();
    boost_page_route.main();
    container_coordinator.main();
    container_manager.main();
    flutter_boost.main();
  });
}
