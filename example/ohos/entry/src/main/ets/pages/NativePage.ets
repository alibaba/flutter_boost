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

const TAG: string = "NativePage";

@Component
export struct NativePage {
  private routeStack: NavPathStack | null = null;
  @Prop params: Record<string, Object> = {}; 

  build() {
    NavDestination() {
      Column() {
        Text("ArkUI")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Text(JSON.stringify(this.params!["message"]))
          .fontSize(30)
          .fontColor(Color.Blue)
          .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Red)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      hilog.info(0x0000, TAG, "onBackPressed===");
      this.routeStack?.pop();
      return true
    })
    .onAppear(() => {
      hilog.info(0x0000, TAG, "onAppear===");
     })
    .onDisAppear(() => {
      hilog.info(0x0000, TAG, "onDisAppear===");
    })
    .onShown(() => {
      hilog.info(0x0000, TAG, "onShown===");
    })
    .onHidden(() => {
      hilog.info(0x0000, TAG, "onHidden===");
     })
    .onReady((ctx: NavDestinationContext) => {
      try {
        hilog.info(0x0000, TAG, "onReady===");
        this.routeStack = ctx.pathStack;
      } catch (e) {
        hilog.error(0x0000, TAG, `onReady catch exception: ${JSON.stringify(e)}`);
      }
    })
  }
}