//
//  AppDelegate.m
//  sdfsdf
//
//  Created by Jidong Chen on 2018/10/18.
//  Copyright © 2018年 Jidong Chen. All rights reserved.
//

#import "AppDelegate.h"
#import "UIViewControllerDemo.h"
#import "PlatformRouterImp.h"
#import "NativeViewController.h"
#import <flutter_boost/FlutterBoost.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    PlatformRouterImp *router = [PlatformRouterImp new];
    [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform:router
                                                        onStart:^(FlutterEngine *engine) {
        
        // 注册MethodChannel，监听flutter侧的getPlatformVersion调用
        FlutterMethodChannel *flutterMethodChannel = [FlutterMethodChannel methodChannelWithName:@"flutter_native_channel" binaryMessenger:engine.binaryMessenger];
        
        [flutterMethodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            
            NSString *method = call.method;
            if ([method isEqualToString:@"getPlatformVersion"]) {
                NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
                result(sysVersion);
            } else {
                result(FlutterMethodNotImplemented);
            }
            
        }];
    }];
    
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    
    
    [self.window makeKeyAndVisible];
    
   
    UIViewControllerDemo *vc = [[UIViewControllerDemo alloc] initWithNibName:@"UIViewControllerDemo" bundle:[NSBundle mainBundle]];
    vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"hybrid" image:nil tag:0];
   
    
    FLBFlutterViewContainer *fvc = FLBFlutterViewContainer.new;
    [fvc setName:@"tab" params:@{}];
    fvc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"flutter_tab" image:nil tag:1];
    
    
    UITabBarController *tabVC = [[UITabBarController alloc] init];
    UINavigationController *rvc = [[UINavigationController alloc] initWithRootViewController:tabVC];
    
   
    router.navigationController = rvc;
    
    tabVC.viewControllers = @[vc,fvc];
    
    self.window.rootViewController = rvc;
    
    UIButton *nativeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nativeButton.frame = CGRectMake(self.window.frame.size.width * 0.5 - 50, 200, 100, 40);
    nativeButton.backgroundColor = [UIColor redColor];
    [nativeButton setTitle:@"push native" forState:UIControlStateNormal];
    [nativeButton addTarget:self action:@selector(pushNative) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:nativeButton];
    
    UIButton *pushEmbeded = [UIButton buttonWithType:UIButtonTypeCustom];
    pushEmbeded.frame = CGRectMake(self.window.frame.size.width * 0.5 - 70, 150, 140, 40);
    pushEmbeded.backgroundColor = [UIColor redColor];
    [pushEmbeded setTitle:@"push embeded" forState:UIControlStateNormal];
    [pushEmbeded addTarget:self action:@selector(pushEmbeded) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:pushEmbeded];
    
    return YES;
}

- (void)pushNative
{
    UINavigationController *nvc = (id)self.window.rootViewController;
    UIViewControllerDemo *vc = [[UIViewControllerDemo alloc] initWithNibName:@"UIViewControllerDemo" bundle:[NSBundle mainBundle]];
    [nvc pushViewController:vc animated:YES];
}

- (void)pushEmbeded
{
    UINavigationController *nvc = (id)self.window.rootViewController;
    UIViewController *vc = [[NativeViewController alloc] init];
    [nvc pushViewController:vc animated:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
