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
import { BinaryMessenger, BasicMessageChannel, } from '@ohos/flutter_ohos';
import CommonParams from './CommonParams';
import FlutterRouterApiCodec from './FlutterRouterApiCodec';

/**
 * 向 Flutter 侧发送消息
 */
export default class FlutterRouterApi {
  private binaryMessenger: BinaryMessenger;

  constructor(argBinaryMessenger: BinaryMessenger) {
    this.binaryMessenger = argBinaryMessenger;
  }

  /**
   * 将发送push路由事件
   *
   * @param argInput 路由的输入参数。
   * @param callback 在路由推送后调用的回调函数。
   */
  pushRoute(argInput: CommonParams, callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.pushRoute",
      FlutterRouterApiCodec.INSTANCE
    );
    try {
      channel.send([argInput], (channelReply) => {
        callback();
      });
    } catch (e) {
      console.log('e:' + e)
    }
  }


  /**
   * 发送pop路由事件
   * @param argInput 弹出路由的参数
   * @param callback 弹出路由完成后的回调函数
   */
  popRoute(argInput: CommonParams, callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.popRoute",
      FlutterRouterApiCodec.INSTANCE
    );
    channel.send([argInput], (toMap) => {
      callback();
    });
  }


  /**
   * 移除路由
   * @param argInput 移除路由的参数
   * @param callback 移除路由完成后的回调函数
   */
  removeRoute(argInput: CommonParams, callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.removeRoute",
      FlutterRouterApiCodec.INSTANCE
    );
    channel.send([argInput], (toMap) => {
      callback();
    });
  }

  /**
   * 回到前台
   * @param argInput - 公共参数
   * @param callback - 回调函数
   */
  onForeground(argInput: CommonParams, callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.onForeground",
      FlutterRouterApiCodec.INSTANCE
    );
    channel.send([argInput], (toMap) => {
      callback();
    });
  }

  /**
   * 进入后台
   * @param argInput - 公共参数
   * @param callback - 回调函数
   */
  onBackground(argInput: CommonParams, callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.onBackground",
      FlutterRouterApiCodec.INSTANCE
    );
    channel.send([argInput], (toMap) => {
      callback();
    });
  }

  /**
   * 处理原生返回结果
   * @param argInput 参数输入
   * @param callback 回调函数
   */
  onNativeResult(argInput: CommonParams, callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.onNativeResult",
      FlutterRouterApiCodec.INSTANCE
    );
    channel.send([argInput], (toMap) => {
      callback();
    });
  }

  /**
   * 当容器显示发送到flutter侧
   * @param argInput - 公共参数
   * @param callback - 回调函数
   */
  onContainerShow(argInput: CommonParams, callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.onContainerShow",
      FlutterRouterApiCodec.INSTANCE
    );
    channel.send([argInput], (toMap) => {
      callback()
    });
  }


  /**
   * 当容器隐藏时发送到flutter侧
   * @param argInput - 公共参数
   * @param callback - 回调函数
   */
  onContainerHide(argInput: CommonParams, callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.onContainerHide",
      FlutterRouterApiCodec.INSTANCE
    );
    channel.send([argInput], (toMap) => {
      callback()
    });
  }

  /**
   * 向Flutter发送事件
   * @param argInput 输入参数
   * @param callback 回调函数
   */
  sendEventToFlutter(argInput: CommonParams, callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.sendEventToFlutter",
      FlutterRouterApiCodec.INSTANCE
    );
    channel.send([argInput], (toMap) => {
      callback()
    });
  }

  /**
   * 发送返回按钮事件
   * @param callback 回调函数，当返回按钮按下时执行。
   */
  onBackPressed(callback: () => void) {
    const channel = new BasicMessageChannel<Object>(
      this.binaryMessenger,
      "dev.flutter.pigeon.FlutterRouterApi.onBackPressed",
      FlutterRouterApiCodec.INSTANCE
    );
    channel.send(null, (channelReply) => {
      callback()
    });
  }
}
