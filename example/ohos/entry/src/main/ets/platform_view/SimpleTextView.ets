import common from '@ohos.app.ability.common';
import PlatformView from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { DVModel } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicView';
import { createDVModelFromJson } from '@ohos/flutter_ohos/src/main/ets/view/DynamicView/dynamicViewJson';

export class SimpleTextView extends PlatformView {
  private viewId: number;
  private model: DVModel;

  constructor(context: common.Context, viewId: number, args: ESObject) {
    super()
    this.viewId = viewId;
    this.model = this.createDVModel();
  }

  private createDVModel(): DVModel {
    return createDVModelFromJson(
      {
        compType: "Column",
        attributes: {
          backgroundColor: '#F1F3F5',
          height: '100%',
          width: '100%'
        },
        children: [
          {
            compType: "Text",
            attributes: {
              value: "PlatformView: #" + this.viewId.toString(),
              fontSize: 18,
            },
          },
          {
            compType: "Text",
            attributes: {
              value: "Hi, there! I'm from ArkUI.",
              fontColor: '#0D9FFB',
              fontSize: 18,
              marginTop: 20,
            },
          }
        ],
      }
    );
  }

  getView(): DVModel {
    return this.model;
  }

  dispose(): void {
  }
}