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
import FlutterBoostUtils from '../FlutterBoostUtils';
import FlutterBoostAbility from './FlutterBoostAbility';
import { FlutterViewContainer } from './FlutterViewContainer';
import Log from '../util/Log'

const TAG = 'FlutterContainerManager'

/**
 * FlutterContainerManager 类是用于管理 FlutterBoost 容器的类。
 */
export default class FlutterContainerManager{
  private static instance: FlutterContainerManager;
  public static getInstance(): FlutterContainerManager {
    if (!FlutterContainerManager.instance) {
      FlutterContainerManager.instance = new FlutterContainerManager();
    }
    return FlutterContainerManager.instance;
  }

  private allContainers: Map<string, FlutterViewContainer> = new Map();
  private activeContainers: FlutterViewContainer[] = [];
  public topContainerWaitForAttachToEngine: FlutterViewContainer | null = null;

  private isTraceEnabled(): boolean {
    return FlutterBoostUtils.isDebugLoggingEnabled();
  }

  public addContainer(uniqueId: string, container: FlutterViewContainer): void {
    this.allContainers.set(uniqueId, container);
    if (this.isTraceEnabled()) Log.i(TAG, "#addContainer: " + this.toString());
  }

  public activateContainer(uniqueId: string | null, container: FlutterViewContainer | null): void {
    if (uniqueId === null || container === null) return;
    if (!this.allContainers.has(uniqueId)) throw new Error('Container does not exist');

    const index = this.activeContainers.indexOf(container);
    if (index !== -1) {
      this.activeContainers.splice(index, 1);
    }
    this.activeContainers.push(container);
    if (this.isTraceEnabled()) Log.i(TAG, "#activateContainer: " + this.toString());
  }

  public removeContainer(uniqueId: string | null): void {
    if (uniqueId === null) return;
    const container = this.allContainers.get(uniqueId);
    if (container) {
      this.allContainers.delete(uniqueId);
      const index = this.activeContainers.indexOf(container);
      if (index !== -1) {
        this.activeContainers.splice(index, 1);
      }
    }
    if (this.isTraceEnabled()) Log.i(TAG, "#removeContainer: " + this.toString());
  }

  public findContainerById(uniqueId: string): FlutterViewContainer | null {
    return this.allContainers.get(uniqueId) || null;
  }

  public isActiveContainer(container: FlutterViewContainer): boolean {
    return this.activeContainers.includes(container);
  }

  public getTopContainer(): FlutterViewContainer | null {
    if (this.isTraceEnabled()) Log.i(TAG, "#getTopContainer: " + this.toString());
    if (this.activeContainers.length > 0) {
      return this.activeContainers[this.activeContainers.length - 1];
    }
    return null;
  }


  public getTopContainerOfThis(container: FlutterViewContainer): FlutterViewContainer | null {
    const index = this.activeContainers.indexOf(container);
    if (index !== -1 && index + 1 < this.activeContainers.length) {
      return this.activeContainers[index + 1];
    }
    return null;
  }

  public isTopContainer(uniqueId: string): boolean {
    const top = this.getTopContainer();
    return top !== null && top.getUniqueId() === uniqueId;
  }

  public getContainerSize(): number {
    return this.allContainers.size;
  }

  public toString(): string {
    let sb: string[] = [`activeContainers=${this.activeContainers.length}, [`];
    this.activeContainers.forEach((value) => sb.push(`${value.getUrl()},`));
    sb.push("]");
    return sb.join("");
  }
}

