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
package com.idlefish.flutterboost.interfaces;

import android.app.Activity;

import com.idlefish.flutterboost.containers.FlutterSplashView;

import java.util.Map;

/**
 * a container which contains the flutter view
 */
public interface IFlutterViewContainer {
    String RESULT_KEY = "_flutter_result_";

    Activity getContextActivity();

    /**
     * provide a flutter view
     * @return
     */
    FlutterSplashView getBoostFlutterView();

    /**
     * call to destroy the container
     */
    void finishContainer(Map<String,Object> result);

    /**
     * container name
     * @return
     */
    String getContainerUrl();

    /**
     * container params
     * @return
     */
    Map getContainerUrlParams();

    /**
     * callback when container shown
     */
    void onContainerShown();

    /**
     * callback when container hidden
     */
    void onContainerHidden();
}
