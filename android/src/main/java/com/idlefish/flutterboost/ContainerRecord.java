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

import android.content.Intent;

import com.idlefish.flutterboost.interfaces.IContainerRecord;
import com.idlefish.flutterboost.interfaces.IFlutterViewContainer;

import java.util.HashMap;
import java.util.Map;

public class ContainerRecord implements IContainerRecord {
    private final FlutterViewContainerManager mManager;
    private final IFlutterViewContainer mContainer;
    private final String mUniqueId;

    private int mState = STATE_UNKNOW;
    private MethodChannelProxy mProxy = new MethodChannelProxy();

    ContainerRecord(FlutterViewContainerManager manager, IFlutterViewContainer container) {
        final Map params = container.getContainerUrlParams();
        if(params != null && params.containsKey(IContainerRecord.UNIQ_KEY)) {
            mUniqueId = String.valueOf(params.get(IContainerRecord.UNIQ_KEY));
        }else{
            mUniqueId = genUniqueId(this);
        }

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

    /**
     *
     * 解决Top页面在绑定engine 后，被底下页面detach engine ，导致白屏问题卡死问题
     *
     * 具体案例路径和原因：
     * android 10系统
     * 1、闲鱼应用当前是Flutter页面（Flutter-A），切到后台；
     * 2、切后台后，某些原因，导致accs断开；
     * 3、收到push，因为accs断开，走厂商通道；
     * 4、进去XiaoMiSystemMessageActivity（Native-B），这个activity主题是透明的，埋下一个问题；
     * 5、XiaoMiSystemMessageActivity 内处理push，跳转到消息页（Flutter-C）,同时关闭自己；
     *
     * 5 步骤 堆栈从 [Native-B,Flutter-A] 变成了  [Flutter-C,Flutter-A] ，由于Native-B的主题是透明的，导致Flutter-C,Flutter-A的生命周期回调不合预期，
     * 出现了Flutter-C没有挂载Engine，而Flutter-A挂载Engine的情况。
     *
     * 最终现象是 Flutter-C 假死
     *
     * @return
     */
    @Override
    public boolean isLocked(){
        IContainerRecord record=mManager.getCurrentTopRecord();
        if(record==this ||record==null ) return  false;
        return  true;

    }

    @Override
    public void onCreate() {
        Utils.assertCallOnMainThread();

        if (mState != STATE_UNKNOW) {
            Debuger.exception("state error");
        }

        mState = STATE_CREATED;
//        mContainer.getBoostFlutterView().onResume();
        mProxy.create();
    }

    @Override
    public void onAppear() {
        Utils.assertCallOnMainThread();

        if (mState != STATE_CREATED && mState != STATE_DISAPPEAR) {
            Debuger.exception("state error");
        }

        mState = STATE_APPEAR;

        mManager.pushRecord(this);

        mProxy.appear();

        mContainer.getBoostFlutterView().onAttach();

    }

    @Override
    public void onDisappear() {
        Utils.assertCallOnMainThread();

        if (mState != STATE_APPEAR) {
            Debuger.exception("state error");
        }

        mState = STATE_DISAPPEAR;

        mProxy.disappear();
        if(getContainer().getContextActivity().isFinishing()) {
            mProxy.destroy();
        }

        mContainer.getBoostFlutterView().onDetach();

        mManager.popRecord(this);
    }

    @Override
    public void onDestroy() {
        Utils.assertCallOnMainThread();

        if (mState != STATE_DISAPPEAR) {
            Debuger.exception("state error");
        }

        mState = STATE_DESTROYED;

        mProxy.destroy();

//        mContainer.getBoostFlutterView().onDestroy();

        mManager.removeRecord(this);

        mManager.setContainerResult(this,-1,-1,null);

        if (!mManager.hasContainerAppear()) {
//            mContainer.getBoostFlutterView().onPause();
//            mContainer.getBoostFlutterView().onStop();
        }
    }

    @Override
    public void onBackPressed() {
        Utils.assertCallOnMainThread();

        if (mState == STATE_UNKNOW || mState == STATE_DESTROYED) {
            Debuger.exception("state error");
        }

        HashMap<String, String> map = new HashMap<>();
        map.put("type", "backPressedCallback");
        map.put("name", mContainer.getContainerUrl());
        map.put("uniqueId", mUniqueId);

        FlutterBoost.instance().channel().sendEvent("lifecycle", map);

//        mContainer.getBoostFlutterView().onBackPressed();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {

    }

    @Override
    public void onNewIntent(Intent intent) {

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

    }

    @Override
    public void onContainerResult(int requestCode, int resultCode, Map<String, Object> result) {
        mManager.setContainerResult(this, requestCode,resultCode, result);

    }

    @Override
    public void onUserLeaveHint() {

    }

    @Override
    public void onTrimMemory(int level) {

    }

    @Override
    public void onLowMemory() {

    }


    private class MethodChannelProxy {
        private int mState = STATE_UNKNOW;

        private void create() {
            if (mState == STATE_UNKNOW) {
                invokeChannelUnsafe("didInitPageContainer",
                        mContainer.getContainerUrl(),
                        mContainer.getContainerUrlParams(),
                        mUniqueId
                );
                //Debuger.log("didInitPageContainer");
                mState = STATE_CREATED;
            }
        }


        private void appear() {
            invokeChannelUnsafe("didShowPageContainer",
                    mContainer.getContainerUrl(),
                    mContainer.getContainerUrlParams(),
                    mUniqueId
            );
            //Debuger.log("didShowPageContainer");

            mState = STATE_APPEAR;
        }

        private void disappear() {
            if (mState < STATE_DISAPPEAR) {
                invokeChannel("didDisappearPageContainer",
                        mContainer.getContainerUrl(),
                        mContainer.getContainerUrlParams(),
                        mUniqueId
                );
                //Debuger.log("didDisappearPageContainer");

                mState = STATE_DISAPPEAR;
            }
        }

        private void destroy() {
            if (mState < STATE_DESTROYED) {
                invokeChannel("willDeallocPageContainer",
                        mContainer.getContainerUrl(),
                        mContainer.getContainerUrlParams(),
                        mUniqueId
                );
                //Debuger.log("willDeallocPageContainer");

                mState = STATE_DESTROYED;
            }
        }

        public void invokeChannel(String method, String url, Map params, String uniqueId) {
            HashMap<String, Object> args = new HashMap<>();
            args.put("pageName", url);
            args.put("params", params);
            args.put("uniqueId", uniqueId);
            FlutterBoost.instance().channel().invokeMethod(method, args);
        }

        public void invokeChannelUnsafe(String method, String url, Map params, String uniqueId) {
            HashMap<String, Object> args = new HashMap<>();
            args.put("pageName", url);
            args.put("params", params);
            args.put("uniqueId", uniqueId);
            FlutterBoost.instance().channel().invokeMethodUnsafe(method, args);
        }
    }

    public static String genUniqueId(Object obj) {
        return System.currentTimeMillis() + "-" + obj.hashCode();
    }
}
