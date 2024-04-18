
export class RouterOptions {
    constructor(uri: string, params: object | null) {
        this.uri = uri;
        this.params = params;
    }
    uri: string;
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