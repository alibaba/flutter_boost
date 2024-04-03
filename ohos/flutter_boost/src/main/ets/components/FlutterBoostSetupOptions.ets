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
import { FlutterEngineProvider, FlutterPlugin } from '@ohos/flutter_ohos';
import List from '@ohos.util.List';

export class FlutterBoostSetupOptionsBuilder {
  public initialRoute: string = "/";
  public dartEntrypoint: string = "main";
  public dartEntrypointArgs: string[];
  public shouldOverrideBackForegroundEvent: boolean = false;
  public shellArgs: string[];
  public flutterEngineProvider: FlutterEngineProvider | null
  public plugins: List<FlutterPlugin> | null = null;

  constructor() {
    this.initialRoute = '/'
    this.dartEntrypoint = 'main'
    this.dartEntrypointArgs = []
    this.shouldOverrideBackForegroundEvent = false
    this.shellArgs = []
    this.flutterEngineProvider = null
    this.plugins = null
  }

  public setInitialRoute(initialRoute: string): FlutterBoostSetupOptionsBuilder {
    this.initialRoute = initialRoute;
    return this;
  }

  public setDartEntrypoint(dartEntrypoint: string): FlutterBoostSetupOptionsBuilder {
    this.dartEntrypoint = dartEntrypoint;
    return this;
  }

  public setDartEntrypointArgs(args: string[]): FlutterBoostSetupOptionsBuilder {
    this.dartEntrypointArgs = args;
    return this;
  }

  public setShellArgs(shellArgs: string[]): FlutterBoostSetupOptionsBuilder {
    this.shellArgs = shellArgs;
    return this;
  }

  public setFlutterEngineProvider(flutterEngineProvider: FlutterEngineProvider): FlutterBoostSetupOptionsBuilder {
    this.flutterEngineProvider = flutterEngineProvider;
    return this;
  }

  // Determines whether to override back/foreground event.
  public setShouldOverrideBackForegroundEvent(canOverride: boolean): FlutterBoostSetupOptionsBuilder {
    this.shouldOverrideBackForegroundEvent = canOverride
    return this;
  }

  public setPlugins(plugins: List<FlutterPlugin>): FlutterBoostSetupOptionsBuilder {
    this.plugins = plugins;
    return this;
  }

  public build(): FlutterBoostSetupOptions {
    return new FlutterBoostSetupOptions(this);
  }
}

/**
 * FlutterBoostSetupOptions 类是用于配置 FlutterBoost 的设置选项。
 */
export class FlutterBoostSetupOptions {
  private readonly initialRoute: string;
  private readonly dartEntrypoint: string;
  private readonly dartEntrypointArgs: string[];
  private readonly shellArgs: string[];
  private readonly shouldOverrideBackForegroundEvent: boolean;
  private flutterEngineProvider: FlutterEngineProvider | null
  private plugins: List<FlutterPlugin> | null = null;

  public constructor(builder: FlutterBoostSetupOptionsBuilder) {
    this.initialRoute = builder.initialRoute;
    this.dartEntrypoint = builder.dartEntrypoint;
    this.dartEntrypointArgs = builder.dartEntrypointArgs;
    this.shellArgs = builder.shellArgs;
    this.shouldOverrideBackForegroundEvent = builder.shouldOverrideBackForegroundEvent;
    this.flutterEngineProvider = builder.flutterEngineProvider;
    this.plugins = builder.plugins
  }

  public static createDefault(): FlutterBoostSetupOptions {
    return new FlutterBoostSetupOptionsBuilder().build();
  }

  public getInitialRoute(): string {
    return this.initialRoute;
  }

  public getDartEntrypoint(): string {
    return this.dartEntrypoint;
  }

  public getDartEntrypointArgs(): string[] {
    return this.dartEntrypointArgs;
  }

  public getShellArgs(): string[] {
    return this.shellArgs;
  }

  public getFlutterEngineProvider(): FlutterEngineProvider | null {
    return this.flutterEngineProvider;
  }

  public getShouldOverrideBackForegroundEvent(): boolean {
    return this.shouldOverrideBackForegroundEvent;
  }

  public getPlugins(): List<FlutterPlugin> | null {
    return this.plugins;
  }

  public toString(): string {
    let sb: string[] = ['['];
    if (this.shellArgs == null || this.shellArgs.length == 0) {
      sb.push(']');
    } else {
      for (let i = 0; i < this.shellArgs.length; i++) {
        sb.push(String(this.shellArgs[i]));
        if (i == this.shellArgs.length - 1) {
          sb.push(']');
          break;
        }
        sb.push(", ");
      }
    }
    return `initialRoute:${this.initialRoute}, dartEntrypoint:${this.dartEntrypoint}, shouldOverrideBackForegroundEvent:${this.shouldOverrideBackForegroundEvent}, shellArgs:${sb.join('')}`;
  }
}


