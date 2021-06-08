import UIKit
import flutter_boost

@UIApplicationMain
class AppDelegate:UIResponder, UIApplicationDelegate  {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        //主页
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(title: "首页", image: nil, tag: 0)
    
        
        //flutter的tab 页
        let hybridViewController = HybridViewController()
        hybridViewController.tabBarItem = UITabBarItem(title: "flutter页", image: nil, tag: 1)
        
        
        //创建代理，做初始化操作
        let delegate = BoostDelegate()
        FlutterBoost.instance().setup(application, delegate: delegate) { engine in
            
        }
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([homeViewController,hybridViewController], animated: false)
        let navigationViewController = UINavigationController(rootViewController: tabBarController)
        navigationViewController.navigationBar.isHidden = true
        self.window?.rootViewController = navigationViewController
        
       
        //这里将navigationController 给delegate，让delegate具有导航能力
        delegate.navigationController = navigationViewController
        
        
        //在主窗口上放一个button，用来给flutter侧发送自定义事件
        let sendEventButton = UIButton()
        sendEventButton.addTarget(self, action: #selector(self.onTapSendEventButton), for:.touchUpInside)
        sendEventButton.setTitle("Send event to flutter", for: .normal)
        
        self.window?.addSubview(sendEventButton)
        
        sendEventButton.snp.makeConstraints { (mkr) in
            mkr.centerX.equalToSuperview()
            mkr.top.equalToSuperview().offset(120)
        }
        sendEventButton.backgroundColor = UIColor.red
        
        return true
    }
    
    @objc func onTapSendEventButton(){
        //发送自定义事件
        FlutterBoost.instance().sendEventToFlutter(with: "event", arguments: ["data":"event from native"])
    }
    
}
