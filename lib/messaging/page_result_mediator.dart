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

typedef void PageResultHandler(String key , Map<dynamic,dynamic> result);
typedef VoidCallback = void Function();

class PageResultMediator{

  Map<String,PageResultHandler> _handlers = Map();
  void onPageResult(String key , Map<dynamic,dynamic> resultData){

    if(key == null) return;

    Logger.log("did receive page result $resultData for page key $key");

    if(_handlers.containsKey(key)){
      _handlers[key](key,resultData);
      _handlers.remove(key);
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