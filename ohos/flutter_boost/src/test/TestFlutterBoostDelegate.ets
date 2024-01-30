import { FlutterBoost, FlutterBoostDelegate, FlutterBoostRouteOptions } from '../../index';

export default class TestFlutterBoostDelegate implements FlutterBoostDelegate {
  pushNativeRoute(options: FlutterBoostRouteOptions) {
    throw new Error('Method not implemented.');
  }

  pushFlutterRoute(options: FlutterBoostRouteOptions) {
    throw new Error('Method not implemented.');
  }
}