import { RouterNameConstants } from '../constants/RouterConstants';
import { FlutterBoostUtils } from 'flutter_boost';

export class RouterOptions {
    constructor(uri: string, params: Record<string, Object>, uniqueId: string | null) {
        this.uri = uri;
        this.params = params;
        this.uniqueId = uniqueId;
    }
    //！！！业务自定义的路由参数中，务必保证uri、params、uniqueId这三个属性的名字跟example中的保持一致 ！！！
    uri: string;
    params: Record<string, Object>;
    uniqueId: string | null = null;  //！！！业务自定义路由参数中必须要包含uniqueId，避免丢失dart侧传过来的uniqueId ！！！
}

export class RouterModule {
    static routeStack: NavPathStack | null = null;

    public static setRouteStack(stack: NavPathStack): void {
        RouterModule.routeStack = stack;
        RouterModule.routeStack.setInterception({
            willShow: (from: NavDestinationContext | "navBar", to: NavDestinationContext | "navBar",
                operation: NavigationOperation, animated: boolean) => {
                let target: NavDestinationContext;
                let params: Record<string, Object>;
                if (operation === NavigationOperation.POP) {
                    target = from as NavDestinationContext;
                    if (target.pathInfo.name !== RouterNameConstants.FLUTTER_PAGE) return;
                    params = (target.pathInfo.param as RouterOptions).params;
                    if (params['OHFB_routerOptionsOfPageB'] && params['OHFB_routerOptionsOfPageB'] instanceof RouterOptions) {
                        target.pathStack!.pushPath({name: target.pathInfo.name, param: params['OHFB_routerOptionsOfPageB'] as RouterOptions});
                    }
                } else if (operation === NavigationOperation.PUSH) {
                    target = to as NavDestinationContext;
                    if (target.pathInfo.name !== RouterNameConstants.FLUTTER_PAGE) return;
                    params = (target.pathInfo.param as RouterOptions).params;
                    if (params['FB_hopRouteEnabled']) {
                        let nameOfPageC: string = params['FB_hopRoutePageC']! as string;
                        let argsOfPageC: Record<string, Object> = (params['FB_hopRouteArgsOfPageC'] ?? {}) as Record<string, Object>;
                        let routerOptionsOfPageB:RouterOptions = target.pathInfo.param as RouterOptions;
                        let map:Map<string, Object> = FlutterBoostUtils.recordToMap(routerOptionsOfPageB.params);
                        map.delete('FB_hopRouteArgsOfPageC');  //将B的路由参数中的pageC的args删除，避免循环包含
                        routerOptionsOfPageB.params = FlutterBoostUtils.mapToRecord(map);
                        argsOfPageC['OHFB_routerOptionsOfPageB'] = routerOptionsOfPageB;
                        target.pathStack!.replacePath({name: target.pathInfo.name, param: new RouterOptions(nameOfPageC, argsOfPageC, null)});
                    }
                }
            }
        })
    }

    public static push(name: string, options: RouterOptions | Record<string, Object> = {}, onPageResult?: (pageName: string, result: Record<string, Object>) => void): void {
        if (RouterModule.routeStack != null) {
            RouterModule.routeStack.pushPath({name: name, param: options, onPop: (popInfo: PopInfo) => {
              if (onPageResult) {
                //如果前一页面是flutter页面，请务必将popInfo.result的类型转换成Record<string, Object> ！！！
                onPageResult((options instanceof RouterOptions) ? (options as RouterOptions).uri : name,
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