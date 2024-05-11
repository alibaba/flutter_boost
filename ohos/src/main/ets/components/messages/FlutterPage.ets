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
import FlutterBoostUtils from '../FlutterBoostUtils'

export default class FlutterPage {
  public withContainer?: boolean
  public pageName?: string
  public uniqueId?: string
  public arguments?: Record<string, Object>

  public toMap(): Map<string, Object> {
    let toMapResult: Map<string, Object> = new Map();
    toMapResult.set('withContainer', !!this.withContainer);
    if (this.pageName && this.pageName!.length > 0) {
      toMapResult.set('pageName', this.pageName);
    }

    if (this.uniqueId && this.uniqueId!.length > 0) {
      toMapResult.set('uniqueId', this.uniqueId);
    }

    if (this.arguments) {
      toMapResult.set('arguments', FlutterBoostUtils.recordToMap(this.arguments));
    }
    return toMapResult;
  }

  static fromMap(map: Map<string, Object>): FlutterPage {
    let fromMapResult: FlutterPage = new FlutterPage()

    let withContainer = map.get("withContainer")
    if (withContainer) {
      fromMapResult.withContainer = Boolean(withContainer)
    }

    let pageName = map.get("pageName");
    if (pageName) {
      fromMapResult.pageName = String(pageName)
    }

    let uniqueId = map.get("uniqueId");
    if (uniqueId) {
      fromMapResult.uniqueId = String(uniqueId)
    }

    let args = map.get("arguments")
    if (args) {
      if (args instanceof Map) {
        fromMapResult.arguments = FlutterBoostUtils.mapToRecord(args);
      } else if (typeof args == 'object') {
        fromMapResult.arguments = args as Record<string, Object>;
      }
    }

    return fromMapResult
  }
}