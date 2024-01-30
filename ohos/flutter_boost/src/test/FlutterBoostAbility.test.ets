import { describe, it, expect } from '@ohos/hypium';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import FlutterBoostAbility from '../main/ets/components/containers/FlutterBoostAbility';

const delegator = abilityDelegatorRegistry.getAbilityDelegator()
const bundleName = abilityDelegatorRegistry.getArguments().bundleName;

function sleep(time: number) {
  return new Promise<void>((resolve: Function) => setTimeout(resolve, time));
}

export default function FlutterBoostAbilityTest() {
  describe('FlutterBoostAbilityTest', () => {
    it('testUiExample', 0, async (done: Function) => {
      console.info("uitest: TestUiExample begin");
      console.error("uitest: TestUiExample begin bundleName" + bundleName);

      //start tested ability
      const want: Want = {
        bundleName: bundleName,
        abilityName: 'FlutterBoostAbility'
      }
      await delegator.startAbility(want);
      await sleep(1000);
      //check top display ability
      await delegator.getCurrentTopAbility().then((Ability: UIAbility) => {
        console.info("get top ability");
        expect(Ability.context.abilityInfo.name).assertEqual('EntryAbility');
      })
      done();
    })
  })
}
