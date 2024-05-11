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

import HiLog from '@ohos.hilog';

const DOMAIN: number = 0x00FF;
const TAG = "FlutterBoost";
const SYMBOL = " --> ";

/**
 * Basic log class
 */
export default class Log {
  /**
   * Outputs debug-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static d(tag: string, format: string, ...args: ESObject[]) {
    if (Log.isLoggable(HiLog.LogLevel.DEBUG)) {
      HiLog.debug(DOMAIN, TAG, tag + SYMBOL + format, args);
    }
  }

  /**
   * Outputs info-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static i(tag: string, format: string, ...args: ESObject[]) {
    if (Log.isLoggable(HiLog.LogLevel.INFO)) {
      HiLog.info(DOMAIN, TAG, tag + SYMBOL + format, args);
    }
  }

  /**
   * Outputs warning-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static w(tag: string, format: string, ...args: ESObject[]) {
    if (Log.isLoggable(HiLog.LogLevel.WARN)) {
      HiLog.warn(DOMAIN, TAG, tag + SYMBOL + format, args);
    }
  }

  /**
   * Outputs error-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static e(tag: string, format: string, ...args: ESObject[]) {
    if (Log.isLoggable(HiLog.LogLevel.ERROR)) {
      HiLog.error(DOMAIN, TAG, tag + SYMBOL + format, args);
    }
  }

  /**
   * Outputs fatal-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static f(tag: string, format: string, ...args: ESObject[]) {
    if (Log.isLoggable(HiLog.LogLevel.FATAL)) {
      HiLog.fatal(DOMAIN, TAG, tag + SYMBOL + format, args);
    }
  }

  /**
   * Checks whether logs of the specified tag, and level can be printed.
   *
   * @param tag Identifies the log tag.
   * @param level log level
   * @since 7
   */
  private static isLoggable(level: HiLog.LogLevel): boolean {
    return HiLog.isLoggable(DOMAIN, TAG, level);
  }
}
