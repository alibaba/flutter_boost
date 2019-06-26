/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 Alibaba Group
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import 'dart:async';

import 'package:flutter_boost/container/boost_container.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost/messaging/boost_message_channel.dart';

class Router {


  Future<Map<dynamic,dynamic>> open(String url,{Map<dynamic,dynamic> urlParams,Map<dynamic,dynamic> exts}){
    return BoostMessageChannel.openPage(url,urlParams, exts);
  }

  Future<bool> close(String id,{Map<dynamic,dynamic> result,Map<dynamic,dynamic> exts}){
    return BoostMessageChannel.closePage(id,result:result,exts: exts);
  }


  //Close currentPage page.
  Future<bool> closeCurPage(Map params) {
    BoostContainerSettings settings;

    final BoostContainerState container =
        FlutterBoost.containerManager.onstageContainer;

    if (container != null) {
      settings = container.settings;
    } else {
      settings = FlutterBoost.containerManager.onstageSettings;
    }

    if (settings == null) {
      return Future<bool>(() {
        return false;
      });
    }

    bool animated = true;
    if (params.containsKey("animated")) {
      animated = params["animated"] as bool;
    }

    Map<String,dynamic> exts = Map();
    exts["animated"] = animated;

    return BoostMessageChannel.closePage(settings.uniqueId,result: {} ,exts: exts);
  }
}
