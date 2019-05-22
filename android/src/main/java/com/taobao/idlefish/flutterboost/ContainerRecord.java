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
package com.taobao.idlefish.flutterboost;

import android.os.Handler;

import com.taobao.idlefish.flutterboost.NavigationService.NavigationService;
import com.taobao.idlefish.flutterboost.interfaces.IContainerManager;
import com.taobao.idlefish.flutterboost.interfaces.IContainerRecord;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;

import java.util.Map;

import fleamarket.taobao.com.xservicekit.handler.MessageResult;

public class ContainerRecord implements IContainerRecord {
    private final IContainerManager mManager;
    private final IFlutterViewContainer mContainer;
    private final String mUniqueId;
    private final Handler mHandler = new Handler();

    private int mState = STATE_UNKNOW;
    private MethodChannelProxy mProxy = new MethodChannelProxy();

    public ContainerRecord(IContainerManager manager, IFlutterViewContainer container) {
        mUniqueId = System.currentTimeMillis() + "-" + hashCode();
        mManager = manager;
        mContainer = container;
    }

    @Override
    public String uniqueId() {
        return mUniqueId;
    }

    @Override
    public IFlutterViewContainer getContainer() {
        return mContainer;
    }

    @Override
    public int getState() {
        return mState;
    }

    @Override
    public void onCreate() {
        mState = STATE_CREATED;
        mContainer.getBoostFlutterView().boostResume();
        mProxy.create();
    }

    @Override
    public void onAppear() {
        mState = STATE_APPEAR;
        mContainer.getBoostFlutterView().boostResume();
        mProxy.appear();
    }

    @Override
    public void onDisappear() {
        mProxy.disappear();
        mState = STATE_DISAPPEAR;

        /**
         * Bug workaround:
         * If current container is finishing, we should call destroy flutter page early.
         */
        if(mContainer.isFinishing()) {
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mProxy.destroy();
                }
            });
        }
    }

    @Override
    public void onDestroy() {
        mProxy.destroy();
        mState = STATE_DESTROYED;
    }

    @Override
    public void onResult(Map Result) {
        NavigationService.onNativePageResult(
                genResult("onNativePageResult"),
                mUniqueId,
                mUniqueId,
                Result,
                mContainer.getContainerParams()
        );
    }

    private class MethodChannelProxy {
        private int mState = STATE_UNKNOW;

        private void create() {
            if (mState == STATE_UNKNOW) {
                NavigationService.didInitPageContainer(
                        genResult("didInitPageContainer"),
                        mContainer.getContainerName(),
                        mContainer.getContainerParams(),
                        mUniqueId
                );
                //Debuger.log("didInitPageContainer");
                mState = STATE_CREATED;
            }
        }

        private void appear() {
            NavigationService.didShowPageContainer(
                    genResult("didShowPageContainer"),
                    mContainer.getContainerName(),
                    mContainer.getContainerParams(),
                    mUniqueId
            );
            //Debuger.log("didShowPageContainer");

            mState = STATE_APPEAR;
        }

        private void disappear() {
            if (mState < STATE_DISAPPEAR) {
                NavigationService.didDisappearPageContainer(
                        genResult("didDisappearPageContainer"),
                        mContainer.getContainerName(),
                        mContainer.getContainerParams(),
                        mUniqueId
                );
                //Debuger.log("didDisappearPageContainer");

                mState = STATE_DISAPPEAR;
            }
        }

        private void destroy() {
            if (mState < STATE_DESTROYED) {
                NavigationService.willDeallocPageContainer(
                        genResult("willDeallocPageContainer"),
                        mContainer.getContainerName(),
                        mContainer.getContainerParams(),
                        mUniqueId
                );
                //Debuger.log("willDeallocPageContainer");

                mState = STATE_DESTROYED;
            }
        }
    }

    private MessageResult<Boolean> genResult(final String name) {
        return new MessageResult<Boolean>() {

            @Override
            public void success(Boolean var1) {
                //Debuger.log(name + " call success");
            }

            @Override
            public void error(String var1, String var2, Object var3) {
                Debuger.log(name + " call error");
            }

            @Override
            public void notImplemented() {
                Debuger.log(name + " call not Impelemented");
            }
        };
    }
}
