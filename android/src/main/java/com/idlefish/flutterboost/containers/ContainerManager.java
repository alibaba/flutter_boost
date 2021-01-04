package com.idlefish.flutterboost.containers;

import android.app.Activity;
import android.text.TextUtils;

import java.lang.ref.WeakReference;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

public class ContainerManager {

    private final Set<ContainerRef> mContainerRefs = new HashSet<ContainerRef>();
    /**
     * 记录当前最上层的容器
     */
    private Stack<WeakReference<Object>> stackTop = new Stack<>();

    void setStackTop(Object container) {
        stackTop.add(new WeakReference<>(container));

    }

    void removeStackTop(Object container) {
        if (stackTop.empty()) return;
        if (stackTop.peek().get() == container) {
            stackTop.pop();
        }
    }


    public Object getCurrentStackTop() {
        if (stackTop.empty()) return null;
        return stackTop.peek().get();
    }


    public void addContainer(String uniqueId, Activity container) {
        ContainerRef containerRef = new ContainerRef(uniqueId, container);
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

    public Object findContainerById(String uniqueId) {
        for (ContainerRef ref : mContainerRefs) {
            if (TextUtils.equals(uniqueId, ref.uniqueId)) {
                return ref.container.get();
            }
        }
        return null;
    }


    public static class ContainerRef {
        public final String uniqueId;
        public final WeakReference<Object> container;

        ContainerRef(String id, Object container) {
            this.uniqueId = id;
            this.container = new WeakReference<>(container);
        }
    }
}
