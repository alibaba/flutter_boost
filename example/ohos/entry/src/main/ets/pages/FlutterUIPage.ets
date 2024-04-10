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
import router from '@ohos.router';
import { FlutterBoost, FlutterBoostEntry } from '@ohos/flutter_boost';
import { FlutterPage, FlutterView } from '@ohos/flutter_ohos';

const TAG: string = "xlog-FlutterUI";

@Entry
@Component
struct FlutterUIPage {
  private flutterEntry: FlutterBoostEntry | null = null;
  private flutterView?: FlutterView;

  aboutToAppear() {
    this.flutterEntry = new FlutterBoostEntry(getContext(this), router.getParams());
    this.flutterEntry.aboutToAppear();
    this.flutterView = this.flutterEntry.getFlutterView();
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
    FlutterBoost.getInstance().getPlugin()?.onBackPressed();
    return true;
  }

  build() {
    Stack() {
      FlutterPage({ viewId: this.flutterView?.getId() })
    }
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300 })
      .slide(SlideEffect.Right)

    PageTransitionExit({ duration: 300 })
      .translate({ x: 0, y: 0 })
      .opacity(0)
  }
}

@Component
export struct FlutterUIComponent {
  @Prop uri: string;
  @Prop params: Record<string, Object>;

  private flutterEntry: FlutterBoostEntry | null = null;
  private flutterView?: FlutterView;
  private effect: object =
    TransitionEffect.OPACITY
      .combine(TransitionEffect.move(TransitionEdge.END)).animation({curve: Curves.springMotion()});

  aboutToAppear() {
    this.flutterEntry = new FlutterBoostEntry(getContext(this), {
      uri: this.uri,
      params: this.params,
    });
    this.flutterEntry.aboutToAppear();
    this.flutterView = this.flutterEntry.getFlutterView();
    hilog.info(0x0000, TAG, 'Component(#%{public}s) aboutToAppear===', this.uri);
  }

  aboutToDisappear() {
    hilog.info(0x0000, TAG, 'Component(#%{public}s) aboutToDisappear===', this.uri);
    this.flutterEntry?.aboutToDisappear()
  }

  onPageShow() {
    hilog.info(0x0000, TAG, 'Component(#%{public}s) onPageShow===', this.uri);
    this.flutterEntry?.onPageShow()
  }

  onPageHide() {
    hilog.info(0x0000, TAG, 'Component(#%{public}s) onPageHide===', this.uri);
    this.flutterEntry?.onPageHide()
  }

  build() {
    Stack() {
      FlutterPage({ viewId: this.flutterView?.getId() })
    }
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (isVisible) {
        this.onPageShow();
      } else {
        this.onPageHide();
      }
    })
    .transition(this.effect)
  }
}