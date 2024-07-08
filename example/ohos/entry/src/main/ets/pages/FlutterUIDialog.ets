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

import Curves from '@ohos.curves'
import hilog from '@ohos.hilog';
import { FlutterBoostEntry } from 'flutter_boost';
import { FlutterPage, FlutterView } from '@ohos/flutter_ohos';
import { RouterOptions } from '../router/RouterModule';

const TAG: string = "FlutterUIDialog";
@Component
export struct FlutterUIDialog {
  private flutterEntry: FlutterBoostEntry | null = null;
  private flutterView: FlutterView | null = null;
  @Prop xComponentType: XComponentType = XComponentType.SURFACE;
  @Prop routerOptions: RouterOptions; 
  private effect: object =
    TransitionEffect.OPACITY
      .combine(TransitionEffect.move(TransitionEdge.BOTTOM)).animation({curve: Curves.springMotion()});
  @State enableAnimation: boolean = true;

  async aboutToAppear() {
    hilog.info(0x0000, TAG, "aboutToAppear===");
    this.flutterEntry = new FlutterBoostEntry(getContext(this), this.routerOptions, /*isDialog*/true);
    await this.flutterEntry.aboutToAppear();
    // The |aboutToAppear| method is called first,
    // followed by the |getFlutterView| method.
    this.flutterView = this.flutterEntry.getFlutterView();
  }

  aboutToDisappear() {
    hilog.info(0x0000, TAG, "aboutToDisappear===");
    this.flutterEntry?.aboutToDisappear()
  }

  build() {
    NavDestination() {
      FlutterPage({
        viewId: this.flutterView!.getId(),
        xComponentType: this.xComponentType
      })
    }
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
    .onBackPressed(() => {
      hilog.info(0x0000, TAG, "onBackPressed===");
      return this.flutterEntry!.onBackPressed();
    })
    .onShown(() => {
      hilog.info(0x0000, TAG, "onShown===");
      this.flutterEntry?.onShown();
    })
    .onHidden(() => {
      hilog.info(0x0000, TAG, "onHidden===");
      this.flutterEntry?.onHidden();
      this.enableAnimation = false;
    })
    .onReady((ctx: NavDestinationContext) => {
      try {
        hilog.info(0x0000, TAG, "onReady===");
        this.flutterEntry?.onReady(ctx.pathStack);
      } catch (e) {
        hilog.error(0x0000, TAG, `onReady catch exception: ${JSON.stringify(e)}`);
      }
    })
    .transition(this.enableAnimation ? this.effect : null)
  }
}