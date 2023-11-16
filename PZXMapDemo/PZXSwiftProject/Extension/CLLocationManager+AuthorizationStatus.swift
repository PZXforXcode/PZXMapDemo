//
//  CLLocationManager+AuthorizationStatus.swift
//  xinyuancar
//
//  Created by 博识iOS One on 2021/1/18.
//

import Foundation

extension CLLocationManager {
    func authorizationStatusAndHandle() {
        let status  = CLLocationManager.authorizationStatus()
        switch status {
            case .notDetermined:
                self.requestAlwaysAuthorization()
            case .denied, .restricted:
                let alertController = UIAlertController(title: "提示", message: "定位服务已关闭，您需要打开定位权限。才可以使用功能。请到设置->隐私一定位服务中开启定位服务。", preferredStyle: .alert)
                let alertAction1 = UIAlertAction(title: "取消", style: .default, handler: nil)
                let alertAction2 = UIAlertAction(title: "系统设置", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if(UIApplication.shared.canOpenURL(url!)) {
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    }
                })
                alertController.addAction(alertAction1)
                alertController.addAction(alertAction2)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                break
            default:
                break
        }
    }
}
