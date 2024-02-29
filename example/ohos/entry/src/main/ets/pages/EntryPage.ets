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
import router from '@ohos.router';
import { FlutterPage } from '@ohos/flutter_ohos';
import bottomTabItems from '../viewmodel/BottomTabItems';
import { TabItem } from '../viewmodel/TabItem';
import { FlutterBoost, FlutterBoostEntry } from '@ohos/flutter_boost';

const TAG = "EntryPage";

@Entry
@Component
struct EntryPage {
  @State currentIndex: number = 0;
  private flutterEntries: Array<FlutterBoostEntry> = [];
  private isOpaque: boolean = true;

  build() {
    Column() {
      Tabs({
        index: this.currentIndex,
        barPosition: BarPosition.End
      }) {
        // ForEach(bottomTabItems.getTabItems(), (item: TabItem) => {
        //   TabContent() {
        //     Column() {
        //       this.Content()
        //     }
        //   }
        //   .tabBar(this.CardTab(item))
        // }, (item: TabItem, index?: number) => index + JSON.stringify(item))

        TabContent() {
          Column() {
            FlutterPage({ viewId: this.flutterEntries[0]?.getFlutterView()?.getId() })
          }
        }.tabBar(this.CardTab(bottomTabItems.getTabItems()[0]))


        TabContent() {
          Column() {
            FlutterPage({ viewId: this.flutterEntries[1]?.getFlutterView()?.getId() })
          }
        }.tabBar(this.CardTab(bottomTabItems.getTabItems()[1]))


        TabContent() {
          Column() {
            FlutterPage({ viewId: this.flutterEntries[2]?.getFlutterView()?.getId() })
          }
        }.tabBar(this.CardTab(bottomTabItems.getTabItems()[2]))


        TabContent() {
          Column() {
            Button('打开FlutterEntry')
              .onClick(() => {
                this.isOpaque = true;
                FlutterBoost.getInstance().open('flutterPage', {})
              })

            Button('打开透明FlutterEntry')
              .onClick(() => {
                this.isOpaque = false;
                FlutterBoost.getInstance().open('transparentWidget', {}, this.isOpaque)
              })
          }
        }.tabBar(this.CardTab(bottomTabItems.getTabItems()[3]))

      }
      .animationDuration(0)
      .vertical(false)
      .barWidth("100%")
      .barHeight("56vp")
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .align(Alignment.Center)
      .onChange((index: number) => {
        this.currentIndex = index;
        this._onFlutterTabShow();
      })
    }
    .backgroundColor("#F1F3F5")
  }

  // 组件生命周期
  aboutToAppear() {
    console.info('MyComponent aboutToAppear');

    const firstFlutterEntry: FlutterBoostEntry = new FlutterBoostEntry(getContext(this), {
      uri: 'firstFirst'
    });

    const secondFlutterEntry: FlutterBoostEntry = new FlutterBoostEntry(getContext(this), {
      uri: 'flutterPage'
    });

    const thirdFlutterEntry: FlutterBoostEntry = new FlutterBoostEntry(getContext(this), {
      uri: 'flutterPage'
    });

    firstFlutterEntry.aboutToAppear();
    secondFlutterEntry.aboutToAppear();
    thirdFlutterEntry.aboutToAppear();

    this.flutterEntries.push(firstFlutterEntry);
    this.flutterEntries.push(secondFlutterEntry);
    this.flutterEntries.push(thirdFlutterEntry);
  }

  // 组件生命周期
  aboutToDisappear() {
    console.info('MyComponent aboutToDisappear');
  }

  // 只有被@Entry装饰的组件才可以调用页面的生命周期
  onPageShow() {
    console.info('Index onPageShow');
    this._onFlutterTabShow();
  }

  // 只有被@Entry装饰的组件才可以调用页面的生命周期
  onPageHide() {
    console.info('Index onPageHide');
    this._onFlutterTabHide();
  }

  _onFlutterTabShow() {
    if (this.currentIndex == 0) {
      this.flutterEntries[1]?.onPageHide();
      this.flutterEntries[2]?.onPageHide();
      this.flutterEntries[0]?.onPageShow();
    } else if (this.currentIndex == 1) {
      this.flutterEntries[0]?.onPageHide();
      this.flutterEntries[2]?.onPageHide();
      this.flutterEntries[1]?.onPageShow();
    } else if (this.currentIndex == 2) {
      this.flutterEntries[0]?.onPageHide();
      this.flutterEntries[1]?.onPageHide();
      this.flutterEntries[2]?.onPageShow();
    }
  }

  _onFlutterTabHide() {
    if (this.currentIndex == 0) {
      this.flutterEntries[0]?.onPageHide();
    } else if (this.currentIndex == 1) {
      this.flutterEntries[1]?.onPageHide();
    } else if (this.currentIndex == 2) {
      this.flutterEntries[2]?.onPageHide();
    }
  }

  @Builder
  CardTab(item: TabItem) {
    Column() {
      Image(this.currentIndex === item.index ? item.imageActivated : item.imageOriginal)
        .width("21vp")
        .height("21vp")
        .objectFit(ImageFit.Contain)
        .margin({
          top: "4vp",
          bottom: "5.5vp"
        })
      Text(item.title)
        .fontSize("10fp")
        .fontColor(this.currentIndex === item.index ?
          "#007DFF" : "#66000000")
    }
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height("100%")
  }

  @Builder
  Content() {
    if (this.currentIndex === 0) {
      FlutterPage({ viewId: this.flutterEntries[0]?.getFlutterView()?.getId() })
    } else if (this.currentIndex === 1) {
      FlutterPage({ viewId: this.flutterEntries[1]?.getFlutterView()?.getId() })
    } else if (this.currentIndex === 2) {
      FlutterPage({ viewId: this.flutterEntries[2]?.getFlutterView()?.getId() })
    } else {
      Column() {
        Button('打开FlutterEntry')
          .onClick(() => {
            this.isOpaque = true;
            FlutterBoost.getInstance().open('flutterPage', {})
          })

        Button('打开透明FlutterEntry')
          .onClick(() => {
            this.isOpaque = false;
            FlutterBoost.getInstance().open('transparentWidget', {}, this.isOpaque)
          })
      }
    }
  }

  pageTransition() {
    if (this.isOpaque == false) {
      PageTransitionEnter({ type: RouteType.None, duration: 0 })
      PageTransitionExit({ type: RouteType.None, duration: 0 })
    }
  }
}