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
import 'logger.dart';

class Tracer {
  static final Tracer singleton = Tracer();

  final Map<String, Record> _records = <String, Record>{};
  Tracer();

  static String mark(String unique, String tag) {
    Record record = singleton._records[unique];

    if (record == null) {
      record = Record()
        ..unique = unique
        ..marks = <Mark>[];
      singleton._records[unique] = record;
    }

    record.marks.add(Mark(tag, DateTime.now()));

    return record.toString();
  }

  static void markAndLog(String unique, String tag) {
    Logger.log(mark(unique, tag));
  }

  static String dump(String unique) => singleton._records[unique]?.toString();
}

class Record {
  String unique;
  List<Mark> marks;

  @override
  String toString() {
    if (marks == null || marks.isEmpty) {
      return '';
    }

    if (marks.length == 1) {
      return marks.first.tag;
    }

    Mark least = marks.first;
    String info = 'trace<$unique>#${least.tag}';
    for (int i = 1; i < marks.length; i++) {
      final Mark mark = marks[i];
      info =
          '$info=${mark.timeStamp.millisecond - least.timeStamp.millisecond}ms=>${mark.tag}';
      least = mark;
    }

    return info;
  }
}

class Mark {
  String tag;
  DateTime timeStamp;

  Mark(this.tag, this.timeStamp);
}
