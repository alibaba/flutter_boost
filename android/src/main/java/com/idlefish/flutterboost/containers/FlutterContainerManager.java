package com.idlefish.flutterboost.containers;

import android.app.Activity;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;

import io.flutter.Log;

public class FlutterContainerManager {
    private static final String TAG = "FlutterContainerManager";
    private static final boolean DEBUG = false;

    private FlutterContainerManager() {
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
        if (DEBUG) Log.d(TAG, "#addContainer:" + toString());
    }

    // onContainerAppeared
    public void activateContainer(String uniqueId, FlutterViewContainer container) {
        if (uniqueId == null || container == null) return;
        assert(allContainers.containsKey(uniqueId));

        if (activeContainers.contains(container)) {
            activeContainers.remove(container);
        }
        activeContainers.add(container);
        if (DEBUG) Log.d(TAG, "#activateContainer:" + toString());
    }

    // onContainerDestroyed
    public void removeContainer(String uniqueId) {
        if (uniqueId == null) return;
        FlutterViewContainer container = allContainers.remove(uniqueId);
        activeContainers.remove(container);
        if (DEBUG) Log.d(TAG, "#removeContainer:" + toString());
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

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("activeContainers=" + activeContainers.size() + ", [");
        activeContainers.forEach((value) -> sb.append(value.getUrl() + ','));
        sb.append("]");
        return sb.toString();
    }
}
