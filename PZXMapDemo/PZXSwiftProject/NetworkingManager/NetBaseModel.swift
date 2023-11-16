//
//  NetBaseModel.swift
//  PZXSwiftProject
//
//  Created by 彭祖鑫 on 2021/5/27.
//

import Foundation
import HandyJSON
import SwiftyJSON

class NetBaseModel: HandyJSON {
    
    var code: APICode = .Undefine
    
    var message: String = ""
    
    var data: AnyObject?

    
    //测试数据
    var reason: String = ""
    var result: AnyObject?

    required init() {}
    
    func swiftJsonData() -> JSON {
        guard self.data != nil else {
            return JSON("")
        }
        let json = try! JSONSerialization.data(withJSONObject: self.data!, options: .prettyPrinted)
        return JSON(json)
    }
    
    //测试数据
    func swiftJsonDatatest() -> JSON {
        guard self.result != nil else {
            return JSON("")
        }
        let json = try! JSONSerialization.data(withJSONObject: self.result!, options: .prettyPrinted)
        return JSON(json)
    }
}
