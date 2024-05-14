
export class RouterOptions {
    constructor(uri: string, uniqueId: string, params: object | null) {
        this.uri = uri;
        this.uniqueId = uniqueId;
        this.params = params;
    }
    uri: string;
    uniqueId: string;  //业务自定义路由参数中需要包含uniqueId，避免丢失dart侧传过来的uniqueId
    params: object | null = null;
}

export class RouterModule {
    static routeStack: NavPathStack | null = null;

    public static setRouteStack(stack: NavPathStack): void {
        RouterModule.routeStack = stack;
    }

    public static push(name: string, param?: object): void {
        if (RouterModule.routeStack != null) {
            RouterModule.routeStack.pushPath({name: name, param: param});
        } else {
            throw new Error('routeStack is null!');
        }
    }

    public static pop(): void {
        if (RouterModule.routeStack != null) {
            RouterModule.routeStack.pop();
        } else {
            throw new Error('routeStack is null!');
        }
    }
}