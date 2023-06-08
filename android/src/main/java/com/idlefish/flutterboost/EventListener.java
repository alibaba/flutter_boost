// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.idlefish.flutterboost;

import java.util.Map;

public interface EventListener {
    void onEvent(String key, Map<String, Object> args);
}