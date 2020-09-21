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
import 'dart:ui';

class ObserversHolder {
  final Map<String, Set<dynamic>> _observers = <String, Set<dynamic>>{};

  VoidCallback addObserver<T>(T observer) {
    final Set<T> set = _observers[T.toString()] as Set<T> ?? <T>{};

    set.add(observer);
    _observers[T.toString()] = set;

    return () => set.remove(observer);
  }

  void removeObserver<T>(T observer) =>
      _observers[T.toString()]?.remove(observer);

  void cleanObservers<T>() => _observers[T.toString()]?.clear();

  Set<T> observersOf<T>() => _observers[T.toString()] as Set<T> ?? <T>{};
}
