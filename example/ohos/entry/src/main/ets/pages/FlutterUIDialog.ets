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

import hilog from '@ohos.hilog';
import { FlutterBoostEntry } from '@ohos/flutter_boost';
import { FlutterPage, FlutterView } from '@ohos/flutter_ohos';
import { RouterOptions } from '../router/RouterModule';

const TAG: string = "FlutterUIDialog";
@Component
export struct FlutterUIDialog {
  private flutterEntry: FlutterBoostEntry | null = null;
  private flutterView?: FlutterView
  private params: RouterOptions | null = null;

  aboutToAppear() {
    hilog.info(0x0000, TAG, "aboutToAppear===");
  }

  aboutToDisappear() {
    hilog.info(0x0000, TAG, "aboutToDisappear===");
    this.flutterEntry?.aboutToDisappear()
  }

  build() {
    NavDestination() {
      FlutterPage({ viewId: this.flutterView?.getId() })
    }
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
    .onBackPressed(() => {
      hilog.info(0x0000, TAG, "onBackPressed===");
      this.flutterEntry?.onBackPress();
      return true
    })
    .onShown(() => {
      hilog.info(0x0000, TAG, "onShown===");
      this.flutterEntry?.onPageShow();
    })
    .onHidden(() => {
      hilog.info(0x0000, TAG, "onHidden===");
      this.flutterEntry?.onPageHide();
    })
    .onReady((ctx: NavDestinationContext) => {
      try {
        this.params = ctx.pathInfo.param as RouterOptions;
        this.flutterEntry = new FlutterBoostEntry(getContext(this), this.params, ctx.pathStack);
        this.flutterEntry.aboutToAppear();
        this.flutterView = this.flutterEntry.getFlutterView();
        hilog.info(0x0000, TAG, "onReady===");
      } catch (e) {
        hilog.error(0x0000, TAG, `onReady catch exception: ${JSON.stringify(e)}`);
      }
    })
  }
}