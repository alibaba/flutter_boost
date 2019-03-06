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

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.taobao.idlefish.flutterboost.NavigationService.NavigationService;
import com.taobao.idlefish.flutterboost.interfaces.IContainerManager;
import com.taobao.idlefish.flutterboost.interfaces.IContainerRecord;
import com.taobao.idlefish.flutterboost.interfaces.IFlutterViewContainer;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.WeakHashMap;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterMain;
import io.flutter.view.FlutterRunArguments;

public class FlutterViewContainerManager implements IContainerManager {

    private final Map<IFlutterViewContainer, IContainerRecord> mRecords = new LinkedHashMap<>();
    private final Instrument mInstrument;
    private final Handler mHandler = new Handler(Looper.getMainLooper());
    private final Set<ContainerRef> mRefs = new HashSet<>();

    private IContainerRecord mCurrentTopRecord;

    FlutterViewContainerManager() {
        mInstrument = new Instrument(this);
    }

    @Override
    public PluginRegistry onContainerCreate(IFlutterViewContainer container) {
        assertCallOnMainThread();

        ContainerRecord record = new ContainerRecord(this, container);
        if (mRecords.put(container, record) != null) {
            Debuger.exception("container:" + container.getContainerName() + " already exists!");
            return new PluginRegistryImpl(container.getActivity(), container.getBoostFlutterView());
        }

        mRefs.add(new ContainerRef(record.uniqueId(),container));

        FlutterMain.ensureInitializationComplete(container.getActivity().getApplicationContext(), null);
        BoostFlutterView flutterView = FlutterBoostPlugin.viewProvider().createFlutterView(container);
        if (!flutterView.getFlutterNativeView().isApplicationRunning()) {
            String appBundlePath = FlutterMain.findAppBundlePath(container.getActivity().getApplicationContext());
            if (appBundlePath != null) {
                FlutterRunArguments arguments = new FlutterRunArguments();
                arguments.bundlePath = appBundlePath;
                arguments.entrypoint = "main";
                flutterView.runFromBundle(arguments);
            }
        }
        mInstrument.performCreate(record);

        return new PluginRegistryImpl(container.getActivity(), container.getBoostFlutterView());
    }

    @Override
    public void onContainerAppear(IFlutterViewContainer container) {
        assertCallOnMainThread();

        final IContainerRecord record = mRecords.get(container);
        if (record == null) {
            Debuger.exception("container:" + container.getContainerName() + " not exists yet!");
            return;
        }

        mInstrument.performAppear(record);
        mCurrentTopRecord = record;
    }

    @Override
    public void onContainerDisappear(IFlutterViewContainer container) {
        assertCallOnMainThread();

        final IContainerRecord record = mRecords.get(container);
        if (record == null) {
            Debuger.exception("container:" + container.getContainerName() + " not exists yet!");
            return;
        }
        mInstrument.performDisappear(record);

        if (!container.isFinishing()) {
            checkIfFlutterViewNeedStopLater();
        }
    }

    @Override
    public void onContainerDestroy(IFlutterViewContainer container) {
        assertCallOnMainThread();

        if (mCurrentTopRecord != null
                && mCurrentTopRecord.getContainer() == container) {
            mCurrentTopRecord = null;
        }

        final IContainerRecord record = mRecords.remove(container);
        if (record == null) {
            Debuger.exception("container:" + container.getContainerName() + " not exists yet!");
            return;
        }

        mInstrument.performDestroy(record);

        checkIfFlutterViewNeedStopLater();
    }

