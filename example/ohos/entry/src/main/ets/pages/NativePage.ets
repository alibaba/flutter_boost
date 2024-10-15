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

import promptAction from '@ohos.promptAction'
import { FlutterBoost } from 'flutter_boost';
import { FlutterUIComponent } from './FlutterUIComponent';
import { RouterModule, RouterOptions } from '../router/RouterModule';
import { RouterNameConstants } from '../constants/RouterConstants';

const TAG: string = "NativePage";

@Component
export struct NativePage {
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#007DFF'
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()
  bottomRectHeight: string = AppStorage.get<number>('bottomRectHeight') + 'px';

  private routeStack: NavPathStack | null = null;
  @Prop params: Record<string, Object> = {}; 

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

  @Builder homeContents() {
    Column() {
      Text("ArkUI")
        .fontSize(28)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Bold)
        .decoration({ type: TextDecorationType.Underline, color: Color.Yellow })
        .margin({ bottom: 20 })
      Text(JSON.stringify(this.params!["message"]))
        .fontSize(28)
        .fontColor(Color.Red)
        .fontWeight(FontWeight.Bold)
        .decoration({ type: TextDecorationType.Underline, color: Color.Yellow })
        .margin({ bottom: 70 })
      Button('打开Flutter页面')
        .margin({ bottom: 20 })
        .onClick(() => {
          try {
            FlutterBoost.getInstance().open('flutterPage', {}, /*opaque*/true, (pageName: string, result: Record<string, Object>) => {
              this.onPageResult(pageName, result)
            })
          } catch (err) {
            hilog.info(0x0000, TAG, '%{public}s', 'Failed to 打开Flutter页面');
          }
        })
      Button('打开pop Uitil页面')
        .margin({ bottom: 20 })
        .onClick(() => {
          try {
            FlutterBoost.getInstance().open('popUntilView', {}, /*opaque*/true, (pageName: string, result: Record<string, Object>) => {
              this.onPageResult(pageName, result)
            })
          } catch (err) {
            hilog.info(0x0000, TAG, '%{public}s', 'Failed to 打开Flutter页面');
          }
        })
      Button('打开Native页面')
        .margin({ bottom: 20 })
        .onClick(() => {
          try {
            RouterModule.push(RouterNameConstants.NATIVE_PAGE, { "message": "A Message From Native" }, 
              (pageName: string, result: Record<string, Object>) => {
                this.onPageResult(pageName, result)
              });
          } catch (err) {
            hilog.info(0x0000, TAG, '%{public}s', 'Failed to 打开Native页面');
          }
        })
      Button('打开Flutter半透明弹窗')
        .margin({ bottom: 20 })
        .onClick(() => {
          try {
            FlutterBoost.getInstance().open('transparentWidget', {}, false)
          } catch (err) {
            hilog.info(0x0000, TAG, '%{public}s', 'Failed to 打开Flutter页面');
          }
        })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%').height('100%')
    .backgroundColor('#F1F3F5')
  }

  build() {
    NavDestination() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        // 1. Home
        TabContent() {
          this.homeContents()
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
          Column() {
            Text("ArkUI")
              .fontSize(50)
              .fontWeight(FontWeight.Bold)
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F1F3F5')
          .width('100%').height('100%')
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
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      hilog.info(0x0000, TAG, "onBackPressed===");
      RouterModule.pop({ "message": "pop from a native page" });
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

  onPageResult(pageName: string, result: Record<string, Object>) {
    if (result) {
      promptAction.showToast({ message: "#onPageResult:" + JSON.stringify(result) });
    }
  }
}