//
//  PZXSwiftProject
//  UserModelData.swift
//  Created by pzx on 2021/7/6
//  
//  ***
//  *   GitHub:https://github.com/PZXforXcode
//  *   简书:https://www.jianshu.com/u/e2909d073047
//  *   qq:496912046
//  ***
        
let userModelFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/userModelData"

import Foundation

struct UserModel:Codable {
    /** 昵称*/
    var nickName: String = ""
    /** token*/
    var Token: String = ""
    /** 头像*/
    var avatarUrl: String = ""

    
//    private enum CodingKeys: String, CodingKey {
//        case name
//        case age
//        case sex
//        case weight
//        case work
//    }
    
    init(nickName: String = UserModelTool.CurrentUser()!.nickName, Token: String = UserModelTool.CurrentUser()!.Token, avatarUrl: String = UserModelTool.CurrentUser()!.avatarUrl) {
        self.nickName = nickName
        self.Token = Token
        self.avatarUrl = avatarUrl
    }
    
}

class UserModelTool {
    
    class func saveUser(_ user: UserModel) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            try data.write(to: URL(fileURLWithPath: userModelFilePath))
        }catch {
            
        }
    }
    
    class func CurrentUser() -> UserModel? {
        let decoder = JSONDecoder()
        let fileManager = FileManager.default
        guard let data = fileManager.contents(atPath: userModelFilePath) else {
            return nil
        }
        do {
            let user = try decoder.decode(UserModel.self, from: data)
            return user
        }catch {
            
        }
        return nil
    }
    
    class func ClearAllUserInfo() {
                
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(UserModel.init(nickName: "", Token: "", avatarUrl: ""))
            try data.write(to: URL(fileURLWithPath: userModelFilePath))
        }catch {
            
        }
    }
    
    class func isLogin() -> Bool {
        
        let token = UserModelTool.CurrentUser()?.Token ?? ""

        return !token.isEmpty
    }
}
