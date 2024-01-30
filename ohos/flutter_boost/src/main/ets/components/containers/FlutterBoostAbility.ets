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

import { FlutterAbility } from '@ohos/flutter_ohos/src/main/ets/embedding/ohos/FlutterAbility';
import PlatformPlugin from '@ohos/flutter_ohos/src/main/ets/plugin/PlatformPlugin';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { FlutterBoost } from '../FlutterBoost';
import { FlutterViewContainer } from './FlutterViewContainer';
import { LifecycleStage } from './Lifecycle';
import window from '@ohos.window';
import FlutterBoostAbilityLaunchConfigs from './FlutterBoostAbilityLaunchConfigs';
import util from '@ohos.util';
import Log from '../util/Log';
import FlutterContainerManager from './FlutterContainerManager';

const TAG = "FlutterBoostAbility";
const EVENT_BACK_PRESS = 'EVENT_BACK_PRESS';

/**
 * FlutterBoostAbility类
 */
export default class FlutterBoostAbility extends FlutterAbility implements FlutterViewContainer {
  private isAttached?: boolean = false
  private want?: Want
  private uniqueId?: string
  private platformPlugin?: PlatformPlugin | null
  private stage?: LifecycleStage;

  // override UIAbility Lifecycle method === start
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.want = want

    const uniqueId = this.want?.parameters?.[FlutterBoostAbilityLaunchConfigs.EXTRA_UNIQUE_ID] as string || util.generateRandomUUID(false);
    this.uniqueId = uniqueId;

    await super.onCreate(want, launchParam)

    this.onContainerCreated()

    this.context.eventHub.on(EVENT_BACK_PRESS, () => {
      FlutterBoost.getInstance().getPlugin()?.onBackPressed();
      Log.d(TAG, "#onBackPressed: " + this);
    })
  }

  onDestroy() {
    this.onContainerDestroy()
  }

  async onWindowStageCreate(windowStage: window.WindowStage) {
    super.onWindowStageCreate(windowStage);
    try {
      windowStage?.on('windowStageEvent', (data) => {
        let stageEventType: window.WindowStageEventType = data;
        switch (stageEventType) {
          case window.WindowStageEventType.SHOWN: // 切到前台
            Log.i(TAG, 'windowStage foreground.');
            break;
          case window.WindowStageEventType.ACTIVE: // 获焦状态
            Log.i(TAG, 'windowStage active.');
            this.onContainerAppeared()
            break;
          case window.WindowStageEventType.INACTIVE: // 失焦状态
            Log.i(TAG, 'windowStage inactive.');
            break;
          case window.WindowStageEventType.HIDDEN: // 切到后台
            Log.i(TAG, 'windowStage background.');
            this.onContainerDisappeared()
            break;
          default:
            break;
        }
      });

    } catch (exception) {
      Log.e(TAG, 'Failed to enable the listener for window stage event changes. Cause:' + JSON.stringify(exception));
    }
  }

  onForeground() {
    super.onForeground()
  }

  onBackground() {
    super.onBackground()
  }

  shouldDestroyEngineWithHost(): boolean {
    return false;
  }

  shouldAttachEngineToActivity(): boolean {
    return false;
  }

  // override UIAbility === end

  // override FlutterViewContainer interface ======start
  getUrl(): string {
    if (this.want?.uri) {
      return this.want?.uri
    } else {
      Log.w(TAG, "want.url has not specify!");
      return ''
    }
  }

  getUrlParams(): Record<string, Object> {
    return this.want?.parameters ? this.want.parameters : {}
  }

  // override FlutterViewContainer interface
  getUniqueId(): string {
    return this.uniqueId!
  }

  // override FlutterViewContainer interface
  finishContainer(result: Record<string, Object>) {
    this.context.terminateSelf();
  }

  isPausing(): boolean {
    throw new Error('Method not implemented.');
  }

  isOpaque(): boolean {
    throw new Error('Method not implemented.');
  }

  detachFromEngineIfNeeded() {
    this.performDetach()
  }

  getState(): LifecycleStage {
    throw new Error('Method not implemented.');
  }

  paramsForDisappear?(): Record<string, Object> | null {
    return null;
  }

  // override FlutterViewContainer interface ======End

  // override FlutterAbilityDelegate
  getCachedEngineId(): string {
    return FlutterBoost.ENGINE_ID
  }

  /**
   * 当容器创建完成时
   */
  private onContainerCreated() {
    this.stage = LifecycleStage.ON_CREATE;

    // TODO:待补齐
    // this.getFlutterView()?.detachFromFlutterEngine(); // Avoid failure when attaching to engine in |onResume|.
    FlutterBoost.getInstance().getPlugin()?.onContainerCreated(this);

    Log.d(TAG, "#onContainerCreated: " + this);
  }

  /**
   * 当容器出现时
   */
  private onContainerAppeared() {
    // try to detach previous container from the engine.
    const top = FlutterContainerManager.getInstance().getTopContainer()
    if (top && top != this) top.detachFromEngineIfNeeded()

    // perform attach
    this.performAttach()
    FlutterBoost.getInstance().getPlugin()?.onContainerAppeared(this)

    this.getFlutterEngine()?.getLifecycleChannel()?.appIsResumed()
    this.platformPlugin?.updateSystemUiOverlays()
    //
    Log.d(TAG, "#onContainerAppeared: " + this);
  }

  /**
   * 当容器消失时
   */
  private onContainerDisappeared() {
    FlutterBoost.getInstance().getPlugin()?.onContainerDisappeared(this);
    Log.d(TAG, "#onContainerDisappeared: " + this);
  }

  /**
   * 当容器销毁时
   */
  private onContainerDestroy() {
    this.detachFromEngineIfNeeded()
    const engine = this.getFlutterEngine()
    if (engine) {
      engine!.getLifecycleChannel()?.appIsResumed(); // Go after |super.onDestroy|.
    } else {
      Log.e(TAG, "#onContainerDisappeared: engine can not null!");
    }
    FlutterBoost.getInstance().getPlugin()?.onContainerDestroyed(this);
    Log.d(TAG, "#onContainerDisappeared: " + this);
  }

  // private methods ==> start
  /**
   * 绑定
   */
  private performAttach() {
    if (!this.isAttached) {

      // 1.plugin attach
      const exclusiveAppComponent = this.getExclusiveAppComponent()
      if (exclusiveAppComponent) {
        this.getFlutterEngine()?.getAbilityControlSurface()?.attachToAbility(exclusiveAppComponent)
      }

      // 2.Ability attach
      this.getFlutterView()?.attachToFlutterEngine(this.getFlutterEngine()!);

      if (!this.platformPlugin) {
        this.platformPlugin = new PlatformPlugin(this.getFlutterEngine()!.getPlatformChannel()!, this.context);
      }

      Log.d(TAG, "#performAttach: " + this);
      this.isAttached = true
    }
  }

  /**
   * 解绑
   */
  private performDetach() {
    if (this.isAttached) {
      // Plugins are no longer attached to the activity.
      this.getFlutterEngine()?.getAbilityControlSurface()?.detachFromAbility()

      // Release Flutter's control of UI such as system chrome.
      this.releasePlatformChannel()

      // Detach rendering pipeline.
      this.getFlutterView()?.detachFromFlutterEngine();

      this.isAttached = false
      Log.d(TAG, "#performDetach: " + this);
    }
  }

  private releasePlatformChannel() {
    if (this.platformPlugin) {
      this.platformPlugin.destroy();
      this.platformPlugin = null;
    }
  }
}