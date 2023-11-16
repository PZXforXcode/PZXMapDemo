//
//  AppDelegate.swift
//  PZXSwiftProject
//
//  Created by 彭祖鑫 on 2021/5/27.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        settingIQKeyBoardManager()
        GMSServices.provideAPIKey("AIzaSyBX_qjaHcVEgKjvnb1Hv4zJm5fIM7OIlI0")
        
        return true
    }
    
    //MARK: 键盘监控设置
    func settingIQKeyBoardManager() {
        IQKeyboardManager.shared.enable = true
    }
    
}

extension AppDelegate {
    
    
    
}
