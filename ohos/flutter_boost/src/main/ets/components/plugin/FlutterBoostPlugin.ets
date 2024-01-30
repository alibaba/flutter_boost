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

import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { FlutterViewContainer } from '../containers/FlutterViewContainer';
import FlutterContainerManager from '../containers/FlutterContainerManager';
import FlutterEngine from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngine';
import { FlutterBoost } from '../FlutterBoost';
import FlutterRouterApi from '../messages/FlutterRouterApi';
import NativeRouterApi, { NativeRouterApiSetup } from '../messages/NativeRouterApi';
import FlutterBoostDelegate from '../FlutterBoostDelegate';
import CommonParams from '../messages/CommonParams';
import Log from '../util/Log'
import StackInfo from '../messages/StackInfo';
import FlutterBoostRouteOptions, { FlutterBoostRouteOptionsBuilder } from '../FlutterBoostRouteOptions';
import EventListener from '../util/EventListener';
import ListenerRemover from '../util/ListenerRemover';

const TAG = 'FlutterBoostPlugin'

/**
 * FlutterBoostPlugin插件类。
 */
export class FlutterBoostPlugin implements FlutterPlugin, MethodCallHandler, NativeRouterApi {
  public static className = 'FlutterBoostPlugin'
  private channel: FlutterRouterApi | null // 发送到dart
  private engine: FlutterEngine | null
  private delegate: FlutterBoostDelegate | null
  private requestCode: number = 1000;
  private pageNames: Map<number, string>
  private dartStack?: StackInfo
  private listenersTable: Record<string, EventListener[]> = {};

  constructor() {
    this.engine = null
    this.delegate = null
    this.channel = null
    this.pageNames = new Map<number, string>()
  }

  onMethodCall(call: MethodCall, result: MethodResult) {
    throw new Error('Method not implemented.');
  }

