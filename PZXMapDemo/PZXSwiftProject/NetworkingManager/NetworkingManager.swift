//
//  NetworkingManager.swift
//  PZXSwiftProject
//
//  Created by 彭祖鑫 on 2021/5/27.
//

import Foundation
import Alamofire
import HandyJSON

typealias NetSuccessClosure = (_ baseModel: NetBaseModel?) -> Void
typealias NetFailedClosure = (_ error: NetworkingError) -> Void
typealias NetRequestClosure = (_ success: Bool, _ message: String ) -> Void

public func convertJSONToModel<T: Codable>(jsonObject: AnyObject, modelType: T.Type) -> T? {
     do {
         let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
         let decodedModel = try JSONDecoder().decode(modelType, from: jsonData)
         return decodedModel
     } catch {
         print("Error converting to JSON: \(error)")
         return nil
     }
 }

class NetworkingManager {

    
    public class func requestFunc(apiModel: inout APIModel, success: @escaping NetSuccessClosure, failure: @escaping NetFailedClosure) {
        
        let header = NetworkingManager.settingDefaultHttpHeaders(apiModel: apiModel)
        
        AF.request(apiModel.gettingFullUrl(), method: apiModel.requestConfig!.method, parameters: apiModel.paramDic, headers: nil).response { (response) in
            
            switch response.result {
            
            case .success(_):
           
                let json = String(data: response.data ?? Data(), encoding: .utf8) ?? ""
                
                let model = NetBaseModel.deserialize(from: json)
            

                if model != nil  {
                    
                    //暂时测试
                    success(model)
//                    if model!.code == .Success  || model!.code == .OtherSuccess {
//                        success(model)
//                    }else {
//                        failure(NetworkingError.init(code: model!.code.rawValue, localizedDescription: StringSafe(model?.message)))
//                    }
                }else {
                    failure(NetworkingError.init(code: ErrorCode.Analysis.rawValue, localizedDescription: Analysis_Error))
                }
            case let .failure(error):
                if error.isResponseSerializationError {
                    let json = String(data: response.data ?? Data(), encoding: .utf8) ?? ""
                    let model = NetBaseModel.deserialize(from: json)
                    if model != nil {
                        if model?.code == APICode.TokenExpire {//登录失效要单独处理
                            NetworkingManager.TokenExpire()
                        }else {
                            failure(NetworkingError.init(code: model!.code.rawValue, localizedDescription: model!.message))
                        }
                    }else {
                        var desError = NetworkingError.init(code: error.responseCode ?? ErrorCode.Analysis.rawValue, localizedDescription: error.localizedDescription)
                        _ = desError.desc()
                        failure(desError)
                    }
                }else {
                    if (error.responseCode != nil)  {
                        failure(NetworkingError.init(code: error.responseCode!, localizedDescription: NET_Connect_Error))
                    }else {
                        failure(NetworkingError.init(code: ErrorCode.Unkonwn.rawValue, localizedDescription: Unknown_Error))
                    }
                }
            }
        }
    }
    
    
    
    ///配置header
    private class func settingDefaultHttpHeaders(apiModel: APIModel) -> HTTPHeaders {
        var headers = HTTPHeaders.default
        
//        headers.update(name: "Authorization", value: "Bearer " + currentUser.userToken)
        headers.update(name: "cli-os", value: "ios")
        headers.update(name: "Accept", value: "application/json")
        headers.update(name: "Content_Type", value: "application/json")
        headers.update(name: "cli-version", value: PZXAppInfo.appVersion)
        headers.update(name: "cli-os-version", value: UIDevice.current.systemVersion)
        headers.update(name: "api-version", value: "1.0.0")//第一个版本默认1.0.0
        
        return headers
    }
    
    ///token失效需要重新登录
    public class func TokenExpire() {
    
    }
}
