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
import { RouterModule, RouterOptions } from '../router/RouterModule';

const TAG: string = "FlutterUIPage";
@Component
export struct FlutterUIPage {
  private flutterEntry: FlutterBoostEntry | null = null;
  private flutterView?: FlutterView;
  private params: RouterOptions | null = null;

  aboutToAppear() {
    hilog.info(0x0000, TAG, "Page aboutToAppear===");
  }

  aboutToDisappear() {
    hilog.info(0x0000, TAG, "Page aboutToDisappear===");
    this.flutterEntry?.aboutToDisappear()
  }

  onPageShow() {
    hilog.info(0x0000, TAG, "Page onPageShow===");
    this.flutterEntry?.onPageShow()
  }

  onPageHide() {
    hilog.info(0x0000, TAG, "Page onPageHide===");
    this.flutterEntry?.onPageHide()
  }

  onBackPress(): boolean | void {
    hilog.info(0x0000, TAG, "Page onBackPress===");
    this.flutterEntry?.onBackPress();
    return true;
  }

  build() {
    NavDestination() {
      FlutterPage({ viewId: this.flutterView?.getId() })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      hilog.info(0x0000, TAG, "Page onBackPressed===");
      RouterModule.pop();
      return true;
    })
    .onAppear(() => {
      hilog.info(0x0000, TAG, "onAppear===");
    })
    .onDisAppear(() => {
      hilog.info(0x0000, TAG, "onDisAppear===");
    })
    .onShown(() => {
      this.onPageShow()
    })
    .onHidden(() => {
      this.onPageHide()
    })
    .onReady((ctx: NavDestinationContext) => {
      try {
        this.params = ctx.pathInfo.param as RouterOptions;
        this.flutterEntry = new FlutterBoostEntry(getContext(this), this.params);
        this.flutterEntry.aboutToAppear();
        this.flutterView = this.flutterEntry.getFlutterView();
        hilog.info(0x0000, TAG, "onReady===");
      } catch (e) {
        hilog.error(0x0000, TAG, `onReady catch exception: ${JSON.stringify(e)}`);
      }
    })
  }
}
