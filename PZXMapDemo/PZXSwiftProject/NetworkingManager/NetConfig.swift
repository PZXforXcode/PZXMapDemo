//
//  NetConfig.swift
//  PZXSwiftProject
//
//  Created by 彭祖鑫 on 2021/5/27.
//

import Foundation
import Alamofire
import HandyJSON

enum APICode: Int, HandyJSONEnum {
    ///成功
    case Success                = 00
    ///成功
    case OtherSuccess           = 200
    ///Token失效
    case TokenExpire            = 401
    ///接口问题（未发版之类的）
    case UrlVersion             = 403
    ///未知接口
    case UrlEmpty               = 404
    ///权限问题
    case Access                 = 500
    /// 未知状态
    case Unknown                =  -999
    /// 未定义
    case Undefine               = -998
}

struct NetConfig {
    var name: String = ""//接口描述
    var baseURL: String = baseSeverUrlString//基础域名
    var path: String = ""//接口地址
    var method: HTTPMethod//请求方法
    
    init(name: String = "", baseUrl: String = baseSeverUrlString, path: String, method: HTTPMethod) {
        self.name = name
        self.baseURL = baseUrl
        self.path = path
        self.method = method
    }

    ///修改接口，有些变化的参数会直接拼接在地址里
    mutating func changePath(newingPath: String) {
        self.path = newingPath
    }
}


struct APIModel {
    var requestConfig: NetConfig?  //请求配置信息
    var paramDic: Dictionary<String, String> = Dictionary() //请求体参数
    var flag: Bool = false//true代表直接使用path 不要拼接头,默认为false
    
    init(requestConfig: NetConfig, paramDic: Dictionary<String, String> = Dictionary(), flag: Bool = false) {
        self.requestConfig = requestConfig
        self.paramDic = paramDic
        self.flag = flag
    }
    
    mutating func gettingFullUrl() -> String {
        if self.flag == false {
            
            return requestConfig!.baseURL+requestConfig!.path
        }else {
            
            print(requestConfig!.path)
            
            return requestConfig!.path
        }
    }
}

struct NetworkingError: HandyJSON {
    /// 错误码
    var code: Int = -1
    /// 错误描述
    var localizedDescription: String = ""
    
    mutating func desc() -> String {
        var desc = "⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️\n"
        
        if code == APICode.Access.rawValue {
            desc.append(self.localizedDescription)
            self.localizedDescription = NET_Request_Error
        }else if code == APICode.UrlVersion.rawValue {
            desc.append(self.localizedDescription)
            self.localizedDescription = NET_Request_Error
        }else {
            if self.localizedDescription.count > 30 {
                desc = ERROR_ALAERT+"\n"+self.localizedDescription+"\n" + ERROR_ALAERT
                self.localizedDescription = NET_Request_Error
                return desc
            }
        }
        
        desc.append("\n⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️")
        return desc
    }

}
