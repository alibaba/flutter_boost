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
import 'package:flutter_boost/support/logger.dart';
import 'package:flutter_boost/AIOService/NavigationService/service/NavigationService.dart';

typedef void PageResultHandler(String key , Map<String,dynamic> result);
typedef VoidCallback = void Function();

class PageResultMediator{

  static int _resultId = 0;

  String createResultId(){
    _resultId++;
    return "result_id_$_resultId";
  }

  bool isResultId(String rid){
    if(rid == null) return false;
    return rid.contains("result_id");
  }

  Map<String,PageResultHandler> _handlers = Map();
  void onPageResult(String key , Map<String,dynamic> resultData, Map params){

    if(key == null) return;

    Logger.log("did receive page result $resultData for page key $key");

    if(_handlers.containsKey(key)){
      _handlers[key](key,resultData);
      _handlers.remove(key);
    }else{
      //Cannot find handler consider forward to native.
      //Use forward to avoid circle.
      if(params == null || !params.containsKey("forward")){
        if(params == null){
          params = new Map();
        }
        params["forward"] = 1;
        NavigationService.onFlutterPageResult(key, key , resultData, params);
      }else{
        params["forward"] = params["forward"]+1;
        if(params["forward"] <= 2){
          NavigationService.onFlutterPageResult(key, key , resultData, params);
        }
      }

    }
  }

  VoidCallback setPageResultHandler(String key, PageResultHandler handler){
    if(key == null || handler == null) return (){};
    _handlers[key] = handler;
    return (){
      _handlers.remove(key);
    };
  }

}
