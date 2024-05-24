import { FlutterBoostRouteResult } from 'flutter_boost';

export class RouterOptions {
    constructor(uri: string, params: Record<string, Object>, uniqueId: string | null) {
        this.uri = uri;
        this.params = params;
        this.uniqueId = uniqueId;
    }
    uri: string;
    params: Record<string, Object>;
    uniqueId: string | null = null;  //业务自定义路由参数中需要包含uniqueId，避免丢失dart侧传过来的uniqueId
}

export class RouterModule {
    static routeStack: NavPathStack | null = null;

    public static setRouteStack(stack: NavPathStack): void {
        RouterModule.routeStack = stack;
    }

    public static push(name: string, routerOptions?: RouterOptions, onPageResult?: (pageName: string, result: Record<string, Object>) => void): void {
        if (RouterModule.routeStack != null) {
            RouterModule.routeStack.pushPath({name: name, param: routerOptions, onPop: (popInfo: PopInfo) => {
              if (onPageResult) {
                onPageResult(routerOptions ? routerOptions.uri : "native",
                    (popInfo && popInfo.result) ? ((popInfo.result as FlutterBoostRouteResult).result) : ({} as Record<string, Object>));
              }
            }});
        } else {
            throw new Error('routeStack is null!');
        }
    }

    public static pop(result: Record<string, Object> = {}): void {
        if (RouterModule.routeStack != null) {
            RouterModule.routeStack.pop(new FlutterBoostRouteResult(result));
        } else {
            throw new Error('routeStack is null!');
        }
    }
}