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
#import <flutter_boost/FlutterBoost.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    
    
    [self.window makeKeyAndVisible];
    
   
    UIViewControllerDemo *vc = [[UIViewControllerDemo alloc] initWithNibName:@"UIViewControllerDemo" bundle:[NSBundle mainBundle]];
    vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"hybrid" image:nil tag:0];
   
    
    UIViewController *fvc = UIViewController.new;
//    [fvc setName:@"tab" params:@{}];
    fvc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"flutter_tab" image:nil tag:1];
    
    
    UITabBarController *tabVC = [[UITabBarController alloc] init];
    UINavigationController *rvc = [[UINavigationController alloc] initWithRootViewController:tabVC];
    
    tabVC.viewControllers = @[vc,fvc];
    
    self.window.rootViewController = rvc;
    
    
  
    
    
    
    
    UIButton *nativeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nativeButton.frame = CGRectMake(self.window.frame.size.width * 0.5 - 60, 150, 130, 45);
    nativeButton.backgroundColor = [UIColor redColor];
    [nativeButton setTitle:@"push native" forState:UIControlStateNormal];
    [nativeButton addTarget:self action:@selector(pushNative) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:nativeButton];
    
    UIButton *startEngine = [UIButton buttonWithType:UIButtonTypeCustom];
    startEngine.frame = CGRectMake(self.window.frame.size.width * 0.5 - 60, 230, 130, 40);
    startEngine.backgroundColor = [UIColor redColor];
    [startEngine setTitle:@"start engine" forState:UIControlStateNormal];
    [startEngine addTarget:self action:@selector(startFlutter:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:startEngine];
    
    UIButton *destroyEngine = [UIButton buttonWithType:UIButtonTypeCustom];
    destroyEngine.frame = CGRectMake(self.window.frame.size.width * 0.5 - 60, 300, 130, 40);
    destroyEngine.backgroundColor = [UIColor redColor];
    [destroyEngine setTitle:@"destroy engine" forState:UIControlStateNormal];
    [destroyEngine addTarget:self action:@selector(destroyFlutter:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:destroyEngine];
    
    
    return YES;
}

- (void)startFlutter:(id)sender {
    PlatformRouterImp *router = [PlatformRouterImp new];
    router.navigationController = (UINavigationController*)self.window.rootViewController;
    [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform:router
                                                        onStart:^(FlutterEngine *engine) {
                                                            
                                                        }];
}

- (void)destroyFlutter:(id)sender {
    
    //切记：在destroyEngine前务必将所有FlutterViewController及其子类的实例销毁。在这里是FLBFlutterViewContainer。否则会异常;以下是全部步骤
    //1. 首先通过为所有FlutterPlugin的methodChannel属性设为nil来接触其与FlutterEngine的间接强引用
    //2. 销毁所有的FlutterViewController实例，来解除其与FlutterEngine的强引用
    //3. 调用FlutterBoostPlugin.destroyEngine函数来解除与FlutterEngine的强引用
    [FlutterBoostPlugin.sharedInstance destroyEngine];
}

- (void)pushNative
{
    UINavigationController *nvc = (id)self.window.rootViewController;
    UIViewControllerDemo *vc = [[UIViewControllerDemo alloc] initWithNibName:@"UIViewControllerDemo" bundle:[NSBundle mainBundle]];
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
