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
import FlutterBoostUtils from '../FlutterBoostUtils';

const TAG: string = "FlutterBoostEntry";

export class FlutterBoostRouteResult {
  constructor(result: Record<string, Object>) {
    this.result = result;
  }
  result: Record<string, Object> = {}
}

export default class FlutterBoostEntry extends FlutterEntry implements FlutterViewContainer {
  private uniqueId: string
  private isAttached: boolean = false
  private platformPlugin?: PlatformPlugin | null
  private stage?: LifecycleStage;
  private thisContext: Context;
  private routerOptions: ESObject;
  private isDialogMode: boolean;
  private routeStack: NavPathStack | null = null;
  private isStackPopping: boolean = false

  constructor(context: Context, routerOptions: ESObject = {}, isDialog: boolean = false) {
    super(context);

    this.thisContext = context;

    this.routerOptions = routerOptions;
    this.isDialogMode = isDialog;

    if (this.routerOptions && this.routerOptions.uniqueId) {
      //1、 当路由参数中的uniqueId不为null的时候，说明uniqueId已经由dart侧确定，因此直接获取
      this.uniqueId = this.routerOptions.uniqueId as string;
    } else {
      //2、 当路由参数中的uniqueId为null的时候，说明uniqueId需要由native侧生成，因此随机生成一个uniqueId
      const uniqueId = util.generateRandomUUID(false);
      this.uniqueId = uniqueId;
    }

    this.isAttached = false;

    this.stage = LifecycleStage.ON_CREATE;

    this.onContainerCreated();
  }

  private isTraceEnabled(): boolean {
    return FlutterBoostUtils.isDebugLoggingEnabled();
  }

  // 是否是当前栈顶页面（已打开）
  private isTopContainer(): boolean {
    return FlutterContainerManager.getInstance().getTopContainer() == this;
  }

  // 是否是历史栈中已经打开的页面
  private isActiveContainer(): boolean {
    return FlutterContainerManager.getInstance().isActiveContainer(this);
  }

  // override FlutterAbilityAndEntryDelegate ======start
  shouldAttachEngineToAbility(): boolean {
    return false;
  }

  getCachedEngineId(): string {
    return FlutterBoost.ENGINE_ID;
  }
  // override FlutterAbilityAndEntryDelegate ======end

  // override FlutterViewContainer interface ======start
  getUrl(): string {
    // 1 如果this.routerOptions 不为空，而且存在uri值，则取出来
    if (this.routerOptions && this.routerOptions.uri) {
      const uri = this.routerOptions.uri as string;
      return uri;
    } else {
      Log.e(TAG, 'Missing uri');
      return '';
    }
  }

