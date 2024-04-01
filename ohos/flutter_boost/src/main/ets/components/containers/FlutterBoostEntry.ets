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

import { FlutterEntry, PlatformPlugin, } from '@ohos/flutter_ohos';
import { FlutterViewContainer } from './FlutterViewContainer';
import { LifecycleStage } from './Lifecycle';
import util from '@ohos.util';
import Log from '../util/Log';
import { FlutterBoost } from '../FlutterBoost';
import FlutterContainerManager from './FlutterContainerManager';
import router from '@ohos.router';

const TAG: string = "FlutterBoostEntry";

export default class FlutterBoostEntry extends FlutterEntry implements FlutterViewContainer {
  private uniqueId: string
  private isAttached: boolean = false
  private platformPlugin?: PlatformPlugin | null
  private stage?: LifecycleStage;
  private thisContext: Context;
  private thisParams: ESObject;
  private isFirstAttached: boolean = true;

  constructor(context: Context, params: ESObject = {}) {
    super(context, params);

    this.thisParams = params;
    this.thisContext = context;

    const uniqueId = util.generateRandomUUID(false);
    this.uniqueId = uniqueId;
    if(params.uniqueId !=null && params.uniqueId !=''){
      this.uniqueId = params.uniqueId;
    }
    this.isAttached = false;
    this.isFirstAttached = true;

    this.stage = LifecycleStage.ON_CREATE;
    this.onContainerCreated();
  }

  // override FlutterAbilityAndEntryDelegate ======start
  getCachedEngineId(): string {
    return FlutterBoost.ENGINE_ID;
  }

  // override FlutterAbilityAndEntryDelegate ======end

  // override FlutterViewContainer interface ======start
  getUrl(): string {
    // 1 如果this.thisParams 不为空，而且存在uri值，则取出来
    if (this.thisParams && this.thisParams.uri) {
      const uri = this.thisParams.uri as string;
      return uri;
    } else {
      Log.e(TAG, 'Missing uri');
      return '';
    }
  }

  getUrlParams(): Record<string, Object> {
    if (this.thisParams && this.thisParams.params) {
      const params = this.thisParams.params as Record<string, Object>;
      return params;
    } else {
      Log.e(TAG, 'Missing params')
      return {};
    }
  }

  getUniqueId(): string {
    return this.uniqueId!;
  }

  finishContainer(result: Record<string, Object>) {
    if (this.stage !== LifecycleStage.ON_FINISH) {
      router.back();
      this.stage = LifecycleStage.ON_FINISH;
    } else {
      Log.e(TAG, 'finishContainer can not called twice!');
    }
  }

  isPausing(): boolean {
    throw new Error('Method not implemented.');
  }

  isOpaque(): boolean {
    throw new Error('Method not implemented.');
  }

  detachFromEngineIfNeeded(): void {
    if (this.isAttached) {
      this.performDetach();
      this.isAttached = false;
    }
  }

  attachToEngineIfNeeded(): void {
    if (!this.isAttached) {
      this.performAttach();
      this.isAttached = true;
    }
  }

  getState(): LifecycleStage {
    throw new Error('Method not implemented.');
  }

  paramsForDisappear?(): Record<string, Object> {
    return {};
  }

  // override FlutterViewContainer interface ====== end

  shouldDispatchAppLifecycleState(): boolean {
    return false;
  }

  // Avoid failure when attaching to engine in tab scenario
  // See https://github.com/flutter/engine/pull/43595 for more details
  EnsureEngineDetachedForTheFirstTime(): void {
    if (this.isFirstAttached) {
      this.getFlutterView()?.detachFromFlutterEngine();
      this.isFirstAttached = false;
    }
  }

  /**
   * 当容器创建完成时
   */
  private onContainerCreated(): void {
    FlutterBoost.getInstance().getPlugin()?.onContainerCreated(this);
    Log.d(TAG, "#onContainerCreated: " + this.getUrl());
  }

  /**
   * 当容器出现时
   */
  private onContainerAppeared(): void {
    // try to detach previous container from the engine.
    const top = FlutterContainerManager.getInstance().getTopContainer()
    if (top && top != this) top.detachFromEngineIfNeeded();

    this.EnsureEngineDetachedForTheFirstTime();
    // switch dart router
    FlutterBoost.getInstance().getPlugin()?.onContainerAppeared(this, () => {
      // attach XComponent
      this.attachToEngineIfNeeded();
      this.platformPlugin?.updateSystemUiOverlays();
    });
    Log.d(TAG, "#onContainerAppeared: " + this.getUrl());
  }

  /**
   * 当容器消失时
   */
  private onContainerDisappeared(): void {
    FlutterBoost.getInstance().getPlugin()?.onContainerDisappeared(this);
    Log.d(TAG, "#onContainerDisappeared: " + this.getUrl());
  }

  /**
   * 当容器销毁时
   */
  private onContainerDestroy(): void {
    this.detachFromEngineIfNeeded();
    FlutterBoost.getInstance().getPlugin()?.onContainerDestroyed(this);
    Log.d(TAG, "#onContainerDisappeared: " + this.getUrl());
  }

  // super method override ===> start
  async aboutToAppear(): Promise<void> {
    this.stage = LifecycleStage.ON_ABOUT_TO_APPEAR;
    await super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    this.stage = LifecycleStage.ON_ABOUT_TO_DISAPPEAR;
    this.onContainerDestroy();
  }

  onPageShow(): void { //生命周期
    super.onPageShow();
    this.stage = LifecycleStage.ON_SHOW;
    this.onContainerAppeared();
  }

  onPageHide(): void { //生命周期
    super.onPageHide();
    this.stage = LifecycleStage.ON_HIDE;
    this.onContainerDisappeared();
  }

  // super method override ===> end


  // private methods ==> start
  /**
   * 绑定
   */
  private performAttach(): void {
    // 1.plugin attach
    const exclusiveAppComponent = this.getExclusiveAppComponent();
    if (exclusiveAppComponent) {
      this.getFlutterEngine()?.getAbilityControlSurface()?.attachToAbility(exclusiveAppComponent);
    }

    // 2.Ability attach
    this.getFlutterView()?.attachToFlutterEngine(this.getFlutterEngine()!);

    if (!this.platformPlugin) {
      this.platformPlugin = new PlatformPlugin(this.getFlutterEngine()!.getPlatformChannel()!, this.thisContext);
    }
    Log.d(TAG, "#performAttach: " + this.getUrl());
  }

  /**
   * 解绑
   */
  private performDetach(): void {
    // Plugins are no longer attached to the activity.
    this.getFlutterEngine()?.getAbilityControlSurface()?.detachFromAbility();

    // Release Flutter's control of UI such as system chrome.
    this.releasePlatformChannel();

    // Detach rendering pipeline.
    this.getFlutterView()?.detachFromFlutterEngine();
    Log.d(TAG, "#performDetach: " + this.getUrl());
  }

  private releasePlatformChannel(): void {
    if (this.platformPlugin) {
      this.platformPlugin.destroy();
      this.platformPlugin = null;
    }
  }
}