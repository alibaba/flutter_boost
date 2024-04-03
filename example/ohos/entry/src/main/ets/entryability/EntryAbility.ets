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
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import hilog from '@ohos.hilog';
import {
  FlutterBoost,
  FlutterBoostDelegate,
  FlutterBoostRouteOptions,
  FlutterBoostAbility,
  FlutterBoostSetupOptions,
  FlutterBoostSetupOptionsBuilder
} from '@ohos/flutter_boost';
import FlutterManager from '@ohos/flutter_ohos/src/main/ets/embedding/ohos/FlutterManager';

import router from '@ohos.router';

export default class EntryAbility extends UIAbility implements FlutterBoostDelegate {
  // 打开原生
  pushNativeRoute(options: FlutterBoostRouteOptions) {
    router.pushUrl({ url: 'pages/NativePage' })
  }

  // 打开flutter
  pushFlutterRoute(options: FlutterBoostRouteOptions) {
    let pageName: string = 'pages/MyFlutterPage'
    if (options.isOpaque() == false) {
      pageName = 'pages/MyTransparentFlutterPage'
    }

    router.pushUrl({
      url: pageName, params: {
        uri: options.getPageName(),
        params: options.getArguments(),
      }
    }).then(() => {
      console.info('Succeeded in jumping to the second page.')
    })
  }

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    FlutterManager.getInstance().pushUIAbility(this)
  }

  onDestroy(): void {
    FlutterManager.getInstance().popUIAbility(this)
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    FlutterManager.getInstance().pushWindowStage(this, windowStage)

    const optionsBuilder: FlutterBoostSetupOptionsBuilder = new FlutterBoostSetupOptionsBuilder()
      .setShellArgs(['--trace-systrace', '--user-authorization-code=QZvoUptODA+KDgeFUluhheYns7X7CnDu9YRv8YmU0GXQcKLzs4C2WgjblrAIhtkqqGg=='])
      .setDartEntrypointArgs(['I am from ohos!', '--for-test'])
      .setPlugins(GeneratedPluginRegistrant.getPlugins())

    FlutterBoost.getInstance().setup(this, this.context, () => {
      hilog.info(0x0000, 'testTag', '%{public}s', '引擎初始化成功');

      windowStage.loadContent('pages/EntryPage', (err, data) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
      });

    }, optionsBuilder.build())
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');


  }

  onWindowStageDestroy(): void {
    FlutterManager.getInstance().popWindowStage(this)
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}