  getUrlParams(): Record<string, Object> {
    if (this.routerOptions && this.routerOptions.params) {
      const params = this.routerOptions.params as Record<string, Object>;
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
    if (this.isTraceEnabled()) Log.d(TAG, "#finishContainer: " + this.getUrl());
    if (this.stage !== LifecycleStage.ON_FINISH) {
      this.routeStack ? this.routeStack.pop(new FlutterBoostRouteResult(result)) : router.back();
      this.stage = LifecycleStage.ON_FINISH;
      this.isStackPopping = true;
    } else {
      Log.e(TAG, 'finishContainer can not called twice!');
    }
  }

  isPopping(): boolean {
    return this.isStackPopping;
  }

  isOpaque(): boolean {
    return !this.isDialogMode;
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

  // override FlutterAbilityAndEntryDelegate ======start
  shouldDispatchAppLifecycleState(): boolean {
    return false;
  }

  attachToEngineAutomatically(): boolean {
    return false;
  }
  // override FlutterAbilityAndEntryDelegate ======end

  /**
   * 当容器创建完成时
   */
  private onContainerCreated(): void {
    Log.d(TAG, "#onContainerCreated");
    FlutterBoost.getInstance().getPlugin()?.onContainerCreated(this);
  }

  /**
   * 当容器出现时
   */
  private onContainerAppeared(): void {
    if (this.isTraceEnabled()) Log.d(TAG, "#onContainerAppeared: " + this.getUrl());
    // try to detach previous container from the engine.
    const top = FlutterContainerManager.getInstance().getTopContainer()
    if (top && top != this) top.detachFromEngineIfNeeded();

    // switch dart router
    FlutterBoost.getInstance().getPlugin()?.onContainerAppeared(this, () => {
      // attach XComponent
      this.attachToEngineIfNeeded();
      this.platformPlugin?.updateSystemUiOverlays();
    });
  }

  /**
   * 当容器消失时
   */
  private onContainerDisappeared(): void {
    if (this.isTraceEnabled()) Log.d(TAG, "#onContainerDisappeared: " + this.getUrl());
    FlutterBoost.getInstance().getPlugin()?.onContainerDisappeared(this);
  }

  /**
   * 当容器销毁时
   */
  private onContainerDestroy(): void {
    if (this.isTraceEnabled()) Log.d(TAG, "#onContainerDestroy: " + this.getUrl());
    this.detachFromEngineIfNeeded();
    FlutterBoost.getInstance().getPlugin()?.onContainerDestroyed(this);

    // NavDestinationMode.DIALOG：
    // 默认透明，进出页面栈不影响下层NavDestination的生命周期，不支持系统转场动画。
    if (this.isDialogMode) {
      // try to attach previous container from the engine.
      const top = FlutterContainerManager.getInstance().getTopContainer();
      if (top && top != this) top.attachToEngineIfNeeded();
    }
  }

  // super method override ===> start
  async aboutToAppear(): Promise<void> {
    if (this.isTraceEnabled()) Log.d(TAG, "#aboutToAppear");
    // Calls super method
    await super.aboutToAppear();

    this.stage = LifecycleStage.ON_ABOUT_TO_APPEAR;
  }

  aboutToDisappear(): void {
    if (this.isTraceEnabled()) Log.d(TAG, "#aboutToDisappear: " + this.getUrl());
    this.stage = LifecycleStage.ON_ABOUT_TO_DISAPPEAR;
    this.onContainerDestroy();

    // Calls super method
    super.aboutToDisappear();
  }

  onPageShow(): void { //生命周期
    // 在栈顶页面是透明弹窗的场景下，应用切换到后台，或者当前透明弹窗页面被Native页面遮挡时，
    // 不切换引擎和路由
    const top = FlutterContainerManager.getInstance().getTopContainer()
    if (this.isActiveContainer() && !this.isTopContainer() && !top!.isPopping()
      || this.isTopContainer() && !this.isOpaque()) {
      return;
    }
    if (this.isTraceEnabled()) Log.d(TAG, "#onPageShow: " + this.getUrl());
    // Calls super method
    super.onPageShow();

    this.stage = LifecycleStage.ON_SHOW;
    this.onContainerAppeared();
  }

  onPageHide(): void { //生命周期
    // 在栈顶页面是透明弹窗的场景下，应用切换到后台，或者当前透明弹窗页面被Native页面遮挡时，
    // 不切换引擎和路由
    if (this.isActiveContainer() && !this.isTopContainer()
      || this.isTopContainer() && !this.isOpaque()) {
      return;
    }
    if (this.isTraceEnabled()) Log.d(TAG, "#onPageHide: " + this.getUrl());
    this.stage = LifecycleStage.ON_HIDE;
    this.onContainerDisappeared();

    // Calls super method
    super.onPageHide();
  }

  // Intercept the user's press of the back key.
  onBackPress() {
    if (this.isTraceEnabled()) Log.d(TAG, "#onBackPress: " + this.getUrl());
    this.onBackPressed();
  }
  // super method override ===> end

  // 对于非Tab的情况，当NavDestination即将构建子组件之前会触发此回调
  onReady(routeStack: NavPathStack): void {
    this.routeStack = routeStack;
    if (this.isTraceEnabled()) Log.d(TAG, "#onReady: " + this.getUrl());
  }

  // 当该NavDestination页面显示时触发此回调
  onShown(): void {
    if (this.isTraceEnabled()) Log.d(TAG, "#onShown: " + this.getUrl());
    this.onPageShow();
  }

  // 当该NavDestination页面隐藏时触发此回调
  onHidden(): void {
    if (this.isTraceEnabled()) Log.d(TAG, "#onHidden: " + this.getUrl());
    this.onPageHide();
  }

  // 当与Navigation绑定的页面栈中存在内容时，此回调生效。当点击返回键时，触发该回调
  // 返回值为true时，表示重写返回键逻辑，返回值为false时，表示回退到上一个页面
  onBackPressed(): boolean {
    if (this.isTraceEnabled()) Log.d(TAG, "#onBackPressed: " + this.getUrl());
    FlutterBoost.getInstance().getPlugin()?.onBackPressed();
    return true;
  }


  // private methods ==> start
  /**
   * 绑定
   */
  private performAttach(): void {
    if (this.isTraceEnabled()) Log.d(TAG, "#performAttach: " + this.getUrl());
    // 1.plugin attach
    const exclusiveAppComponent = this.getExclusiveAppComponent();
    if (exclusiveAppComponent) {
      this.getFlutterEngine()?.getAbilityControlSurface()?.attachToAbility(exclusiveAppComponent);
    }

    // 2.Ability attach
    this.getFlutterView().attachToFlutterEngine(this.getFlutterEngine()!);

    if (!this.platformPlugin) {
      this.platformPlugin = new PlatformPlugin(this.getFlutterEngine()!.getPlatformChannel()!, this.thisContext);
    }
  }

  /**
   * 解绑
   */
  private performDetach(): void {
    if (this.isTraceEnabled()) Log.d(TAG, "#performDetach: " + this.getUrl());
    // Plugins are no longer attached to the activity.
    this.getFlutterEngine()?.getAbilityControlSurface()?.detachFromAbility();

    // Release Flutter's control of UI such as system chrome.
    this.releasePlatformChannel();

    // Detach rendering pipeline.
    this.getFlutterView().detachFromFlutterEngine();
  }

  private releasePlatformChannel(): void {
    if (this.platformPlugin) {
      this.platformPlugin.destroy();
      this.platformPlugin = null;
    }
  }
}