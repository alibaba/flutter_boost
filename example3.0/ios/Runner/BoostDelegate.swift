//
//  BoostDelegate.swift
//  Runner
//
//  Created by luckysmg on 2021/5/21.
//

import UIKit
import flutter_boost

class BoostDelegate: NSObject,FlutterBoostDelegate {
    
    ///您用来push的导航栏
    var navigationController:UINavigationController?
    
    ///用来存返回flutter侧返回结果的表
    var resultTable:Dictionary<String,([AnyHashable:Any]?)->Void> = [:];
    
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
        let vc:FBFlutterViewContainer = FBFlutterViewContainer()
        vc.setName(options.pageName, uniqueId: options.uniqueId, params: options.arguments,opaque: options.opaque)
        
        //用参数来控制是push还是pop
        let isPresent = (options.arguments?["isPresent"] as? Bool)  ?? false
        let isAnimated = (options.arguments?["isAnimated"] as? Bool) ?? true
        
        //对这个页面设置结果
        resultTable[vc.uniqueIDString()] = options.onPageFinished;
        
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
            //pop场景
            
            //找到和要移除的id对应的vc
            guard let viewControllers = self.navigationController?.viewControllers else{
                return
            }
            
            var containerToRemove:FBFlutterViewContainer?
            for item in viewControllers.reversed() {
                if let container = item as? FBFlutterViewContainer,container.uniqueIDString() == options.uniqueId {
                    containerToRemove = container
                    break
                }
            }
            if(containerToRemove == nil){
                fatalError("uniqueId is wrong!!!")
            }
            
            if self.navigationController?.topViewController == containerToRemove {
                self.navigationController?.popViewController(animated: true)
            }else{
                containerToRemove?.removeFromParent()
            }
        }
        
        //这里在pop的时候将参数带出,并且从结果表中移除
        if let onPageFinshed = resultTable[options.uniqueId] {
            onPageFinshed(options.arguments)
            resultTable.removeValue(forKey: options.uniqueId)
        }
        
    }
}
