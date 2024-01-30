import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import {
  FlutterBoost,
  FlutterBoostDelegate,
  FlutterBoostRouteOptions,
  FlutterBoostAbility,
  FlutterBoostSetupOptions,
  FlutterBoostSetupOptionsBuilder
} from '@ohos/flutter_boost'
import common from '@ohos.app.ability.common';
import FlutterEngine from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngine';
import EntryAbility from '../../../main/ets/entryability/EntryAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';


const delegator = abilityDelegatorRegistry.getAbilityDelegator()
const bundleName = abilityDelegatorRegistry.getArguments().bundleName;

function sleep(time: number) {
  return new Promise<void>((resolve: Function) => setTimeout(resolve, time));
}

class TestFlutterBoostDelegate implements  FlutterBoostDelegate{
  pushNativeRoute(options: FlutterBoostRouteOptions) {
    throw new Error('Method not implemented.');
  }

  pushFlutterRoute(options: FlutterBoostRouteOptions) {
    throw new Error('Method not implemented.');
  }
}

export default function FlutterBoostAbilityTest() {


  describe('FlutterBoostAbilityTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('assertEqual-once', 0, () => {
      console.info("it1 begin");
      let mocker: MockKit = new MockKit();
      class ClassName {
        constructor() {
        }
        method_1(arg:string) {
          return '888888';
        }
        method_2(arg:string) {
          return '999999';
        }
      }
      let claser = new ClassName();
      let mockfunc: Function = mocker.mockFunc(claser, claser.method_1);
      when(mockfunc)('test').afterReturnNothing();
      expect(claser.method_1('test')).assertUndefined();
    });

    it('FlutterBoostFlutterEngineIsNotNull', 0, async (done: Function) => {
      console.info("uitest: TestUiExample begin" + bundleName);

      // 1. 先拉起EntryAbility
      const want: Want = {
        bundleName: 'com.example.flutter_boost_example',
        abilityName: 'EntryAbility'
      }
      await delegator.startAbility(want);
      await sleep(1000);
      const ability: UIAbility = await delegator.getCurrentTopAbility()
      expect(ability.context.abilityInfo.name).assertEqual('EntryAbility');

      // 2.测试engine不为null
      const engine = FlutterBoost.getInstance().getEngine()
      expect(engine).not().assertNull();
      done();
    })


    it('FlutterBoostOpen', 0, async (done: Function) => {
      console.info("uitest: TestUiExample begin" + bundleName);

      // 1. 先拉起EntryAbility
      const want: Want = {
        bundleName: 'com.example.flutter_boost_example',
        abilityName: 'EntryAbility'
      }
      await delegator.startAbility(want);
      await sleep(1000);
      const ability: UIAbility = await delegator.getCurrentTopAbility()
      expect(ability.context.abilityInfo.name).assertEqual('EntryAbility');



      done();
    })

    it('FlutterBoostSetup', 0, async (done: Function) => {
      console.info("uitest: TestUiExample begin" + bundleName);

      let mocker: MockKit = new MockKit();
      let claser = FlutterBoost.getInstance()
      mocker.mockFunc(claser, claser.setup);
      // 1. 先拉起EntryAbility
      const want: Want = {
        bundleName: 'com.example.flutter_boost_example',
        abilityName: 'EntryAbility'
      }
      await delegator.startAbility(want);
      await sleep(1000);
      const ability: UIAbility = await delegator.getCurrentTopAbility()
      expect(ability.context.abilityInfo.name).assertEqual('EntryAbility');

      class LaunchParam implements AbilityConstant.LaunchParam {
        launchReason: AbilityConstant.LaunchReason;
        lastExitReason: AbilityConstant.LastExitReason;
        constructor() {
          this.launchReason = AbilityConstant.LaunchReason.START_ABILITY;
          this.lastExitReason = AbilityConstant.LastExitReason.NORMAL;
        }
      }

      class A{
        funA(){
          const context = delegator.getAppContext();
          const delegate = new TestFlutterBoostDelegate()
          FlutterBoost.getInstance().setup(delegate, context, (flutterEngine: FlutterEngine) => {
          }, null)
        }
      }
      // const param = new LaunchParam()
      // await ability.onCreate(want,param)
      // await sleep(2000);

      const a= new A()
      a.funA()

      const context = delegator.getAppContext();
      const delegate = ability as EntryAbility;
      const args = [delegate, context, (flutterEngine: FlutterEngine) => {
      }, null]
      mocker.verify('setup', args).once()
      done();
    })

    // TODO:want参数传递
    it('testFlutterBoostAbilityWant', 0, async (done: Function) => {
      // 1. 传递want传递的参数是否没问题 。包含url，param，getUniqueId
      done();
    })

    // TODO:want通过PARAM传递参数
    it('testFlutterBoostAbilityWantParam', 0, async (done: Function) => {
      // 1. 传递want传递的参数是否没问题 。包含url，param，getUniqueId
      done();
    })

    // TODO:测试Stage
    it('testFlutterBoostAbilityStage', 0, async (done: Function) => {
      done();
    })




  })
}