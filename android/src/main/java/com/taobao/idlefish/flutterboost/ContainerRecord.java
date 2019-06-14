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

import android.content.Intent;

import com.taobao.idlefish.flutterboost.messageing.NavigationService;
import com.taobao.idlefish.flutterboost.messageing.base.MessageResult;
import com.taobao.idlefish.flutterboost.interfaces.IContainerRecord;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;

import java.util.HashMap;
import java.util.Map;

public class ContainerRecord implements IContainerRecord {
    private final FlutterViewContainerManager mManager;
    private final IFlutterViewContainer mContainer;
    private final String mUniqueId;

    private int mState = STATE_UNKNOW;
    private MethodChannelProxy mProxy = new MethodChannelProxy();

    ContainerRecord(FlutterViewContainerManager manager, IFlutterViewContainer container) {
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
        Utils.assertCallOnMainThread();

        if(mState != STATE_UNKNOW) {
            Debuger.exception("state error");
        }

        mState = STATE_CREATED;
        mContainer.getBoostFlutterView().onResume();
        mProxy.create();
    }

    @Override
    public void onAppear() {
        Utils.assertCallOnMainThread();

        if(mState != STATE_CREATED && mState != STATE_DISAPPEAR) {
            Debuger.exception("state error");
        }

        mState = STATE_APPEAR;

        mManager.pushRecord(this);

        mContainer.getBoostFlutterView().onAttach();

        mProxy.appear();
    }

    @Override
    public void onDisappear() {
        Utils.assertCallOnMainThread();

        if(mState != STATE_APPEAR) {
            Debuger.exception("state error");
        }

        mState = STATE_DISAPPEAR;

        mProxy.disappear();

        mContainer.getBoostFlutterView().onDetach();

        mManager.popRecord(this);
    }

    @Override
    public void onDestroy() {
        Utils.assertCallOnMainThread();

        if(mState != STATE_DISAPPEAR) {
            Debuger.exception("state error");
        }

        mState = STATE_DESTROYED;

        mProxy.destroy();

        mManager.removeRecord(this);

        if(!mManager.hasContainerAppear()) {
            mContainer.getBoostFlutterView().onPause();
            mContainer.getBoostFlutterView().onStop();
        }
    }

    @Override
    public void onBackPressed() {
        Utils.assertCallOnMainThread();

        if(mState == STATE_UNKNOW || mState == STATE_DESTROYED) {
            Debuger.exception("state error");
        }

        Map<String, String> map = new HashMap<>();
        map.put("type", "backPressedCallback");
        map.put("name", mContainer.getContainerName());
        map.put("uniqueId", mUniqueId);

        FlutterBoostPlugin.getInstance().sendEvent("lifecycle",map);

        mContainer.getBoostFlutterView().onBackPressed();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        mContainer.getBoostFlutterView().onRequestPermissionsResult(requestCode,permissions,grantResults);
    }

    @Override
    public void onNewIntent(Intent intent) {
        mContainer.getBoostFlutterView().onNewIntent(intent);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        mContainer.getBoostFlutterView().onActivityResult(requestCode,resultCode,data);
    }

    @Override
    public void onUserLeaveHint() {
        mContainer.getBoostFlutterView().onUserLeaveHint();
    }

    @Override
    public void onTrimMemory(int level) {
        mContainer.getBoostFlutterView().onTrimMemory(level);
    }

    @Override
    public void onLowMemory() {
        mContainer.getBoostFlutterView().onLowMemory();
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
