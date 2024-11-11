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
import common from '@ohos.app.ability.common';
import {
  FlutterEngine,
  FlutterEngineCache,
  FlutterInjector,
  PlatformViewsController
} from '@ohos/flutter_ohos';
import { DartEntrypoint } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/dart/DartExecutor';
import CommonParams from './messages/CommonParams';
import FlutterBoostDelegate from './FlutterBoostDelegate';
import FlutterBoostUtils from './FlutterBoostUtils';
import { FlutterBoostRouteOptionsBuilder } from './FlutterBoostRouteOptions';
import { FlutterBoostSetupOptions } from './FlutterBoostSetupOptions';
import { FlutterBoostPlugin } from './plugin/FlutterBoostPlugin';
import FlutterContainerManager from './containers/FlutterContainerManager';
import { FlutterViewContainer } from './containers/FlutterViewContainer';
import Log from './util/Log';

const TAG = "FlutterBoost";

/**
 * FlutterBoost核心类
 *
 * 实现NativeRouterApi是用户接受来自dart侧的消息
 */
export class FlutterBoost {
  private static instance: FlutterBoost;
  public static ENGINE_ID = 'flutter_boost_default_engine'

  private flutterEngine: FlutterEngine | null = null
  private delegate: FlutterBoostDelegate | null = null
  private plugin: FlutterBoostPlugin | null = null
  private isInBackground: boolean = false;

  public static getInstance(): FlutterBoost {
    if (!FlutterBoost.instance) {
      FlutterBoost.instance = new FlutterBoost();
    }
    return FlutterBoost.instance;
  }

  public isAppInBackground(): boolean {
    return this.isInBackground;
  }

  /**
   * 设置FlutterBoost的配置信息
   * @param delegate FlutterBoost的委托对象
   * @param context 上下文对象
   * @param onEngineReady 回调函数
   * @param options FlutterBoost的配置选项
   */
  public async setup(delegate: FlutterBoostDelegate,
                     context: common.Context,
                     onEngineReady: (engine: FlutterEngine) => void,
                     options: FlutterBoostSetupOptions | null) {

    this.delegate = delegate;

    if (options == null) {
      // 指定默认设置参数（初始路由为/,入口参数main）
      options = FlutterBoostSetupOptions.createDefault();
    }
    FlutterBoostUtils.setDebugLoggingEnabled(options.isDebugLoggingEnabled());

    // 1. 初始化引擎
    let engine: FlutterEngine | null = this.getEngine()
    if (engine == null) {
      const engineProvider = options.getFlutterEngineProvider();
      if (engineProvider) {
        engine = engineProvider.provideFlutterEngine(context);
      }
      if (engine == null) {
        engine = new FlutterEngine(context, null, null, new PlatformViewsController());
        await engine.init(context, options.getShellArgs(), true);
      }
      FlutterEngineCache.getInstance().put(FlutterBoost.ENGINE_ID, engine);
    }
    this.flutterEngine = engine;

    // 2. 通知业务引擎就绪
    onEngineReady(engine);

    // 3. 设置message channel消息代理
    this.getPlugin()!.setDelegate(this.delegate);

    // 4. DartVM预热
    if (!engine.getDartExecutor().isExecutingDart()) {
      const navigationChannel = engine.getNavigationChannel()
      if (navigationChannel) {
        navigationChannel.setInitialRoute(options.getInitialRoute())
      }
      // TODO:这里没完全对齐
      const dartEntrypoint: DartEntrypoint = new DartEntrypoint(
        FlutterInjector.getInstance().getFlutterLoader().findAppBundlePath(),
        '',
        options.getDartEntrypoint()
      );
      engine.getDartExecutor().executeDartEntrypoint(dartEntrypoint, options.getDartEntrypointArgs());
    }
  }


  /**
   * 设置FlutterBoost的配置信息(Promise)
   * @param delegate FlutterBoost的委托对象
   * @param context 上下文对象
   * @param options FlutterBoost的配置选项
   */
  public setupSync(delegate: FlutterBoostDelegate,
                   context: common.Context,
                   options: FlutterBoostSetupOptions | null): Promise<FlutterEngine> {
    return new Promise<FlutterEngine>((resolve, reject) => {
      try {
        this.setup(delegate, context, (engine: FlutterEngine) => {
          resolve(engine);
        }, options)
      } catch (error) {
        // 如果有错误发生，则拒绝Promise
        reject(error);
      }
    });
  }

  public async unsetFlutterBoost() {
    this.plugin?.setDelegate(null);
    this.plugin = null;
    this.delegate = null;

    FlutterEngineCache.getInstance().remove(FlutterBoost.ENGINE_ID);
    // 暂时不调用，会crash
    // this.flutterEngine?.destroy();
    this.flutterEngine = null;
  }

  /**
   * 打开页面
   * @param pageName 页面名称
   * @param param 参数
   */
  public open(pageName: string, param: Record<string, Object>, opaque?: boolean, onPageResult?: (pageName: string, result: Record<string, Object>) => void) {
    let options = new FlutterBoostRouteOptionsBuilder()
      .setPageName(pageName)
      .setArguments(param)
      .setOpaque(opaque ?? true)
      .build();
    const plugin: FlutterBoostPlugin | null = this.getPlugin()
    if (plugin) {
      const delegate = plugin.getDelegate() as FlutterBoostDelegate;
      if (delegate) {
        delegate.pushFlutterRoute(options, onPageResult);
      } else {
        Log.e(TAG, 'open fail. get delegate fail! Maybe setup function has not been invoked.');
      }
    } else {
      Log.e(TAG, 'open fail. get plugin fail! Maybe setup function has not been invoked.');
    }
  }

  /**
   * 获取引擎对象
   * @returns 引擎对象，如果不存在则返回null
   */
  public getEngine(): FlutterEngine | null {
    return FlutterEngineCache.getInstance().get(FlutterBoost.ENGINE_ID);
  }

  /**
   * 获取插件对象
   * @returns {FlutterBoostPlugin | null} 插件对象或者null
   */
  public getPlugin(): FlutterBoostPlugin | null {
    if (this.plugin == null) {
      let engine = this.getEngine();
      if (engine) {
        const plugin: FlutterBoostPlugin | null = FlutterBoostUtils.getPlugin(engine);
        if (plugin != null) {
          this.plugin = plugin;
        } else {
          throw new Error('Oops! Failed to get |FlutterBoostPlugin|.')
        }
      } else {
        Log.e(TAG, 'Oops! Failed to get |FlutterEngine|. Maybe setup function has not been invoked.');
      }
    }
    return this.plugin;
  }

  /**
   * 向Flutter发送事件
   * @param key 事件的键
   * @param args 事件的参数
   */
  public sendEventToFlutter(key: string, args: Record<string, Object>) {
    this.getPlugin()?.sendEventToFlutter(key, args);
  }

  /**
   * Ability has brought to foreground
   */
  public onBackground() {
    this.isInBackground = true;
    this.getPlugin()?.onBackground();
  }

  /**
   * Ability has back to background
   */
  public onForeground() {
    this.getPlugin()?.onForeground();
    this.isInBackground = false;
  }

  public isTopContainer(container: FlutterViewContainer): boolean {
    return FlutterContainerManager.getInstance().getTopContainer() == container;
  }
}