    private void checkIfFlutterViewNeedStopLater() {
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (!hasContainerAppear()) {
                    FlutterBoostPlugin.viewProvider().stopFlutterView();
                }
            }
        }, 250);
    }

    @Override
    public void onBackPressed(IFlutterViewContainer container) {
        assertCallOnMainThread();

        final IContainerRecord record = mRecords.get(container);
        if (record == null) {
            Debuger.exception("container:" + container.getContainerName() + " not exists yet!");
            return;
        }

        Map<String, String> map = new HashMap<>();
        map.put("type", "backPressedCallback");
        map.put("name", container.getContainerName());
        map.put("uniqueId", record.uniqueId());
        NavigationService.getService().emitEvent(map);
    }

    @Override
    public void destroyContainerRecord(String name, String uniqueId) {
        assertCallOnMainThread();

        boolean done = false;
        for (Map.Entry<IFlutterViewContainer, IContainerRecord> entry : mRecords.entrySet()) {
            if (TextUtils.equals(uniqueId, entry.getValue().uniqueId())) {
                entry.getKey().destroyContainer();
                done = true;
                break;
            }
        }

        if (!done) {
            Debuger.exception("destroyContainerRecord can not find name:" + name + " uniqueId:" + uniqueId);
        }
    }

    @Override
    public void onContainerResult(IFlutterViewContainer container, Map result) {
        final IContainerRecord record = mRecords.get(container);
        if (record == null) {
            Debuger.exception("container:" + container.getContainerName() + " not exists yet!");
            return;
        }

        record.onResult(result);
    }

    @Override
    public void setContainerResult(String uniqueId, Map result) {
        if (result == null) {
            Debuger.exception("setContainerResult result is null");
            return;
        }

        if (!(result instanceof HashMap)) {
            result = new HashMap();
            result.putAll(result);
        }

        boolean done = false;
        for (Map.Entry<IFlutterViewContainer, IContainerRecord> entry : mRecords.entrySet()) {
            if (TextUtils.equals(uniqueId, entry.getValue().uniqueId())) {
                entry.getKey().setBoostResult((HashMap) result);
                done = true;
                break;
            }
        }

        if (!done) {
            Debuger.exception("setContainerResult can not find uniqueId:" + uniqueId);
        }
    }

    @Override
    public IContainerRecord getCurrentTopRecord() {
        return mCurrentTopRecord;
    }

    @Override
    public IContainerRecord getLastRecord() {
        final Collection<IContainerRecord> values = mRecords.values();
        if(!values.isEmpty()) {
            final ArrayList<IContainerRecord> array = new ArrayList<>(values);
            return array.get(array.size()-1);
        }
        return null;
    }

    @Override
    public IFlutterViewContainer findContainerById(String uniqueId) {
        IFlutterViewContainer target = null;
        for (Map.Entry<IFlutterViewContainer, IContainerRecord> entry : mRecords.entrySet()) {
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

    @Override
    public void onShownContainerChanged(String old, String now) {
        assertCallOnMainThread();

        IFlutterViewContainer oldContainer = null;
        IFlutterViewContainer nowContainer = null;

        for (Map.Entry<IFlutterViewContainer, IContainerRecord> entry : mRecords.entrySet()) {
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
        assertCallOnMainThread();

        for (Map.Entry<IFlutterViewContainer, IContainerRecord> entry : mRecords.entrySet()) {
            if (entry.getValue().getState() == IContainerRecord.STATE_APPEAR) {
                return true;
            }
        }

        return false;
    }

    @Override
    public void reset() {
    }

    private void assertCallOnMainThread() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            Debuger.exception("must call method on main thread");
        }
    }

    public static class ContainerRef {
        public final String uniqueId;
        public final WeakReference<IFlutterViewContainer> container;

        ContainerRef(String id, IFlutterViewContainer container) {
            this.uniqueId = id;
            this.container = new WeakReference<>(container);
        }
    }

    public static class PluginRegistryImpl implements PluginRegistry {

        final BoostFlutterView mBoostFlutterView;

        PluginRegistryImpl(Activity activity, BoostFlutterView flutterView) {
            mBoostFlutterView = flutterView;
        }

        @Override
        public Registrar registrarFor(String pluginKey) {
            return mBoostFlutterView.getPluginRegistry().registrarFor(pluginKey);
        }

        @Override
        public boolean hasPlugin(String key) {
            return mBoostFlutterView.getPluginRegistry().hasPlugin(key);
        }

        @Override
        public <T> T valuePublishedByPlugin(String pluginKey) {
            return mBoostFlutterView.getPluginRegistry().valuePublishedByPlugin(pluginKey);
        }
    }
}
