import { FlutterBoostRouteOptions } from 'flutter_boost';

export class RouterModule {
    static routeStack: NavPathStack | null = null;

    public static setRouteStack(stack: NavPathStack): void {
        RouterModule.routeStack = stack;
    }

    public static push(name: string, options: ESObject = {}, onPageResult?: (pageName: string, result: Record<string, Object>) => void): void {
        if (RouterModule.routeStack != null) {
            RouterModule.routeStack.pushPath({name: name, param: options, onPop: (popInfo: PopInfo) => {
              if (onPageResult) {
                //如果前一页面是flutter页面，请务必将popInfo.result的类型转换成Record<string, Object> ！！！
                onPageResult((options instanceof FlutterBoostRouteOptions) ? (options as FlutterBoostRouteOptions).getPageName() : name,
                    (popInfo && popInfo.result) ? (popInfo.result as Record<string, Object>) : ({} as Record<string, Object>));
              }
            }});
        } else {
            throw new Error('routeStack is null!');
        }
    }

    public static pop(result: Record<string, Object> = {}): void {
        if (RouterModule.routeStack != null) {
            RouterModule.routeStack.pop(result);
        } else {
            throw new Error('routeStack is null!');
        }
    }
}