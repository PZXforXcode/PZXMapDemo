//
//  DefineFile.swift
//  PZXSwiftProject
//
//  Created by 彭祖鑫 on 2021/5/27.
//

import Foundation
import UIKit

typealias PZXClosure = () -> Void
typealias PZXBoolValueClosure = (_ isSuccess: Bool,_ value: Any) -> Void

let TAG_NUMBER = 1000

//MARK:=========================Image=========================
let DEFAULT_IMAGE       = "defualt_image"
let DEFAULT_AVATAR      = "defualt_avatar"

//MARK:=========================Frame=========================
public func isIPhoneX() -> Bool {
    if #available(iOS 11, *) {
        guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
            return false
        }
        if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
            return true
        }
    }
    return false
}

let SCREEN_BOUNDS                     = UIScreen.main.bounds
let SCREEN_WIDTH                      = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT                     = UIScreen.main.bounds.size.height

let reference_width: CGFloat         = 375.0
let reference_height: CGFloat        = 667.0

let SCREENT_WIDTH_RATIO              = SCREEN_WIDTH / reference_width
let SCREENT_HEIGHT_RATIO             = SCREEN_HEIGHT / reference_height

let IS_IPHONE_X: Bool!               = isIPhoneX()
//let STATUS_BAR_HEIGHT: CGFloat       = UIApplication.shared.statusBarFrame.size.height
let STATUS_BAR_HEIGHT: CGFloat       = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20
let NAVIGATION_HEIGHT: CGFloat       = 44
let TOP_HEIGHT: CGFloat              =  STATUS_BAR_HEIGHT + NAVIGATION_HEIGHT

let TABBAR_HEIGHT: CGFloat           = IS_IPHONE_X ? 83 : 49

func HorizontalFlexible(_ value: CGFloat) -> CGFloat {
    return value * SCREENT_WIDTH_RATIO
}

func VerticalFlexible(_ value: CGFloat) -> CGFloat {
    return value * SCREENT_HEIGHT_RATIO
}

//MARK:=========================Color=========================
public func RGBColor(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

public func RandomColor(alpha: CGFloat = 1.0) -> UIColor {
    return RGBColor(CGFloat(arc4random()%256), CGFloat(arc4random()%256), CGFloat(arc4random()%256), alpha)
}

public func RCGColorFromeHex(rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
    return UIColor.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,blue: CGFloat(rgbValue & 0x0000FF) / 255.0,alpha: alpha)
}

let GRAYCOLOR1            = RGBColor(51, 51, 51, 1)
let GRAYCOLOR2            = RGBColor(71, 71, 71, 1)
let GRAYCOLOR3            = RGBColor(133, 133, 133, 1)
let GRAYCOLOR4            = RGBColor(179, 179, 179, 1)
let GRAYCOLOR5            = RGBColor(245, 245, 245, 1)
let GRAYCOLOR_line        = RGBColor(245, 245, 245, 1)
let MainColor             = RGBColor(245, 245, 245, 1)
let TitleColor          = RGBColor(51, 51, 51, 1)
let DescribeColor       = RGBColor(153, 153, 153, 1)
let GrayLineColor       = RGBColor(245, 245, 245, 1)

//MARK:=========================Font=========================
public func PZXSystemFont(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: HorizontalFlexible(size))
}

public func PZXBoldSystemFont(_ size: CGFloat) -> UIFont {
    return UIFont.boldSystemFont(ofSize:HorizontalFlexible(size));
}

public func PZXItalicSystemFont(_ size: CGFloat) -> UIFont {
    return UIFont.italicSystemFont(ofSize: HorizontalFlexible(size));
}

//MARK:=========================Moudles=========================
public func PZXKeywindow() -> UIWindow? {
    if #available(iOS 13.0, *) {
        return UIApplication.shared.windows[0]
    }else {
        return UIApplication.shared.keyWindow
    }
}

public func PZXKeyController() -> UIViewController {
    let keyController = (PZXKeywindow()?.rootViewController)!
    return PZXGettingCurrentVCFrom(rootVC: keyController)
}

public func PZXGettingCurrentVCFrom(rootVC: UIViewController) -> UIViewController {
    var currentVC: UIViewController
    var rootViewController = rootVC
    
    //视图是被presented出来的
    if rootViewController.presentedViewController != nil{
        rootViewController = rootViewController.presentedViewController!
    }
    
    if rootViewController.isKind(of: UITabBarController.classForCoder()) {
        //根视图为UITabBarController
        currentVC = PZXGettingCurrentVCFrom(rootVC: (rootViewController as! UITabBarController).selectedViewController!)
    }else if rootViewController.isKind(of: UINavigationController.classForCoder()) {
        //根视图为UINavigationController
        currentVC = PZXGettingCurrentVCFrom(rootVC: (rootViewController as! UINavigationController).visibleViewController!)
    }else {
        //根视图为非导航类
        currentVC = rootVC
    }
    
    return currentVC
}

//MARK:=========================Method=========================
///讲对象安全转换为String,尽量少用
public func StringSafe(_ id : Any?)-> String {
    if(id is String){
        return id as! String
    }
    if(id == nil){
        return ""
    }
    return "\(id!)"
}

///讲对象安全转换为Int,尽量少用
public func IntSafe(_ id : Any?) -> Int {
    if(id is Int){
        return id as! Int
    }
    if(id == nil){
        return 0
    }
    return 0
}

///讲对象安全转换为Float,尽量少用
public func FloatSafe(_ id : Any?) -> Float {
    if(id is Float){
        return id as! Float
    }
    if(id == nil){
        return 0
    }
    
    return 0
}
///Codable转Dic
public func convertToDict(model:Codable) -> Dictionary<String, Any>? {

        var dict: Dictionary<String, Any>? = nil

        do {
            print("init model")
            let encoder = JSONEncoder()

            let data = try encoder.encode(model)
            print("struct convert to data")

            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>

        } catch {
            print(error)
        }

        return dict
    }

//MARK:=========================Other=========================
let PATH_DOCUMENT    = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
let ERROR_ALAERT     = "❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌"
let SUCCESS_ALAERT   = "✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️✌️"
let NUM              = "0123456789"
let ALPHA            = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
let ALPHANUM         = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

struct  PZXAppInfo {
    
    static let infoDictionary           = Bundle.main.infoDictionary
    static let appDisplayName: String   = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
    static let bundleIdentifier:String  = Bundle.main.bundleIdentifier! // Bundle Identifier
    static let appVersion:String        = Bundle.main.infoDictionary! ["CFBundleShortVersionString"] as! String// App 版本号
    static let buildVersion : String    = Bundle.main.infoDictionary! ["CFBundleVersion"] as! String //Bulid 版本号
    static let iOSVersion:String        = UIDevice.current.systemVersion //ios 版本
    static let identifierNumber         = UIDevice.current.identifierForVendor //设备 udid
    static let systemName               = UIDevice.current.systemName //设备名称
    static let model                    = UIDevice.current.model // 设备型号
    static let localizedModel           = UIDevice.current.localizedModel  //设备区域化型号

}

enum ErrorCode: Int {
    ///未知错误
    case Unkonwn =  -999
    ///解析错误
    case Analysis = -998
}

