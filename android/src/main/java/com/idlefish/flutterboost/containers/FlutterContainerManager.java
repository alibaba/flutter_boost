package com.idlefish.flutterboost.containers;

import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.Map;

public class FlutterContainerManager {

    private FlutterContainerManager() {}
    private static class LazyHolder {
        static final FlutterContainerManager INSTANCE = new FlutterContainerManager();
    }

    public static FlutterContainerManager instance() {
        return FlutterContainerManager.LazyHolder.INSTANCE;
    }

    private final Map<String, FlutterViewContainer> allContainers = new LinkedHashMap<>();

    public FlutterViewContainer findContainerById(String uniqueId) {
        if (allContainers.containsKey(uniqueId)) {
            return allContainers.get(uniqueId);
        }
        return null;
    }

    public FlutterViewContainer getTopContainer() {
        if (allContainers.size() > 0) {
            LinkedList<String> listKeys = new LinkedList<String>(allContainers.keySet());
            return allContainers.get(listKeys.getLast());
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

    public void reorderContainer(String uniqueId, FlutterViewContainer container) {
        if (uniqueId == null || container == null) return;
        if (allContainers.containsKey(uniqueId)) {
            allContainers.remove(uniqueId);
        }
        allContainers.put(uniqueId, container);
    }

    public void removeContainer(String uniqueId) {
        if (uniqueId == null) return;
        allContainers.remove(uniqueId);
    }

    public LinkedList<String> getContainers() {
        return new LinkedList<String>(allContainers.keySet());
    }

}
