package com.idlefish.flutterboost.utils;
import android.os.Bundle;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class BundleUtil {

    public static Map<Object, Object> bundleToMap(Bundle bundle) {
        Map<Object, Object> map = new HashMap<>();
        if(bundle == null || bundle.keySet().size() == 0) {
            return map;
        }
        Set<String> keys = bundle.keySet();
        for (String key : keys) {
            Object value = bundle.get(key);
            if(value instanceof Bundle) {
                map.put(key, bundleToMap(bundle.getBundle(key)));
            } else if (value != null){
                map.put(key, value);
            }
        }
        return map;
    }
}
