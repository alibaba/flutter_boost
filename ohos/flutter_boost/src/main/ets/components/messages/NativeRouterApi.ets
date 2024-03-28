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
import CommonParams from './CommonParams';
import StackInfo from './StackInfo';
import { BinaryMessenger, BasicMessageChannel } from '@ohos/flutter_ohos';
import { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import FlutterRouterApiCodec from './FlutterRouterApiCodec';

/**
 * 来自 Flutter 的消息处理器
 */
export default interface NativeRouterApi {
  /**
   * push原生栈路由
   * @param arg 公共参数
   */
  onPushNativeRoute(arg: CommonParams): void;

  /**
   * push Flutter栈 路由
   * @param arg 公共参数
   */
  onPushFlutterRoute(arg: CommonParams): void;

  /**
   * pop路由
   * @param arg 公共参数
   * @param completion 完成回调函数
   */
  onPopRoute(arg: CommonParams, completion: () => void): void;

  /**
   * 获取路由栈信息
   * @returns 路由栈信息
   */
  onGetStackFromHost(): StackInfo;

  /**
   * 保存路由栈信息
   * @param arg 路由栈信息
   */
  onSaveStackToHost(arg: StackInfo): void;

  /**
   * 发送事件
   * @param arg 公共参数
   */
  onSendEventToNative(arg: CommonParams): void;
}

/**
 * 监听来自dart的channel的回调函数
 */
export function NativeRouterApiSetup(binaryMessenger: BinaryMessenger, api: NativeRouterApi) {
  // pushNativeRoute
  {
    const channel = new BasicMessageChannel<Object>(
      binaryMessenger,
      "dev.flutter.pigeon.NativeRouterApi.pushNativeRoute",
      FlutterRouterApiCodec.INSTANCE
    );

    if (api) {
      channel.setMessageHandler({
        onMessage: (message: Object, reply: Reply<Object>) => {
          const wrapped: Record<string, Object> = {}
          try {
            if (Array.isArray(message)) {
              const input: CommonParams = CommonParams.fromObject(message[0]);
              api.onPushNativeRoute(input);
              wrapped["result"] = {} as Record<string, Object>;
            } else {
              wrapped["error"] = wrapError(new Error("message is not array"));
            }
          } catch (exception) {
            wrapped["error"] = wrapError(exception);
          }
          reply.reply(wrapped);
        }
      })
    } else {
      channel.setMessageHandler(null);
    }
  }

  // pushFlutterRoute
  {
    const channel = new BasicMessageChannel<Object>(
      binaryMessenger,
      "dev.flutter.pigeon.NativeRouterApi.pushFlutterRoute",
      FlutterRouterApiCodec.INSTANCE
    );

    if (api) {
      channel.setMessageHandler({
        onMessage: (message: Object, reply: Reply<Object>) => {
          const wrapped: Record<string, Object> = {}
          try {
            if (Array.isArray(message)) {
              const input: CommonParams = CommonParams.fromObject(message[0]);
              api.onPushFlutterRoute(input);
              wrapped["result"] = {} as Record<string, Object>;
            } else {
              wrapped["error"] = wrapError(new Error("message is not array"));
            }
          } catch (exception) {
            wrapped["error"] = wrapError(exception);
          }
          reply.reply(wrapped);
        }
      })
    } else {
      channel.setMessageHandler(null);
    }
  }

  // popRoute
  {
    const channel = new BasicMessageChannel<Object>(
      binaryMessenger,
      "dev.flutter.pigeon.NativeRouterApi.popRoute",
      FlutterRouterApiCodec.INSTANCE
    );

    if (api) {
      channel.setMessageHandler({
        onMessage: (message: Object, reply: Reply<Object>) => {
          const wrapped: Record<string, Object> = {}
          try {
            if (Array.isArray(message)) {
              const input: CommonParams = CommonParams.fromObject(message[0]);
              api.onPopRoute(input, () => {
                wrapped["result"] = {} as Record<string, Object>;
              });
            } else {
              wrapped["error"] = wrapError(new Error("message is not array"));
            }
          } catch (exception) {
            wrapped["error"] = wrapError(exception);
          }
          reply.reply(wrapped);
        }
      })
    } else {
      channel.setMessageHandler(null);
    }
  }

  // getStackFromHost
  {
    const channel = new BasicMessageChannel<Object>(
      binaryMessenger,
      "dev.flutter.pigeon.NativeRouterApi.getStackFromHost",
      FlutterRouterApiCodec.INSTANCE
    );
    if (api) {
      channel.setMessageHandler({
        onMessage: (message: Object, reply: Reply<Object>) => {
          const wrapped: Record<string, Object> = {}
          try {
            const output: StackInfo = api.onGetStackFromHost()
            wrapped["result"] = output.toRecord()
          } catch (exception) {
            wrapped["error"] = wrapError(exception);
          }
          reply.reply(wrapped);
        }
      })
    } else {
      channel.setMessageHandler(null);
    }
  }

  // saveStackToHost
  {
    const channel = new BasicMessageChannel<Object>(
      binaryMessenger,
      "dev.flutter.pigeon.NativeRouterApi.saveStackToHost",
      FlutterRouterApiCodec.INSTANCE
    );
    if (api) {
      channel.setMessageHandler({
        onMessage: (message: Object, reply: Reply<Object>) => {
          const wrapped: Record<string, Object> = {}
          try {
            if (Array.isArray(message)) {
              const stack: StackInfo = StackInfo.fromObject(message[0]);
              api.onSaveStackToHost(stack)
              wrapped["result"] = {} as Record<string, Object>;
            } else {
              wrapped["error"] = wrapError(new Error("message is not array"));
            }
          } catch (exception) {
            wrapped["error"] = wrapError(exception);
          }
          reply.reply(wrapped);
        }
      })
    } else {
      channel.setMessageHandler(null);
    }
  }

  // sendEventToNative
  {
    const channel = new BasicMessageChannel<Object>(
      binaryMessenger,
      "dev.flutter.pigeon.NativeRouterApi.sendEventToNative",
      FlutterRouterApiCodec.INSTANCE
    );
    if (api) {
      channel.setMessageHandler({
        onMessage: (message: Object, reply: Reply<Object>) => {
          const wrapped: Record<string, Object> = {}
          try {
            if (Array.isArray(message)) {
              const input: CommonParams = CommonParams.fromObject(message[0]);
              api.onSendEventToNative(input);
              wrapped["result"] = {} as Record<string, Object>;
            } else {
              wrapped["error"] = wrapError(new Error("message is not array"));
            }
          } catch (exception) {
            wrapped["error"] = wrapError(exception);
          }
          reply.reply(wrapped);
        }
      })
    } else {
      channel.setMessageHandler(null);
    }
  }
}

function wrapError(exception: Error): Record<string, Object> {
  const err: Record<string, Object> = {
    'message': exception.toString(),
    'code': exception.name,
    'details': ''
  };
  return err
}
