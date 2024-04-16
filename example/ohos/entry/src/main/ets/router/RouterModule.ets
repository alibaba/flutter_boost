
export class RouterOptions {
    constructor(uri: string, params: object | null) {
        this.uri = uri;
        this.params = params;
    }
    uri: string;
    params: object | null = null;
}

export class RouterModule {
    static routerStack: NavPathStack | null = null;

    public static setRouterStack(stack: NavPathStack): void {
        RouterModule.routerStack = stack;
    }

    public static push(name: string, param?: object): void {
        if (RouterModule.routerStack != null) {
            RouterModule.routerStack.pushPath({name: name, param: param});
        } else {
            throw new Error('routerStack is null!');
        }
    }

    public static pop(): void {
        if (RouterModule.routerStack != null) {
            RouterModule.routerStack.pop();
        } else {
            throw new Error('routerStack is null!');
        }
    }
}