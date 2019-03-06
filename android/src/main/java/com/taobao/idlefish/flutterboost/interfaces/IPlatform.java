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
package com.taobao.idlefish.flutterboost.interfaces;

import android.app.Activity;
import android.app.Application;
import android.content.Context;

import java.util.Map;

/**
 * APIs that platform(Android App) must provide
 */
public interface IPlatform {

    /**
     * get current application
     * @return
     */
    Application getApplication();

    /**
     * get main activity, which must always exist at the bottom of task stack.
     * @return
     */
    Activity getMainActivity();

    /**
     * debug or not
     * @return
     */
    boolean isDebug();

    /**
     * start a new activity from flutter page, you may need a page router with url
     * @param context
     * @param url
     * @param requestCode
     * @return
     */
    boolean startActivity(Context context,String url,int requestCode);


    /**
     * settings, no use
     * @return
     */
    Map getSettings();
}
