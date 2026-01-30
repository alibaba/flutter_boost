// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.os.Build;
import android.util.Log;

import com.idlefish.flutterboost.FlutterBoostUtils;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

public class FlutterContainerManager {
    private static final String TAG = "FlutterBoost_java";

    private FlutterContainerManager() {}
    private boolean isDebugLoggingEnabled() {
        return FlutterBoostUtils.isDebugLoggingEnabled();
    }

    private static class LazyHolder {
        static final FlutterContainerManager INSTANCE = new FlutterContainerManager();
    }

    public static FlutterContainerManager instance() {
        return FlutterContainerManager.LazyHolder.INSTANCE;
    }

    private final Map<String, FlutterViewContainer> allContainers = new HashMap<>();
    private final LinkedList<FlutterViewContainer> activeContainers = new LinkedList<>();

    // onContainerCreated
    public void addContainer(String uniqueId, FlutterViewContainer container) {
        allContainers.put(uniqueId, container);
        if (isDebugLoggingEnabled()) Log.d(TAG, "#addContainer: " + uniqueId + ", " + this);
    }

    // onContainerAppeared
    public void activateContainer(String uniqueId, FlutterViewContainer container) {
        if (uniqueId == null || container == null) return;
        assert(allContainers.containsKey(uniqueId));

        if (activeContainers.contains(container)) {
            activeContainers.remove(container);
        }
        activeContainers.add(container);
        if (isDebugLoggingEnabled()) Log.d(TAG, "#activateContainer: " + uniqueId + "," + this);
    }

    // onContainerDestroyed
    public void removeContainer(String uniqueId) {
        if (uniqueId == null) return;
        FlutterViewContainer container = allContainers.remove(uniqueId);
        activeContainers.remove(container);
        if (isDebugLoggingEnabled()) Log.d(TAG, "#removeContainer: " + uniqueId + ", " + this);
    }


    public FlutterViewContainer findContainerById(String uniqueId) {
        if (allContainers.containsKey(uniqueId)) {
            return allContainers.get(uniqueId);
        }
        return null;
    }

    public boolean isActiveContainer(FlutterViewContainer container) {
        return activeContainers.contains(container);
    }

    public FlutterViewContainer getTopContainer() {
        if (activeContainers.size() > 0) {
            return activeContainers.getLast();
        }
        return null;
    }

    public FlutterViewContainer getTopActivityContainer() {
        final int size = activeContainers.size();
        if (size == 0) {
            return null;
        }
        for (int i = size - 1; i >= 0; i--) {
            final FlutterViewContainer container = activeContainers.get(i);
            if (container instanceof Activity) {
                return container;
            }
        }
        return null;
    }

    public boolean isTopContainer(String uniqueId) {
        FlutterViewContainer top = getTopContainer();
        if (top != null && top.getUniqueId() == uniqueId) {
            return true;
        }
        return false;
    }

    public int getContainerSize() {
        return allContainers.size();
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("activeContainers=" + activeContainers.size() + ", [");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            activeContainers.forEach((value) -> sb.append(value.getUrl() + ','));
        }
        sb.append("]");
        return sb.toString();
    }
}
