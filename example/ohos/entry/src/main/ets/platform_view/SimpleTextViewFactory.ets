import common from '@ohos.app.ability.common';
import {
  PlatformView,
  PlatformViewFactory,
  StandardMessageCodec
} from '@ohos/flutter_ohos';
import { SimpleTextView } from './SimpleTextView';

export class SimpleTextViewFactory extends PlatformViewFactory {
  constructor() {
    super(StandardMessageCodec.INSTANCE);
  }

  public create(context: common.Context, viewId: number, args: Object): PlatformView {
    return new SimpleTextView(context, viewId, args);
  }
}