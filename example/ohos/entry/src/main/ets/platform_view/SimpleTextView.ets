import common from '@ohos.app.ability.common';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';

@Component
struct TextComponent {
  @Prop params: Params
  embededView: SimpleTextView = this.params.platformView as SimpleTextView

  build() {
    Column() {
      Text(`PlatformView: #${this.embededView.getViewId()}`)
        .fontSize(18)
      Text("Hi, there! I'm from ArkUI.")
        .fontColor('#0D9FFB')
        .fontSize(18)
        .margin(18)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
    .width('100%')
    .height('100%')
  }
}

@Builder
function TextBuilder(params: Params) {
  TextComponent({ params: params })
    .backgroundColor('#F1F3F5')
}

@Observed
export class SimpleTextView extends PlatformView {
  private viewId: number;

  constructor(context: common.Context, viewId: number, args: ESObject) {
    super()
    this.viewId = viewId;
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(TextBuilder);
  }

  getViewId(): number {
    return this.viewId;
  }

  dispose(): void {
  }
}