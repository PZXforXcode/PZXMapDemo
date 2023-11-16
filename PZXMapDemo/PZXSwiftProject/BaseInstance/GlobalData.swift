//
//  PZXSwiftProject
//  GlobalData.swift
//  Created by pzx on 2021/7/6
//  
//  ***
//  *   GitHub:https://github.com/PZXforXcode
//  *   简书:https://www.jianshu.com/u/e2909d073047
//  *   qq:496912046
//  ***
        

import Foundation
import UIKit


class GlobalData: BaseViewModel {
    
    static let shared = GlobalData()
    
    /** 全局请求是否成功*/
    var isSuccessRequest: Bool          = false
    /** 是否出现登录页面（防止出现多个登录页*/
    var isShowLoginVC: Bool             = false
    /** 金币任务是否开启*/
    var isOpenGoladTaskMoudles: Bool    = false
    /** App开屏广告开关是否开启*/
    var isOpenSplash: Bool              = false
    /** 实名认证是否开启*/
    var isOpenPeopleAuth: Bool          = false
    /** CCT任务是否开启*/
    var isOpenCCTTask: Bool             = false
    /** 广告间隔数量*/
    var advertisingIntervalNumber: Int  = 10
    /** 新闻详情停留时长（单位 秒）*/
    var newsDetailWaitingTime: Int      = 10
    /** 任务H5地址*/
    var cctWebUrl: String               = ""
    
    
    ///加载登录界面
    class func loadingLoginViewController(handler: @escaping PZXClosure) {
        if GlobalData.shared.isShowLoginVC == true {
            return
        }
        
        GlobalData.shared.isShowLoginVC = true
        let vc                      = ViewController.init()
        let nav                     = UINavigationController.init(rootViewController: vc)
        nav.modalPresentationStyle  = .fullScreen
        
        let transition              = CATransition.init()
        transition.duration         = 0.4
        transition.timingFunction   = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.subtype          = .fromLeft
        transition.type             = CATransitionType(rawValue: "oglFlip")
        
        PZXKeyController().view.window?.layer.add(transition, forKey: "animation")
        PZXKeyController().present(nav, animated: false) {
            handler()
        }
    }
    
    
    ///登录成功跳转
    class func LoginSuccessViewController(handler: @escaping PZXClosure) {

        
        let transition              = CATransition.init()
        transition.duration         = 0.4
        transition.timingFunction   = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.subtype          = .fromLeft
        transition.type             = CATransitionType(rawValue: "oglFlip")
        
        PZXKeyController().view.window?.layer.add(transition, forKey: "animation")
        PZXKeyController().dismiss(animated: true, completion: {
            
            GlobalData.shared.isShowLoginVC = false
            handler()

        })

    }
    
    required init() {}
}




//MARK: =====================网络请求方法=====================
extension GlobalData {
    //MARK:获取全局配置
    class func gettingCommonConfiguration (request: @escaping NetRequestClosure) {
        var apiModel = APIModel(requestConfig: configurationAPI)
        
        NetworkingManager.requestFunc(apiModel: &apiModel) { (requestModel) in
            
            let jsonData = requestModel?.swiftJsonData()
            
            GlobalData.shared.isOpenGoladTaskMoudles            = jsonData!["opens"]["gold_task"].boolValue
            GlobalData.shared.isOpenSplash                      = jsonData!["opens"]["open_app"].boolValue
            GlobalData.shared.isOpenCCTTask                     = jsonData!["opens"]["cct_switch"].boolValue
            GlobalData.shared.isOpenPeopleAuth                  = jsonData!["opens"]["real_name"].boolValue
            GlobalData.shared.advertisingIntervalNumber         = jsonData!["news"]["advertising_interval_number"].intValue
            GlobalData.shared.newsDetailWaitingTime             = jsonData!["news"]["news_detail_waiting_time"].intValue
            GlobalData.shared.cctWebUrl                         = jsonData!["cct"]["web_url"].stringValue

            request(true,NET_Request_Success)
        } failure: { (failureError) in
            GlobalData.shared.isOpenGoladTaskMoudles = false
            request(false,failureError.localizedDescription)
        }

    }
}
