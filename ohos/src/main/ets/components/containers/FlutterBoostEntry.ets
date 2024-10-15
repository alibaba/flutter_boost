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
import { common } from '@kit.AbilityKit';
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

export default class FlutterBoostEntry extends FlutterEntry implements FlutterViewContainer {
  private uniqueId: string
  private isAttached: boolean = false
  private platformPlugin?: PlatformPlugin | null
  private stage?: LifecycleStage;
  private thisContext: common.UIAbilityContext;
  private routerOptions: ESObject;
  private isDialogMode: boolean;
  private routeStack: NavPathStack | null = null;
  private isStackPopping: boolean = false
  private onPopCallback?: (result: Record<string, Object>) => void;

  constructor(context: common.UIAbilityContext, routerOptions: ESObject, isDialog?: boolean, onPop?: (result: Record<string, Object>) => void) {
    super(context);

    this.thisContext = context;

    this.routerOptions = routerOptions;
    this.isDialogMode = isDialog ?? false;
    this.onPopCallback = onPop;

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
      if (this.onPopCallback) {
        this.onPopCallback(result);
      } else {
        this.routeStack ? this.routeStack.pop(result) : router.back();
      }
      this.isStackPopping = true;
      this.stage = LifecycleStage.ON_FINISH;
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
    FlutterBoost.getInstance().getPlugin()?.onContainerDestroyed(this, () => {
      // NavDestinationMode.DIALOG：
      // 默认透明，进出页面栈不影响下层NavDestination的生命周期，不支持系统转场动画。
      if (this.isDialogMode) {
        // try to attach previous container from the engine.
        const top = FlutterContainerManager.getInstance().getTopContainer();
        if (top && top != this) top.attachToEngineIfNeeded();
      }
    });
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
    if (this.isUnderDialogPage()) return;
    if (this.isTraceEnabled()) Log.d(TAG, "#onPageShow: " + this.getUrl());

    // Calls super method
    super.onPageShow();

    this.stage = LifecycleStage.ON_SHOW;
    this.onContainerAppeared();
  }

  onPageHide(): void { //生命周期
    if (this.isUnderDialogPage()) return;
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
    // 1. plugin attach
    const exclusiveAppComponent = this.getExclusiveAppComponent();
    if (exclusiveAppComponent) {
      this.getFlutterEngine()?.getAbilityControlSurface()?.attachToAbility(exclusiveAppComponent);
    }

    // 2. Ability attach
    this.getFlutterView().attachToFlutterEngine(this.getFlutterEngine()!);

    // Create |PlatformPlugin|
    this.createPlatformPlugin();
  }

  /**
   * 解绑
   */
  private performDetach(): void {
    if (this.isTraceEnabled()) Log.d(TAG, "#performDetach: " + this.getUrl());
    // Plugins are no longer attached to the activity.
    this.getFlutterEngine()?.getAbilityControlSurface()?.detachFromAbility();

    // Release Flutter's control of UI such as system chrome.
    this.releasePlatformPlugin();

    // Detach rendering pipeline.
    this.getFlutterView().detachFromFlutterEngine();
  }

  private createPlatformPlugin(): void {
    if (!this.platformPlugin) {
      this.platformPlugin = this.providePlatformPlugin(this.getFlutterEngine()!);
      this.platformPlugin?.initWindow();
    }
  }

  private releasePlatformPlugin(): void {
    if (this.platformPlugin) {
      this.platformPlugin.destroy();
      this.platformPlugin = null;
    }
  }

  private isUnderDialogPage(): boolean {
    //进入onPageShow有四种情况: 1、打开新页面 2、从别的页面pop返回 3、tab场景下从别的tab跳转 4、从后台切回前台
    //topContainerOfThis指的是曾经从当前container打开或者跳转的container
    //对于第1种情况，topContainerOfThis为null；
    //对于第2种情况，topContainerOfThis是dialog，或者由于在执行当前页面的onPageShow时，topContainerOfThis还没有destroy，所以能够准确获取到；
    //对于第3种情况，和第2种情况类似，只是topContainerOfThis后续不会被destroy，并且从实际业务出发，topContainerOfThis不会是dialog；
    //对于第4种情况，topContainerOfThis为null或者是dialog。
    //onPageHide情况和opPageShow对称
    const topContainerOfThis = FlutterContainerManager.getInstance().getTopContainerOfThis(this);
    if (topContainerOfThis && !topContainerOfThis.isOpaque()) return true;
    else return false;
  }
}