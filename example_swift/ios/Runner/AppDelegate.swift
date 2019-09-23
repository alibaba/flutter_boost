import UIKit
import Flutter
//import flutter_boost

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    
    let router = PlatformRouterImp.init();
    FlutterBoostPlugin.sharedInstance()?.startFlutter(with: router, onStart: { (engine) in
    });
    
    self.window = UIWindow.init(frame: UIScreen.main.bounds)
    let viewController = ViewController.init()
    let navi = UINavigationController.init(rootViewController: viewController)
    self.window.rootViewController = navi
    self.window.makeKeyAndVisible()
    
    return true;//super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
