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
import { FlutterUIPage } from './FlutterUIPage';
import { FlutterUIDialog } from './FlutterUIDialog';
import { NativePage } from './NativePage';
import { RouterModule, RouterOptions } from '../router/RouterModule';
import { RouterNameConstants } from '../constants/RouterConstants';

const TAG: string = "EntryPage";
let storage = LocalStorage.getShared();

@Entry(storage)
@Component
struct EntryPage {
  @State message: string = 'FlutterBoost Example';
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#007DFF'
  @State currentIndex: number = 0
  private routeStack: NavPathStack = new NavPathStack();
  private controller: TabsController = new TabsController()
  bottomRectHeight: string = AppStorage.get<number>('bottomRectHeight') + 'px';

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

  @Builder routerMap(builderName: string, options: RouterOptions | Record<string, Object>) {
    if (builderName == RouterNameConstants.FLUTTER_PAGE) {
      FlutterUIPage({ routerOptions: (options as RouterOptions) })
    } else if (builderName == RouterNameConstants.FLUTTER_DIALOG) {
      FlutterUIDialog({ routerOptions: (options as RouterOptions) })
    } else {
      //无论是从dart侧打开native页面还是从native侧打开native页面，都需要在此对builderName（也就是pageName）再次进行分支判断然后选择相应的native页面，
      //由于example中只有一个额外的native页面，所以在此不过多展开示范
      NativePage({ params: (options as Record<string, Object>) })
    }
  }

  @Builder homeContents() {
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

  aboutToAppear() {
    RouterModule.setRouteStack(this.routeStack);
  }

  build() {
    Column() {
      Navigation(this.routeStack) { // Navigation关联NavPathStack路由栈
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
      .mode(NavigationMode.Stack)
      .navDestination(this.routerMap) // Navigation关联routerMap路由表
      .hideTitleBar(true) // important
      // .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      //   hilog.info(0x0000, TAG, 'customNavContentTransition~~');
      //   // 执行默认转场动效
      //   return undefined;
      // })
    }
    .width('100%')
    .margin({ bottom: this.bottomRectHeight }) // 此处margin与导航条区域高度保持一致
  }

  onBackPress(): boolean | void {
    FlutterBoost.getInstance().getPlugin()?.onBackPressed();
    return true;
  }

  onPageResult(pageName: string, result: Record<string, Object>) {
    if (result) {
      promptAction.showToast({ message: "#onPageResult:" + JSON.stringify(result) });
    }
  }
}