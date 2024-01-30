import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit } from '@ohos/hypium'
import { FlutterBoost, FlutterBoostDelegate, FlutterBoostRouteOptions } from '../../index';
import FlutterEngine from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngine';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import TestFlutterBoostDelegate from './TestFlutterBoostDelegate';

const delegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function FlutterBoostTest() {
  describe('FlutterBoostTest', () => {
    it('testFlutterBoostSetup', 0, () => {
      const context = delegator.getAppContext();
      const delegate: TestFlutterBoostDelegate = new TestFlutterBoostDelegate()
      FlutterBoost.getInstance().setup(delegate, context, (engine: FlutterEngine) => {
          expect(engine).assertNull()
      }, null);
    })
  })
}