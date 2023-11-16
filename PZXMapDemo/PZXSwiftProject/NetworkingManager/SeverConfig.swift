//
//  SeverConfig.swift
//  PZXSwiftProject
//
//  Created by 彭祖鑫 on 2021/5/27.
//

import Foundation

let TEST = 0 //1为测试服 0为正式服
//MARK:================域名================
var baseSeverUrlString: String {
    get {
        if TEST == 1 {//1是测试环境  0 是正式环境
            return "https://headline.dev3.chongqingcangzhou.com"
        }else {
            return "https://api.lxtoutiao.com"
        }
    }
}

//MARK:================接口地址================
let configurationAPI        = NetConfig(name: "获取全局配置",
                                          path: "/api/open-app/configs",
                                          method: .get)

let phoneTypeLoginAPI       = NetConfig(name: "手机账号密码登录",
                                          path: "/api/login",
                                          method: .post)

let listTestAPi       = NetConfig(name: "列表测试",
                                          path: "http://apis.juhe.cn/fapig/nba/query",
                                          method: .post)
