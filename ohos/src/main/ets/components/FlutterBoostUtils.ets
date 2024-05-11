/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 Alibaba Group
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import { FlutterEngine } from '@ohos/flutter_ohos';
import { FlutterBoostPlugin } from './plugin/FlutterBoostPlugin';

export default class FlutterBoostUtils {
  public static getPlugin(engine: FlutterEngine): FlutterBoostPlugin | null {
    if (engine) {
      const plugins = engine.getPlugins()
      if (plugins) {
        const plugin = plugins.get(FlutterBoostPlugin.className)
        if (plugin instanceof FlutterBoostPlugin) {
          const flutterBoostPlugin: FlutterBoostPlugin = plugins.get(FlutterBoostPlugin.className) as FlutterBoostPlugin
          return flutterBoostPlugin
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    return null;
  }

  /**
   * 递归遍历映射对象，将其转换为Record对象。
   *
   * @param map 要遍历的映射对象
   * @returns 转换后的记录对象
   */
  public static mapToRecord(map: Map<string, Object>): Record<string, Object> {
    let result: Record<string, Object> = {};
    map.forEach((value, key) => {
      if (value instanceof Map) {
        result[key] = FlutterBoostUtils.mapToRecord(value);
      } else {
        result[key] = value;
      }
    })
    return result;
  }

  /**
   * 递归遍历记录对象，将其转换为映射对象。
   *
   * @param record 要遍历的记录对象
   * @returns 转换后的映射对象
   */
  public static recordToMap(record: Record<string, Object>): Map<string, Object> {
    const map = new Map<string, Object>();
    Object.keys(record).forEach((key) => {
      const value = record[key];
      if (FlutterBoostUtils.isObject(value)) {
        const record = value as Record<string, Object>;
        map.set(key, FlutterBoostUtils.recordToMap(record));
      } else {
        map.set(key, value);
      }
    });
    return map;
  }

  private static isObject(value: Object): boolean {
    return value !== null && typeof value === 'object' && !(value instanceof Array) && !(value instanceof Date) && !(value instanceof RegExp);
  }
}