  // override FlutterPlugin interface ==> start
  getUniqueClassName(): string {
    return FlutterBoostPlugin.className
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.engine = binding.getFlutterEngine()
    this.channel = new FlutterRouterApi(binding.getBinaryMessenger())
    NativeRouterApiSetup(binding.getBinaryMessenger(), this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.engine = null
    this.channel = null
  }

  // override FlutterPlugin interface ==> end

  // NativeRouterApi override ==> start
  onPushNativeRoute(params: CommonParams) {
    if (this.delegate) {
      this.requestCode++;
      if (this.pageNames && params.pageName) {
        this.pageNames.set(this.requestCode, params.pageName)
      }
      const builder = new FlutterBoostRouteOptionsBuilder()
      if (params.pageName) {
        builder.setPageName(params.pageName)
      }
      if (params.arguments) {
        builder.setArguments(params.arguments)
      }
      builder.setRequestCode(this.requestCode)
      this.delegate.pushNativeRoute(builder.build());
    } else {
      throw new Error("FlutterBoostPlugin might *NOT* set delegate!");
    }
  }

  onPushFlutterRoute(params: CommonParams) {
    if (this.delegate) {
      const builder = new FlutterBoostRouteOptionsBuilder()
      if (params.pageName) {
        builder.setPageName(params.pageName)
      }
      if (params.arguments) {
        builder.setArguments(params.arguments)
      }
      if (params.opaque) {
        builder.setOpaque(params.opaque)
      }
      builder.setRequestCode(this.requestCode)
      this.delegate.pushFlutterRoute(builder.build());
    } else {
      throw new Error("FlutterBoostPlugin might *NOT* set delegate!");
    }
  }

  onPopRoute(params: CommonParams, completion: () => void) {
    const uniqueId = params.uniqueId
    if (uniqueId && uniqueId.length > 0) {
      const container = FlutterContainerManager.getInstance().findContainerById(uniqueId);
      if (container) {
        container.finishContainer(params.arguments ? params.arguments : {})
        completion();
      } else {
        throw new Error("Oops!! Can not find the page. uniqueId:" + uniqueId);
      }
    } else {
      throw new Error("Oops!! The unique id is undefined!");
    }
  }

  onGetStackFromHost(): StackInfo {
    if (!this.dartStack) {
      return StackInfo.fromObject(new Object());
    }
    Log.i(TAG, "#getStackFromHost: " + this.dartStack)
    return this.dartStack
  }

  onSaveStackToHost(arg: StackInfo) {
    this.dartStack = arg;
    Log.i(TAG, "#saveStackToHost: " + this.dartStack);
  }

  onSendEventToNative(params: CommonParams) {
    // 处理来自 Flutter 侧的事件
    const key = params.key
    let args: Record<string, Object> = params.arguments ? params.arguments : {}
    if (!key) {
      throw new Error("Key cannot be null");
    }
    if (!arguments) {
      args = {} // 使用空对象代替 HashMap
    }
    const listeners = this.listenersTable[key];
    if (!listeners) {
      return;
    }
    listeners.forEach((listener) => {
      listener.onEvent(key, args);
    });
  }

  // NativeRouterApi override ==> end

  // public method
  public getChannel(): FlutterRouterApi | null {
    return this.channel
  }

  // public method
  public setDelegate(delegate: FlutterBoostDelegate) {
    this.delegate = delegate;
  }

  // public method
  public getDelegate(): FlutterBoostDelegate | null {
    return this.delegate
  }

  // public method
  public onBackPressed() {
    if (this.channel) {
      this.checkEngineState();
      this.channel.onBackPressed(() => {
      });
    } else {
      throw new Error("FlutterBoostPlugin might *NOT* have attached to engine yet!");
    }
  }

  addEventListener(key: string, listener: EventListener): ListenerRemover {
    if (!key || !listener) {
      throw new Error("Key and listener cannot be null");
    }

    let listeners = this.listenersTable[key];
    if (!listeners) {
      listeners = [];
      this.listenersTable[key] = listeners;
    }
    listeners.push(listener);

    // 返回符合 ListenerRemover 接口的对象
    return {
      remove: () => {
        const index = listeners.indexOf(listener);
        if (index !== -1) {
          listeners.splice(index, 1);
        }
      }
    }
  }

  /*
   * 向Flutter侧发送pushRoute事件
   * */
  public pushRoute(uniqueId: string, pageName: string, args: Record<string, Object>, callback: () => void) {
    if (this.channel) {
      this.checkEngineState();
      let params = new CommonParams()
      params.uniqueId = uniqueId
      params.pageName = pageName
      params.arguments = args
      this.channel.pushRoute(params, () => {
        if (callback) {
          callback();
        }
      })
    } else {
      throw new Error('pushRoute fail.this.channel is null')
    }
  }

  /*
   * 向Flutter侧发送popRoute事件
   * */
  public popRoute(uniqueId: string, callback: () => void) {
    if (this.channel != null) {
      this.checkEngineState();
      let params = new CommonParams()
      params.uniqueId = uniqueId
      this.channel.popRoute(params, () => {
        if (callback) {
          callback();
        }
      });
    } else {
      throw new Error("FlutterBoostPlugin might *NOT* have attached to engine yet!");
    }
  }

  // public method
  // 创建 [1/4]
  public onContainerCreated(container: FlutterViewContainer) {
    Log.i(TAG, "#onContainerCreated: " + container.getUniqueId());
    FlutterContainerManager.getInstance().addContainer(container.getUniqueId(), container);
    if (FlutterContainerManager.getInstance().getContainerSize() == 1) {
      FlutterBoost.getInstance().changeFlutterAppLifecycle(FlutterBoost.FLUTTER_APP_STATE_RESUMED);
    }
  }

  // 展示 [2/4]
  public onContainerAppeared(container: FlutterViewContainer) {
    let uniqueId = container.getUniqueId()
    FlutterContainerManager.getInstance().activateContainer(uniqueId, container)
    // 这里和android对齐。将pushRoute+onContainerShow合并到一起
    this.pushRoute(uniqueId, container.getUrl(), container.getUrlParams(), () => {
      //do nothing
    })
    this._sendContainerShow(uniqueId);
  }

  // 隐藏 [3/4]
  public onContainerDisappeared(container: FlutterViewContainer) {
    let uniqueId = container.getUniqueId()
    let args: Record<string, Object>;
    if (container && container.paramsForDisappear) {
      args = container!.paramsForDisappear() ? container!.paramsForDisappear()! : {};
    } else {
      args = {};
    }

    this._sendContainerHide(uniqueId, args);
  }

  // 销毁 [4/4]
  public onContainerDestroyed(container: FlutterViewContainer) {
    let uniqueId = container.getUniqueId()
    let args = container.getUrlParams()
    // 1.发送移除消息到dart侧
    this._sendRemoveRoute(uniqueId, args);
    // 2.移除FlutterContainerManager中的container
    FlutterContainerManager.getInstance().removeContainer(uniqueId);
  }

  private _sendContainerShow(uniqueId: string) {
    // 向flutter侧发送onContainerShow消息
    if (this.channel) {
      this.checkEngineState();
      let params = new CommonParams()
      params.uniqueId = uniqueId
      this.channel.onContainerShow(params, () => {
      });
    } else {
      throw new Error("FlutterBoostPlugin might *NOT* have attached to engine yet! When call _onContainerShow");
    }
    Log.i(TAG, "## onContainerShow: " + uniqueId);
  }

  private _sendContainerHide(uniqueId: string, args: Record<string, Object>) {
    // 向flutter侧发送onContainerHide消息
    if (this.channel) {
      this.checkEngineState();
      let params = new CommonParams();
      params.uniqueId = uniqueId;
      params.arguments = args;
      this.channel.onContainerHide(params, () => {
      });
    } else {
      throw new Error("FlutterBoostPlugin might *NOT* have attached to engine yet! When call _onContainerHide");
    }
    Log.i(TAG, "## onContainerHide: " + uniqueId);
  }

  private _sendRemoveRoute(uniqueId: string, args: Record<string, Object>) {
    // 向flutter侧发送_sendRemoveRoute消息
    if (this.channel) {
      this.checkEngineState();
      let params = new CommonParams()
      params.uniqueId = uniqueId
      params.arguments = args
      this.channel.removeRoute(params, () => {
      });
    } else {
      throw new Error("FlutterBoostPlugin might *NOT* have attached to engine yet! When call _removeRoute");
    }
    Log.i(TAG, "## removeRoute: " + uniqueId);
  }

  private checkEngineState() {
    if (!this.engine || !this.engine.getDartExecutor().isExecutingDart()) {
      throw new Error("The engine is not ready for use. " +
        "The message may be drop silently by the engine. " +
        "You should check 'DartExecutor.isExecutingDart()' first!");
    }
  }
}