//
//  BoostDelegate.swift
//  Runner
//
//  Created by luckysmg on 2021/5/21.
//

import UIKit
import flutter_boost


import UIKit
import flutter_boost

class BoostDelegate: NSObject,FlutterBoostDelegate {
    
    ///您用来push的导航栏
    var navigationController:UINavigationController?
    
    func pushNativeRoute(_ pageName: String!, arguments: [AnyHashable : Any]!) {
        
        //用参数来控制是push还是pop
        let isPresent = arguments["isPresent"] as? Bool ?? false
        let isAnimated = arguments["isAnimated"] as? Bool ?? true
        
        var targetViewController = UIViewController()
        
        if(pageName == "homePage"){
            //这里接收传入的参数
            let data:String = arguments?["data"] as? String ?? ""
            let homeVC = HomeViewController()
            homeVC.dataString = data
            targetViewController = homeVC
        }
        
        if(isPresent){
            self.navigationController?.present(targetViewController, animated: isAnimated, completion: nil)
        }else{
            self.navigationController?.pushViewController(targetViewController, animated: isAnimated)
        }
    }
    
    func pushFlutterRoute(_ options: FlutterBoostRouteOptions!) {
        
        let engine = FlutterBoost.instance().engine()
        engine?.viewController = nil
        
        let vc:FBFlutterViewContainer = FBFlutterViewContainer()
        //给FBFlutterViewContainer设置路由配置
        vc.setRouteOptions(options)

        //用参数来控制是push还是pop
        let isPresent = (options.arguments?["isPresent"] as? Bool)  ?? false
        let isAnimated = (options.arguments?["isAnimated"] as? Bool) ?? true
        
        //如果是present模式 ，或者要不透明模式，那么就需要以present模式打开页面
        if(isPresent || !options.opaque){
            self.navigationController?.present(vc, animated: isAnimated, completion: nil)
        }else{
            self.navigationController?.pushViewController(vc, animated: isAnimated)
        }
    }
    
    func popRoute(_ options: FlutterBoostRouteOptions!) {
        //如果当前被present的vc是container，那么就执行dismiss逻辑
        if let vc = self.navigationController?.presentedViewController as? FBFlutterViewContainer,vc.uniqueIDString() == options.uniqueId{
            
            //这里分为两种情况，由于UIModalPresentationOverFullScreen下，生命周期显示会有问题
            //所以需要手动调用的场景，从而使下面底部的vc调用viewAppear相关逻辑
            if vc.modalPresentationStyle == .overFullScreen {
                
                //这里手动beginAppearanceTransition触发页面生命周期
                self.navigationController?.topViewController?.beginAppearanceTransition(true, animated: false)
                
                vc.dismiss(animated: true) {
                    self.navigationController?.topViewController?.endAppearanceTransition()
                }
            }else{
                //正常场景，直接dismiss
                vc.dismiss(animated: true, completion: nil)
            }
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
