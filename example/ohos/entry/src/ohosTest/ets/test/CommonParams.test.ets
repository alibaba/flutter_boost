import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { CommonParams } from 'flutter_boost';

export default function CommonParamsTest() {
  describe('fromObject', () => {
    it('should_convert_a_Map_to_CommonParams', 0, () => {
      const map = new Map<string, Object>([
        ['pageName', 'TestPage'],
        ['uniqueId', 'TestId'],
        ['arguments', new Map([['arg1', 'value1']])], // Assuming this will be converted back to Record
        ['opaque', true],
        ['key', 'TestKey']
      ]);
      const params = CommonParams.fromObject(map);
      expect(params.pageName).assertEqual('TestPage');
      expect(params.uniqueId).assertEqual('TestId');
      expect(params.arguments).assertDeepEquals({
        arg1: 'value1'
      });
      expect(params.opaque).assertEqual(true);
      expect(params.key).assertEqual('TestKey');
    })

    it('should_convert_an_Object_to_CommonParams', 0, () => {
      const params = CommonParams.fromObject({
        pageName: 'TestPage',
        uniqueId: 'TestId',
        arguments: {
          arg1: 'value1'
        },
        opaque: true,
        key: 'TestKey'
      });

      expect(params.pageName).assertEqual('TestPage');
      expect(params.uniqueId).assertEqual('TestId');
      expect(params.arguments).assertDeepEquals({
        arg1: 'value1'
      });
      expect(params.opaque).assertEqual(true);
      expect(params.key).assertEqual('TestKey');
    });

  })

  describe('toMap', () => {
    it('should_convert_CommonParams_properties_to_a_Map', 0, () => {
      const params = new CommonParams();
      params.pageName = 'TestPage';
      params.uniqueId = 'TestId';
      params.arguments = {
        arg1: 'value1', arg2: 123
      };
      params.opaque = true;
      params.key = 'TestKey';
      const map = params.toMap();

      expect(map.get('pageName')).assertEqual('TestPage');
      expect(map.get('uniqueId')).assertEqual('TestId');
      expect(map.get('arguments')).assertDeepEquals(new Map<string, Object>([["arg1", "value1"], ["arg2", 123]]));
      expect(map.get('opaque')).assertEqual(true);
      expect(map.get('key')).assertEqual('TestKey');
    })

    it('should_not_include_properties_that_are_undefined_or_empty_in_the_Map', 0, () => {
      const params = new CommonParams();
      const map = params.toMap();

      expect(map.has('pageName')).assertEqual(false);
      expect(map.has('uniqueId')).assertEqual(false);
      expect(map.has('arguments')).assertEqual(false);
      expect(map.has('opaque')).assertEqual(false);
      expect(map.has('key')).assertEqual(false);
    })
  })
}