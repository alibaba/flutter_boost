import Curves from '@ohos.curves'
import hilog from '@ohos.hilog';
import { FlutterBoostEntry } from 'flutter_boost';
import { FlutterPage, FlutterView } from '@ohos/flutter_ohos';

const TAG: string = "FlutterUIComponent";
@Component
export struct FlutterUIComponent {
  @Prop uri: string;
  @Prop params: Record<string, Object>;
  @Prop xComponentType: XComponentType = XComponentType.SURFACE;

  private flutterEntry: FlutterBoostEntry | null = null;
  private flutterView?: FlutterView;
  private effect: object =
    TransitionEffect.OPACITY
      .combine(TransitionEffect.move(TransitionEdge.END)).animation({curve: Curves.springMotion()});

  aboutToAppear() {
    hilog.info(0x0000, TAG, 'Component(#%{public}s) aboutToAppear===', this.uri);
    this.flutterEntry = new FlutterBoostEntry(getContext(this), {
      uri: this.uri,
      params: this.params,
    });
    this.flutterEntry.aboutToAppear();
    // The |aboutToAppear| method is called first,
    // followed by the |getFlutterView| method.
    this.flutterView = this.flutterEntry.getFlutterView();
  }

  aboutToDisappear() {
    hilog.info(0x0000, TAG, 'Component(#%{public}s) aboutToDisappear===', this.uri);
    this.flutterEntry?.aboutToDisappear()
  }

  onPageShow() {
    hilog.info(0x0000, TAG, 'Component(#%{public}s) onPageShow===', this.uri);
    this.flutterEntry?.onPageShow()
  }

  onPageHide() {
    hilog.info(0x0000, TAG, 'Component(#%{public}s) onPageHide===', this.uri);
    this.flutterEntry?.onPageHide()
  }

  build() {
    Stack() {
      FlutterPage({
        viewId: this.flutterView?.getId(),
        xComponentType: this.xComponentType
      })
    }
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (isVisible) {
        this.onPageShow();
      } else {
        this.onPageHide();
      }
    })
    .transition(this.effect)
  }
}