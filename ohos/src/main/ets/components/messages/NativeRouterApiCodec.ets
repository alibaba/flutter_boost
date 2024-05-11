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
import { StandardMessageCodec } from '@ohos/flutter_ohos';
import { ByteBuffer } from '@ohos/flutter_ohos/src/main/ets/util/ByteBuffer';
import CommonParams from './CommonParams';
import FlutterContainer from './FlutterContainer';
import FlutterPage from './FlutterPage';
import StackInfo from './StackInfo';

export default class NativeRouterApiCodec extends StandardMessageCodec {
  public static INSTANCE = new NativeRouterApiCodec();

  writeValue(stream: ByteBuffer, value: ESObject): void {
    if (value instanceof CommonParams) {
      const commonParams: CommonParams = value as CommonParams;
      stream.writeInt8(128)
      this.writeValue(stream, commonParams.toMap());
    } else if (value instanceof FlutterContainer) {
      const flutterContainer: FlutterContainer = value as FlutterContainer;
      stream.writeInt8(129)
      this.writeValue(stream, flutterContainer.toMap());
    } else
    if (value instanceof FlutterPage) {
      const flutterPage: FlutterPage = value as FlutterPage;
      stream.writeInt8(130)
      this.writeValue(stream, flutterPage.toMap());
    } else
    if (value instanceof StackInfo) {
      const stackInfo: StackInfo = value as StackInfo;
      stream.writeInt8(131)
      this.writeValue(stream, stackInfo.toMap());
    } else {
      super.writeValue(stream, value);
    }
  }

  readValueOfType(type: number, buffer: ByteBuffer): ESObject {
    switch (type) {
      case 128:
        return CommonParams.fromObject(super.readValue(buffer))

      case 129:
        return FlutterContainer.fromMap(super.readValue(buffer))

      case 130:
        return FlutterPage.fromMap(super.readValue(buffer))

      case 131:
        return StackInfo.fromMap(super.readValue(buffer))

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}
