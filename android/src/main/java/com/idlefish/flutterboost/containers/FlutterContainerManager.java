package com.idlefish.flutterboost.containers;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class FlutterContainerManager {

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

    public void addContainer(String uniqueId, FlutterViewContainer container) {
        allContainers.put(uniqueId, container);

    }

    public void activateContainer(String uniqueId, FlutterViewContainer container) {
        if (uniqueId == null || container == null) return;
        assert (allContainers.containsKey(uniqueId));

        if (activeContainers.contains(container)) {
            activeContainers.remove(container);
        }
        activeContainers.add(container);
    }

    public void removeContainer(String uniqueId) {
        if (uniqueId == null) return;
        FlutterViewContainer container = allContainers.remove(uniqueId);
        activeContainers.remove(container);
    }


    public FlutterViewContainer findContainerById(String uniqueId) {
        if (allContainers.containsKey(uniqueId)) {
            return allContainers.get(uniqueId);
        }
        return null;
    }

    public FlutterViewContainer getTopContainer() {
        if (activeContainers.size() > 0) {
            return activeContainers.getLast();
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
}
