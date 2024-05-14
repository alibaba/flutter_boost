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
  private randomUniqueId: string
  private isAttached: boolean = false
  private platformPlugin?: PlatformPlugin | null
  private stage?: LifecycleStage;
  private thisContext: Context;
  private thisParams: ESObject;
  private isDialogMode: boolean;
  private routeStack: NavPathStack | null = null;

  constructor(context: Context, params: ESObject = {}, isDialog: boolean = false) {
    super(context, params);

    this.thisContext = context;
    // 该变量需要是上一个页面传过来的路由参数，但是此时还无效，需要到onReady的时候才能拿到真正有效的路由参数
    this.thisParams = params;
    this.isDialogMode = isDialog;
    
    const randomUniqueId = util.generateRandomUUID(false);
    this.randomUniqueId = randomUniqueId;
    this.isAttached = false;

    this.stage = LifecycleStage.ON_CREATE;

    // 对container的create需要放到onReady里面执行，因为上一个页面执行push操作所传的路由参数需要在onReady后才有效
    //this.onContainerCreated();
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
    if(this.thisParams && this.thisParams.uniqueId){
      let uniqueId:string = this.thisParams.uniqueId as string;
      let tmpStr:string = '';
      if(uniqueId === tmpStr){
         uniqueId = this.randomUniqueId;
      }
      const finalUniqueId = uniqueId as string;
      return finalUniqueId!;
    }else {
      const uniqueId = this.randomUniqueId;
      return uniqueId!;
    }
  }

  finishContainer(result: Record<string, Object>) {
    Log.d(TAG, "#finishContainer: " + this.getUrl());
    if (this.stage !== LifecycleStage.ON_FINISH) {
      this.routeStack ? this.routeStack.pop() : router.back();
      this.stage = LifecycleStage.ON_FINISH;
    } else {
      Log.e(TAG, 'finishContainer can not called twice!');
    }
  }

  isPausing(): boolean {
    throw new Error('Method not implemented.');
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

  shouldDispatchAppLifecycleState(): boolean {
    return false;
  }

  attachToEngineAutomatically(): boolean {
    return false;
  }

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
    Log.d(TAG, "#onContainerAppeared: " + this.getUrl());
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
    Log.d(TAG, "#onContainerDisappeared: " + this.getUrl());
    FlutterBoost.getInstance().getPlugin()?.onContainerDisappeared(this);
  }

  /**
   * 当容器销毁时
   */
  private onContainerDestroy(): void {
    Log.d(TAG, "#onContainerDestroy: " + this.getUrl());
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
    Log.d(TAG, "#aboutToAppear");
    // Calls super method
    await super.aboutToAppear();

    this.stage = LifecycleStage.ON_ABOUT_TO_APPEAR;
  }

  aboutToDisappear(): void {
    Log.d(TAG, "#aboutToDisappear: " + this.getUrl());
    this.stage = LifecycleStage.ON_ABOUT_TO_DISAPPEAR;
    this.onContainerDestroy();

    // Calls super method
    super.aboutToDisappear();
  }

  onPageShow(): void { //生命周期
    Log.d(TAG, "#onPageShow: " + this.getUrl());
    // Calls super method
    super.onPageShow();

    this.stage = LifecycleStage.ON_SHOW;
    this.onContainerAppeared();
  }

  onPageHide(): void { //生命周期
    Log.d(TAG, "#onPageHide: " + this.getUrl());
    this.stage = LifecycleStage.ON_HIDE;
    this.onContainerDisappeared();

    // Calls super method
    super.onPageHide();
  }

  // Intercept the user's press of the back key.
  onBackPress() {
    Log.d(TAG, "#onBackPress: " + this.getUrl());
    this.onBackPressed();
  }
  // super method override ===> end

  // 当NavDestination即将构建子组件之前会触发此回调
  onReady(routeStack: NavPathStack, params: ESObject): void {
    this.routeStack = routeStack;
    //对此变量进行重新赋值，此次赋值之后该变量就是完全有效的路由参数了
    this.thisParams = params;
    Log.d(TAG, "#onReady: " + this.getUrl());
    //执行container的create
    this.onContainerCreated();
  }

  // 当该NavDestination页面显示时触发此回调
  onShown(): void {
    Log.d(TAG, "#onShown: " + this.getUrl());
    this.onPageShow();
  }

  // 当该NavDestination页面隐藏时触发此回调
  onHidden(): void {
    Log.d(TAG, "#onHidden: " + this.getUrl());
    this.onPageHide();
  }

  // 当与Navigation绑定的页面栈中存在内容时，此回调生效。当点击返回键时，触发该回调
  // 返回值为true时，表示重写返回键逻辑，返回值为false时，表示回退到上一个页面
  onBackPressed(): boolean {
    Log.d(TAG, "#onBackPressed: " + this.getUrl());
    FlutterBoost.getInstance().getPlugin()?.onBackPressed();
    return true;
  }


  // private methods ==> start
  /**
   * 绑定
   */
  private performAttach(): void {
    Log.d(TAG, "#performAttach: " + this.getUrl());
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
    Log.d(TAG, "#performDetach: " + this.getUrl());
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