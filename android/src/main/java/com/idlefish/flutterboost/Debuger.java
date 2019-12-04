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

public class Debuger {
    private static final String TAG = "FlutterBoost#";
    private static final Debuger DEBUG = new Debuger();

    private Debuger(){ }

    private void print(String info) {
        if(isDebug()) {
            Log.e(TAG, info);
        }
    }

    public static void log(String info) {
        DEBUG.print(info);
    }

    public static void exception(String message) {
        if(isDebug()) {
            throw new RuntimeException(message);
        }else{
            Log.e(TAG,"exception",new RuntimeException(message));
        }
    }

    public static void exception(Throwable t) {
        if(isDebug()) {
            throw new RuntimeException(t);
        }else{
            Log.e(TAG,"exception",t);
        }
    }

    public static boolean isDebug(){
        try {
            return FlutterBoost.instance().platform().isDebug();
        }catch (Throwable t){
            return false;
        }
    }
}
