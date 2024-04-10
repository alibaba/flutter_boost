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
import router from '@ohos.router';
import { FlutterBoost } from '@ohos/flutter_boost';
import { FlutterUIComponent } from './FlutterUIPage';

const TAG: string = "xlog-EntryPage";
@Entry
@Component
struct EntryPage {
  @State message: string = 'FlutterBoost Example';
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#007DFF'
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()

  @Builder tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
      Divider()
        .strokeWidth(2)
        .color('#007DFF')
        .opacity(this.currentIndex === index ? 1 : 0)
    }.width('100%')
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        // 1. Home
        TabContent() {
          Row() {
            Column() {
              Text(this.message)
                .fontSize(28)
                .fontColor(Color.Red)
                .fontWeight(FontWeight.Bold)
                .decoration({ type: TextDecorationType.Underline, color: Color.Yellow })
                .margin({ bottom: 70 })
              Button('打开Flutter页面')
                .margin({ bottom: 20 })
                .onClick(() => {
                  try {
                    FlutterBoost.getInstance().open('flutterPage', {})
                  } catch (err) {
                    hilog.info(0x0000, TAG, '%{public}s', 'Failed to 打开Flutter页面');
                  }
                })
              Button('打开Native页面')
                .margin({ bottom: 20 })
                .onClick(() => {
                  try {
                    router.pushUrl({ url: 'pages/NativePage' })
                  } catch (err) {
                    hilog.info(0x0000, TAG, '%{public}s', 'Failed to 打开Native页面');
                  }
                })
              Button('打开Flutter半透明弹窗')
                .margin({ bottom: 20 })
                .onClick(() => {
                  try {
                    FlutterBoost.getInstance().open('transparentWidget', {})
                  } catch (err) {
                    hilog.info(0x0000, TAG, '%{public}s', 'Failed to 打开Flutter页面');
                  }
                })
            }
            .width('100%')
          }
          .height('100%')
        }.tabBar(this.tabBuilder(0, 'Home'))
        // 2. Index
        TabContent() {
          FlutterUIComponent({ uri: 'flutterPage' })
        }.tabBar(this.tabBuilder(1, 'Index'))
        // 3. MediaQuery
        TabContent() {
          FlutterUIComponent({ uri: 'mediaquery' })
        }.tabBar(this.tabBuilder(2, 'MediaQuery'))
        // 4. ArkUI
        TabContent() {
          Row() {
            Column() {
              Text("ArkUI")
                .fontSize(50)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
          }
          .height('100%')
        }.tabBar(this.tabBuilder(3, 'ArkUI'))
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(56)
      .animationDuration(300)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .width('100%')
      .height('100%')
    }.width('100%')
  }

  onBackPress(): boolean | void {
    FlutterBoost.getInstance().getPlugin()?.onBackPressed();
    return true;
  }
}