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

import android.app.Application;
import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.PluginRegistry;

/**
 * APIs that platform(Android App) must provide
 */
public interface IPlatform {

    int IMMEDIATELY = 0;          //立即启动引擎
    int ANY_ACTIVITY_CREATED = 1; //当有任何Activity创建时,启动引擎

    /**
     * get current application
     * @return
     */
    Application getApplication();

    /**
     * debug or not
     * @return
     */
    boolean isDebug();

    /**
     * register plugins
     * @return
     */
    void registerPlugins(PluginRegistry registry);


    void openContainer(Context context,String url,Map<String,Object> urlParams,int requestCode,Map<String,Object> exts);


    void closeContainer(IContainerRecord record, Map<String,Object> result, Map<String,Object> exts);

    IFlutterEngineProvider engineProvider();

    /**
     * @return
     *
     *  IMMEDIATELY           //立即
     *  ANY_ACTIVITY_CREATED  //当有任何Activity创建的时候
     *  LAZY                  //懒加载，尽可能延后
     */
    int whenEngineStart();
}
