//
//  ChargeGunViewController.swift
//  PZXMapDemo
//
//  Created by 彭祖鑫 on 2023/11/23.
//

import UIKit

class ChargeGunViewController: RootViewController {

    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setSubviews()
        removeQrVC()
    }
    //MARK: – UI
    // subviews
    func setSubviews(){
        
        self.titleLabel.text = "充电枪页面"
        
        self.view.backgroundColor = RandomColor()
        
    }
    
    //MARK: – request
    // 获取服务数据
    
    
    //MARK: – 填充数据
    // 填充数据
    
    
    //MARK: – 点击事件
    
    
    //MARK: – Public Method
    // 公有方法
    
    
    //MARK: – Private Method
    // 私有方法
    fileprivate func removeQrVC() {
        if var naviVCsArr = self.navigationController?.viewControllers {
            for (index, vc) in naviVCsArr.enumerated() {
                if vc is QRCodeScannerViewController {
                    naviVCsArr.remove(at: index)
                    break
                }
            }
            self.navigationController?.viewControllers = naviVCsArr
        }
    }

}
