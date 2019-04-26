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
import 'package:flutter_boost/messaging/message_proxy.dart';
import 'package:flutter_boost/messaging/page_result_mediator.dart';
import 'package:flutter_boost/support/logger.dart';

class Router {
  MessageProxy _msgProxy = MessageProxyImp();
  PageResultMediator resultMediator = null;


  void setMessageProxy(MessageProxy prx) {
    if (prx != null) {
      _msgProxy = prx;
    }
  }


  Future<bool> openPage(String url, Map params,
      {bool animated = true, PageResultHandler resultHandler}) {
    if (resultHandler != null) {
      String rid = resultMediator.createResultId();
      params["result_id"] = rid;
      FlutterBoost.singleton.setPageResultHandler(rid,
          (String key, Map<dynamic, dynamic> result) {
        Logger.log("Recieved result $result for from page key $key");
        if (resultHandler != null) {
          resultHandler(key, result);
        }
      });
    }

    return _msgProxy.openPage(url, params, animated);
  }

  Future<bool> closePage(String name, String pageId, Map params,
      {bool animated = true}) {
    return _msgProxy.closePage(pageId, name, params, animated);
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

    return _msgProxy.closePage(
        settings.uniqueId, settings.name, settings.params, animated);
  }
}
