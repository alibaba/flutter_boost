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

import { FlutterPage, FlutterManager, FlutterView } from '@ohos/flutter_ohos';
import Log from '../util/Log';

const TAG = "FlutterBoostPage";

/**
 * 基础page组件，承载XComponent组件
 */
@Component
export struct FlutterBoostPage {
  @Prop viewId: string = ""

  aboutToAppear() {
    let list: Map<String, FlutterView> = FlutterManager.getInstance().getFlutterViewList();
    const keys = Array.from(list.keys());
    for (let i = 0; i < keys.length; i++) {
      const viewId = keys[i];
      if (viewId !== this.viewId) {
        const flutterView: FlutterView = list.get(viewId) as FlutterView;
        if (flutterView.isAttachedToFlutterEngine()) {
          Log.e(TAG, 'flutterView  ' + viewId + 'detachFromFlutterEngine');
          flutterView.detachFromFlutterEngine();
        }
      }
    }
  }

  build() {
    Stack() {
      FlutterPage({ viewId: this.viewId })
    }
  }
}