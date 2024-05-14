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
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import hilog from '@ohos.hilog';
import {
  FlutterBoost,
  FlutterBoostDelegate,
  FlutterBoostRouteOptions,
  FlutterBoostSetupOptionsBuilder
} from 'flutter_boost';
import { FlutterManager} from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { RouterModule, RouterOptions } from '../router/RouterModule';
import { RouterNameConstants } from '../constants/RouterConstants';
import { SimpleTextViewFactory } from '../platform_view/SimpleTextViewFactory';

const TAG: string = "EntryAbility";
export default class EntryAbility extends UIAbility implements FlutterBoostDelegate {
  // 打开原生页面
  pushNativeRoute(options: FlutterBoostRouteOptions) {
    RouterModule.push(RouterNameConstants.NATIVE_PAGE)
  }

  // 打开flutter页面
  pushFlutterRoute(options: FlutterBoostRouteOptions) {
    let routerName: string = RouterNameConstants.FLUTTER_PAGE
    if (!options.isOpaque()) {
      routerName = RouterNameConstants.FLUTTER_DIALOG
    }

    RouterModule.push(routerName, new RouterOptions(options.getPageName(),
      options.getArguments(),
      options.getUniqueId()));
  }

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onCreate');
    FlutterManager.getInstance().pushUIAbility(this)
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onDestroy');
    FlutterManager.getInstance().popUIAbility(this)
  }

  // Main window is created, set main page for this ability
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageCreate');
    FlutterManager.getInstance().pushWindowStage(this, windowStage)

    const optionsBuilder: FlutterBoostSetupOptionsBuilder = new FlutterBoostSetupOptionsBuilder()
      .setShellArgs(['--trace-systrace', '--user-authorization-code=QZvoUptODA+KDgeFUluhheYns7X7CnDu9YRv8YmU0GXQcKLzs4C2WgjblrAIhtkqqGg=='])
      .setDartEntrypointArgs(['I am from ohos!', '--for-test'])

    FlutterBoost.getInstance().setup(this, this.context, (engine) => {
      hilog.info(0x0000, TAG, '%{public}s', '引擎初始化成功');

      // Register plugins
      GeneratedPluginRegistrant.registerWith(engine)

      // Register platform views
      engine.getPlatformViewsController()?.getRegistry()
        .registerViewFactory('<simple-text-view>', new SimpleTextViewFactory());

      windowStage.loadContent('pages/EntryPage', (err, data) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }

        hilog.info(0x0000, TAG, 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
        let windowClass: window.Window = windowStage.getMainWindowSync();
        windowClass.setWindowLayoutFullScreen(true)
          .then(() => {
            console.info('Succeeded in setting the window layout to full-screen mode.');
          })
          .catch((err: BusinessError) => {
            console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
          });

          let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
          let bottomRectHeight = avoidArea.bottomRect.height; // 获取到导航条区域的高度
          AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);
      });
    }, optionsBuilder.build())
  }

  // Main window is destroyed, release UI related resources
  onWindowStageDestroy(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageDestroy');
    FlutterManager.getInstance().popWindowStage(this)
  }

  // Ability has brought to foreground
  onForeground(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onForeground');
  }

  // Ability has back to background
  onBackground(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onBackground');
  }
}