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

import java.util.Map;

import io.flutter.plugin.common.PluginRegistry;

public interface IContainerManager {

    /**
     * call by native side when container create
     * @param container
     * @return
     */
    PluginRegistry onContainerCreate(IFlutterViewContainer container);

    /**
     * call by native side when container appear
     * @param container
     * @return
     */
    void onContainerAppear(IFlutterViewContainer container);


    /**
     * call by native side when container disappear
     * @param container
     * @return
     */
    void onContainerDisappear(IFlutterViewContainer container);

    /**
     * call by native side when container destroy
     * @param container
     * @return
     */
    void onContainerDestroy(IFlutterViewContainer container);

    /**
     * call by native side when back key pressed
     * @param container
     * @return
     */
    void onBackPressed(IFlutterViewContainer container);


    /**
     * call by flutter side when need destroy container
     * @param name
     * @param uq
     */
    void destroyContainerRecord(String name,String uq);

    /**
     * call by native side when container handle a result (onActivityResult)
     * @param container
     * @param result
     */
    void onContainerResult(IFlutterViewContainer container,Map result);

    /**
     * call by flutter side when flutter want set a result for request (setResult)
     * @param uniqueId
     * @param result
     */
    void setContainerResult(String uniqueId,Map result);

    /**
     * get current interactive container
     * @return
     */
    IContainerRecord getCurrentTopRecord();

    /**
     * get last created container
     * @return
     */
    IContainerRecord getLastRecord();

    /**
     * find a container
     * @param uniqueId
     * @return
     */
    IFlutterViewContainer findContainerById(String uniqueId);

    /**
     * call by flutter side when a container shown or hidden
     * @param old
     * @param now
     */
    void onShownContainerChanged(String old,String now);

    /**
     * is any container appear now
     * @return
     */
    boolean hasContainerAppear();

    /**
     * no use
     */
    void reset();
}
