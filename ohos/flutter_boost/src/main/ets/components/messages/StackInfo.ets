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
import router from '@ohos.router'

/**
 * 界面栈信息
 * Containers Stack Information
 */
export default class StackInfo {
  public containers: Object[]
  public routes: Map<Object, Object>

  constructor() {
    this.containers = []
    this.routes = new Map<Object, Object>()
  }

  public toRecord(): Record<string, Object> {
    let toMapResult: Record<string, Object> = {
      'containers': this.containers,
      'routes': this.routes,
    }
    return toMapResult;
  }

  static fromObject(obj: Object): StackInfo {
    let fromRecordResult: StackInfo = new StackInfo();

    if (obj instanceof Map) {
      const map = obj as Map<string, Object>;
      let containers = map.get('containers');
      if (containers) {
        fromRecordResult.containers = containers as Object[]
      }
      let routes = map.get("routes");
      if (routes) {
        fromRecordResult.routes = routes as Map<Object, Object>;
      }
    } else if (typeof obj == 'object') {
      const record = obj as Record<string, Object>;
      let containers = record['containers'];
      if (containers) {
        fromRecordResult.containers = containers as Object[];
      }
      let routes = record["routes"];
      if (routes) {
        fromRecordResult.routes = routes as Map<Object, Object>
      }
    }
    return fromRecordResult;
  }
}