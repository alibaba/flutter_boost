import FlutterBoostTest from './FlutterBoost.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest()
  FlutterBoostTest()
}