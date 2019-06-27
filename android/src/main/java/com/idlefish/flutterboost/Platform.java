package com.idlefish.flutterboost;

import com.idlefish.flutterboost.interfaces.IContainerRecord;
import com.idlefish.flutterboost.interfaces.IPlatform;

import java.util.Map;

public abstract class Platform implements IPlatform {

    @Override
    public void closeContainer(IContainerRecord record, Map<String, Object> result, Map<String, Object> exts) {
        if(record == null) return;

        record.getContainer().finishContainer(result);
    }

    @Override
    public int whenEngineStart() {
        return ANY_ACTIVITY_CREATED;
    }
}
