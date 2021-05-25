//
//  HomeViewController.swift
//  Runner
//
//  Created by luckysmg on 2021/5/21.
//

import UIKit
import flutter_boost

//首页
class HomeViewController: UIViewController {
    
    
    //您需要关心下面这两个函数里面内容即可
    
    ///例子：push flutter页面
    @objc func onTapPushButton() {
        //创建options，进行open操作的构建
        let options = FlutterBoostRouteOptions()
        options.pageName = "mainPage"
        options.arguments = ["data":textField.text ?? ""]
        
        //这个是push操作完成的回调，而不是页面关闭的回调！！！！
        options.completion = { completion in
            print("open operation is completed")
        }
        
        //这个是页面关闭并且返回数据的回调，回调实际需要根据您的Delegate中的popRoute来调用
        options.onPageFinished = { dic in
            if let data = dic?["data"] as? String{
                self.resultLabel.text = "return data is: \(data)"
            }
        }
        
        FlutterBoost.instance().open(options)
    }
    
    ///例子：present flutter 透明dialog页面
    @objc func onTapPresentDialogButton(){
        
        let options = FlutterBoostRouteOptions()
        options.pageName = "dialogPage"
        
        //这个属性需要设置，否则不透明
        options.opaque = false
        FlutterBoost.instance().open(options)
    }
    
    ///将原生页面数据返回flutter端
    @objc func onTapReturnDataButton(){
        //将原生的数据返回flutter端，注意这句话并不会退出页面
        FlutterBoost.instance().sendResultToFlutter(withPageName: "homePage", arguments: ["data":textField.text ?? ""])
        //退出页面
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    //下面的代码无需您关心!
    //===================================================
    //===================================================
    //===================================================
    
    var dataString:String?
    
    lazy var pushPageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Push flutter page", for: .normal)
        button.addTarget(self, action: #selector(self.onTapPushButton), for: .touchUpInside)
        button.backgroundColor = UIColor.red
        button.contentEdgeInsets = .init(top: 10, left: 15, bottom: 10, right: 15)
        button.layer.cornerRadius = 4
        return button
    }()
    
    lazy var presentDialogButton: UIButton = {
        let button = UIButton()
        button.setTitle("present flutter dialog", for: .normal)
        button.addTarget(self, action: #selector(self.onTapPresentDialogButton), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        button.contentEdgeInsets = .init(top: 10, left: 15, bottom: 10, right: 15)
        button.layer.cornerRadius = 4
        return button
    }()
    
    lazy var returnButton: UIButton = {
        let button = UIButton()
        button.setTitle("Return data if needed", for: .normal)
        button.addTarget(self, action: #selector(self.onTapReturnDataButton), for: .touchUpInside)
        button.backgroundColor = UIColor.orange
        button.contentEdgeInsets = .init(top: 10, left: 15, bottom: 10, right: 15)
        button.layer.cornerRadius = 4
        return button
    }()
    
    lazy var dataLabel: UILabel = {
        let l = UILabel()
        l.text = "data passed in is: \(dataString ?? "")"
        return l
    }()
    
    lazy var resultLabel: UILabel = {
        let resultLabel = UILabel()
        resultLabel.text = "return data is: "
        return resultLabel
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        textField.placeholder = "input data"
        textField.layer.cornerRadius = 4
        return textField
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(dataLabel)
        self.view.addSubview(returnButton)
        self.view.addSubview(pushPageButton)
        self.view.addSubview(resultLabel)
        self.view.addSubview(textField)
        self.view.addSubview(presentDialogButton)
        
        
        self.pushPageButton.snp.makeConstraints { (mkr) in
            mkr.centerX.equalToSuperview()
            mkr.centerY.equalToSuperview().offset(-50)
        }
        
        self.presentDialogButton.snp.makeConstraints { (mkr) in
            mkr.top.equalTo(self.pushPageButton.snp.bottom).offset(20)
            mkr.centerX.equalToSuperview()
        }
        
        self.dataLabel.snp.makeConstraints { (mkr) in
            mkr.top.equalTo(self.presentDialogButton.snp.bottom).offset(20)
            mkr.centerX.equalToSuperview()
        }
        
        self.resultLabel.snp.makeConstraints { mkr in
            mkr.top.equalTo(dataLabel.snp.bottom).offset(20)
            mkr.centerX.equalToSuperview()
        }
        
        self.textField.snp.makeConstraints { (mkr) in
            mkr.top.equalTo(self.resultLabel.snp.bottom).offset(20)
            mkr.height.equalTo(40)
            mkr.width.equalTo(200)
            mkr.centerX.equalToSuperview()
        }
        
        self.returnButton.snp.makeConstraints { (mkr) in
            mkr.top.equalTo(self.textField.snp.bottom).offset(20)
            mkr.centerX.equalToSuperview()
        }
    }
}

import SwiftUI

struct HomePreview : PreviewProvider{
    static var previews: some View{
        Container().edgesIgnoringSafeArea(.all)
    }
    
    struct Container : UIViewControllerRepresentable {
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
        
        func makeUIViewController(context: Context) -> UIViewController {
            HomeViewController()
        }
    }
}


