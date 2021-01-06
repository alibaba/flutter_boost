package com.idlefish.flutterboost;

import android.text.TextUtils;

import com.idlefish.flutterboost.containers.FlutterViewContainer;

import java.lang.ref.WeakReference;
import java.util.HashSet;
import java.util.Set;
import java.util.Stack;

public class ContainerManager {

    private final Set<ContainerRef> mContainerRefs = new HashSet<ContainerRef>();
    /**
     * 记录当前最上层的容器
     */
    private Stack<ContainerRef> stackTop = new Stack<ContainerRef>();


    public void setStackTop(FlutterViewContainer container) {
        stackTop.add(new ContainerRef(container.getUniqueId(),container));

    }

    public void removeStackTop(FlutterViewContainer container) {
        if (stackTop.empty()) return;
        if (stackTop.peek().uniqueId== container.getUniqueId()) {
            stackTop.pop();
        }
    }


    public FlutterViewContainer getCurrentStackTop() {
        if (stackTop.empty()) return null;
        return  stackTop.peek().container.get();
    }


    public void addContainer(FlutterViewContainer container) {
        ContainerRef containerRef = new ContainerRef(container.getUniqueId(), container);
        mContainerRefs.add(containerRef);
    }

    public void removeContainer(String uniqueId) {
        if (mContainerRefs.isEmpty()) return;

        for (ContainerRef ref : mContainerRefs) {
            if (uniqueId != null && TextUtils.equals(uniqueId, ref.uniqueId)) {
                mContainerRefs.remove(ref);
            }
        }
    }

    public FlutterViewContainer findContainerById(String uniqueId) {
        for (ContainerRef ref : mContainerRefs) {
            if (TextUtils.equals(uniqueId, ref.uniqueId)) {
                return ref.container.get();
            }
        }
        return null;
    }


    public static class ContainerRef {
        public final String uniqueId;
        public final WeakReference<FlutterViewContainer> container;

        ContainerRef(String id, FlutterViewContainer container) {
            this.uniqueId = id;
            this.container = new WeakReference<>(container);
        }
    }
}
