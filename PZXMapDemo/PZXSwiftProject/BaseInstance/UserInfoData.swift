//
//  PZXSwiftProject
//  UserInfoData.swift
//  Created by pzx on 2021/7/6
//  
//  ***
//  *   GitHub:https://github.com/PZXforXcode
//  *   简书:https://www.jianshu.com/u/e2909d073047
//  *   qq:496912046
//  ***
        

import UIKit
import HandyJSON
import RxSwift
import RxCocoa

import Foundation

let CURRENT_USER = "CurrentUser"

var currentUser: UserInfo {
    get {
        let info = StringSafe(UserDefaults.standard.object(forKey: CURRENT_USER))
        if info.count != 0 {
            return UserInfo.deserialize(from: info)!
        }else {
            let user = UserInfo.init()
            
            //序列化
            let info = user.toJSONString(prettyPrint: true)
            
            UserDefaults.standard.setValue(info, forKey: CURRENT_USER)
            UserDefaults.standard.synchronize()
            
            return user
        }
    }
}

class UserInfo: HandyJSON{
    
    /** 是否登录*/
    var isLogin                 = false

    /** 是否是新注册用户*/
    var isNewRegister           = false
    /** 是否实名（1是 0否）*/
    var isNameVerified          = false
    /** Token*/
    var userToken               = ""
    /** 用户ID*/
    var userID                  = ""
    /** 用户昵称*/
    var userNickname            = ""
    /** 用户头像*/
    var avatarUrl               = ""
    /** 邀请注册地址*/
    var inviteUrl               = ""
    /** 邀请码*/
    var inviteCode              = ""
    

    required init() {}
    
    class func saveUserInfo(user: UserInfo) {
        let info = user.toJSONString(prettyPrint: true)
        UserDefaults.standard.setValue(info, forKey: user.userID)
        UserDefaults.standard.synchronize()
    }
    
    //不允许多账号的情况下只用这个就行
    class func saveCurrentUserInfo() {
        let info = currentUser.toJSONString(prettyPrint: true)
        
        UserDefaults.standard.setValue(info, forKey: CURRENT_USER)
        UserDefaults.standard.synchronize()
    }
}

