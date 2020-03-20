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
package com.idlefish.flutterboost;


import android.util.Log;

import com.idlefish.flutterboost.log.AndroidLog;
import com.idlefish.flutterboost.log.ILog;

public class Debuger {
    private static final String TAG = "FlutterBoost#";
    private static final Debuger DEBUG = new Debuger();
    private static boolean sSafeMode = false;
    private static ILog sLog = new AndroidLog();

    private Debuger() {
    }

    private void print(String info) {
        if (isDebug()) {
            sLog.e(TAG, info);
        }
    }

    public static void log(String info) {
        DEBUG.print(info);
    }

    public static void exception(String message) {
        if (canThrowError()) {
            throw new RuntimeException(message);
        } else {
            sLog.e(TAG, "exception", new RuntimeException(message));
        }
    }

    public static void exception(Throwable t) {
        if (canThrowError()) {
            throw new RuntimeException(t);
        } else {
            sLog.e(TAG, "exception", t);
        }
    }

    public static boolean isDebug() {
        try {
            return FlutterBoost.instance().platform().isDebug();
        } catch (Throwable t) {
            return false;
        }
    }

    /**
     * 设置boost log接收实现，默认为Anroid自带Log
     *
     * @param log
     */
    public static void setLog(ILog log) {
        if (log != null) {
            sLog = log;
        }
    }

    /**
     * 设置Debugger策略倾向，如tue，则优先保证程序稳定，false，可抛Error
     *
     * @param safeMode
     */
    public static void setSafeMode(boolean safeMode) {
        sSafeMode = safeMode;
    }

    private static boolean canThrowError() {
        return isDebug() && !sSafeMode;
    }
}
