// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.idlefish.flutterboost;

public interface FlutterBoostDelegate {
    void pushNativeRoute(FlutterBoostRouteOptions options);
    void pushFlutterRoute(FlutterBoostRouteOptions options);
    default boolean popRoute(FlutterBoostRouteOptions options){
        return  false;
    }
}
