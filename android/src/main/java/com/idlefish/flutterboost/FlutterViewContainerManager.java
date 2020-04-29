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

import android.content.Context;
import android.text.TextUtils;

import com.idlefish.flutterboost.interfaces.IContainerManager;
import com.idlefish.flutterboost.interfaces.IContainerRecord;
import com.idlefish.flutterboost.interfaces.IFlutterViewContainer;
import com.idlefish.flutterboost.interfaces.IOperateSyncer;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

public class FlutterViewContainerManager implements IContainerManager {

    private final Map<IFlutterViewContainer, IContainerRecord> mRecordMap = new LinkedHashMap<>();
    private final Set<ContainerRef> mRefs = new HashSet<>();
    private final Stack<IContainerRecord> mRecordStack = new Stack<>();

    private final Map<String,OnResult> mOnResults = new HashMap<>();

    FlutterViewContainerManager() {}

    @Override
    public IOperateSyncer generateSyncer(IFlutterViewContainer container) {
        Utils.assertCallOnMainThread();

        ContainerRecord record = new ContainerRecord(this, container);
        if (mRecordMap.put(container, record) != null) {
            Debuger.exception("container:" + container.getContainerUrl() + " already exists!");
        }

        mRefs.add(new ContainerRef(record.uniqueId(),container));

        return record;
    }

    void pushRecord(IContainerRecord record) {
        if(!mRecordMap.containsValue(record)) {
            Debuger.exception("invalid record!");
        }

        mRecordStack.push(record);
    }

    void popRecord(IContainerRecord record) {
        if(mRecordStack.empty()) return;

        if(mRecordStack.peek() == record) {
            mRecordStack.pop();
        }
    }

    void removeRecord(IContainerRecord record) {
        mRecordStack.remove(record);
        mRecordMap.remove(record.getContainer());
//        if(mRecordMap.isEmpty()){
//
//        }


    }

    void setContainerResult(IContainerRecord record,int requestCode, int resultCode, Map<String,Object> result) {

        IFlutterViewContainer target = findContainerById(record.uniqueId());
        if(target == null) {
            Debuger.exception("setContainerResult error, url="+record.getContainer().getContainerUrl());
        }

        if (result == null) {
            result = new HashMap<>();
        }

        result.put("_requestCode__",requestCode);
        result.put("_resultCode__",resultCode);

        final OnResult onResult = mOnResults.remove(record.uniqueId());
        if(onResult != null) {
            onResult.onResult(result);
        }
    }

    public IContainerRecord recordOf(IFlutterViewContainer container) {
        return mRecordMap.get(container);
    }

    void openContainer(String url, Map<String, Object> urlParams, Map<String, Object> exts,OnResult onResult) {
        Context context = FlutterBoost.instance().currentActivity();
        if(context == null) {
            context = FlutterBoost.instance().platform().getApplication();
        }

        if(urlParams == null) {
            urlParams = new HashMap<>();
        }

        int requestCode = 0;
        final Object v = urlParams.remove("requestCode");
        if(v != null) {
            requestCode = Integer.valueOf(String.valueOf(v));
        }

        final String uniqueId = ContainerRecord.genUniqueId(url);
        urlParams.put(IContainerRecord.UNIQ_KEY,uniqueId);

        IContainerRecord currentTopRecord = getCurrentTopRecord();
        if(onResult != null&&currentTopRecord!=null) {
            mOnResults.put(currentTopRecord.uniqueId(),onResult);
        }

        FlutterBoost.instance().platform().openContainer(context,url,urlParams,requestCode,exts);
    }

    IContainerRecord closeContainer(String uniqueId, Map<String, Object> result,Map<String,Object> exts) {
        IContainerRecord targetRecord = null;
        for (Map.Entry<IFlutterViewContainer, IContainerRecord> entry : mRecordMap.entrySet()) {
            if (TextUtils.equals(uniqueId, entry.getValue().uniqueId())) {
                targetRecord = entry.getValue();
                break;
            }
        }

        if(targetRecord == null) {
            Debuger.exception("closeContainer can not find uniqueId:" + uniqueId);
        }

        FlutterBoost.instance().platform().closeContainer(targetRecord,result,exts);
        return targetRecord;
    }

    @Override
    public IContainerRecord getCurrentTopRecord() {
        if(mRecordStack.isEmpty()) return null;
        return mRecordStack.peek();
    }

    @Override
    public IContainerRecord getLastGenerateRecord() {
        final Collection<IContainerRecord> values = mRecordMap.values();
        if(!values.isEmpty()) {
            final ArrayList<IContainerRecord> array = new ArrayList<>(values);
            return array.get(array.size()-1);
        }
        return null;
    }

    @Override
    public IFlutterViewContainer findContainerById(String uniqueId) {
        IFlutterViewContainer target = null;
        for (Map.Entry<IFlutterViewContainer, IContainerRecord> entry : mRecordMap.entrySet()) {
            if (TextUtils.equals(uniqueId, entry.getValue().uniqueId())) {
                target = entry.getKey();
                break;
            }
        }

        if(target == null) {
            for(ContainerRef ref:mRefs){
                if(TextUtils.equals(uniqueId,ref.uniqueId)) {
                    return ref.container.get();
                }
            }
        }

        return target;
    }

    void onShownContainerChanged(String old, String now) {
        Utils.assertCallOnMainThread();

        IFlutterViewContainer oldContainer = null;
        IFlutterViewContainer nowContainer = null;

        for (Map.Entry<IFlutterViewContainer, IContainerRecord> entry : mRecordMap.entrySet()) {
            if (TextUtils.equals(old, entry.getValue().uniqueId())) {
                oldContainer = entry.getKey();
            }

            if (TextUtils.equals(now, entry.getValue().uniqueId())) {
                nowContainer = entry.getKey();
            }

            if (oldContainer != null && nowContainer != null) {
                break;
            }
        }

        if (nowContainer != null) {
            nowContainer.onContainerShown();
        }

        if (oldContainer != null) {
            oldContainer.onContainerHidden();
        }
    }

    @Override
    public boolean hasContainerAppear() {
        for (Map.Entry<IFlutterViewContainer, IContainerRecord> entry : mRecordMap.entrySet()) {
            if (entry.getValue().getState() == IContainerRecord.STATE_APPEAR) {
                return true;
            }
        }

        return false;
    }

    public static class ContainerRef {
        public final String uniqueId;
        public final WeakReference<IFlutterViewContainer> container;

        ContainerRef(String id, IFlutterViewContainer container) {
            this.uniqueId = id;
            this.container = new WeakReference<>(container);
        }
    }

    interface OnResult {
        void onResult(Map<String,Object> result);
    }
}
