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

import com.taobao.idlefish.flutterboost.interfaces.IContainerRecord;
import com.taobao.idlefish.flutterboost.interfaces.IContainerManager;

public class Instrument {

    private final IContainerManager mManager;

    Instrument(IContainerManager manager) {
        mManager = manager;
    }

    public void performCreate(IContainerRecord record) {
        final int currentState = record.getState();
        if (currentState != IContainerRecord.STATE_UNKNOW) {
            Debuger.exception("performCreate state error, current state:" + currentState);
            return;
        }

        record.onCreate();
    }

    public void performAppear(IContainerRecord record) {
        final int currentState = record.getState();
        if (currentState != IContainerRecord.STATE_CREATED
                && currentState != IContainerRecord.STATE_DISAPPEAR) {
            Debuger.exception("performAppear state error, current state:" + currentState);
            return;
        }

        record.onAppear();
    }

    public void performDisappear(IContainerRecord record) {
        final int currentState = record.getState();
        if (currentState != IContainerRecord.STATE_APPEAR) {
            Debuger.exception("performDisappear state error , current state:" + currentState);
            return;
        }

        record.onDisappear();
    }

    public void performDestroy(IContainerRecord record) {
        final int currentState = record.getState();
        if (currentState != IContainerRecord.STATE_DISAPPEAR) {
            Debuger.exception("performDestroy state error, current state:" + currentState);
        }

        record.onDestroy();
    }
}
