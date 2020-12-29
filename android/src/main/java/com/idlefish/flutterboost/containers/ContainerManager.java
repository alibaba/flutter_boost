package com.idlefish.flutterboost.containers;

import java.util.Stack;

public class ContainerManager {

    private final Stack<Object> mRecordStack = new Stack<Object>();

    void push(Object container) {
        mRecordStack.push(container);
    }

    void pop(Object container) {
        if (mRecordStack.empty()) return;

        if (mRecordStack.peek() == container) {
            mRecordStack.pop();
        }
    }

    void remove(Object container) {
        mRecordStack.remove(container);

    }

    public Object getCurrentTop() {
        if (mRecordStack.isEmpty()) return null;
        return mRecordStack.peek();
    }


}
