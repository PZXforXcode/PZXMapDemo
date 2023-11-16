//
//  PZXSwiftProject
//  MainTabBarControllerViewController.swift
//  Created by pzx on 2021/7/6
//
//  ***
//  *   GitHub:https://github.com/PZXforXcode
//  *   简书:https://www.jianshu.com/u/e2909d073047
//  *   qq:496912046
//  ***
        

import UIKit

class MainTabBarControllerViewController: UITabBarController,UITabBarControllerDelegate {

    
//    convenience init() {
//        
//        let ServerStoryboard: UIStoryboard = UIStoryboard(name: "ServerViewController", bundle: nil)
//        
//        let homePageVC              = HomePageViewController()//首页
//        let ServerVC           = ServerStoryboard.instantiateViewController(withIdentifier: "ServerViewController") as! ServerViewController//快讯
//        let CarVC                = CarViewController()//行情
//        let MineVC              = MineViewController()//个人中心
//        
//        let homePageNavVC = UINavigationController.init(rootViewController: homePageVC)
//        let ServerNavVC = UINavigationController.init(rootViewController: ServerVC)
//        let CarNavVC = UINavigationController.init(rootViewController: CarVC)
//        let MineNavVC = UINavigationController.init(rootViewController: MineVC)
//        
//        homePageNavVC.tabBarItem.title = "首页"
//        homePageNavVC.tabBarItem.image = UIImage.init(named: "首页未选中")
//        homePageNavVC.tabBarItem.selectedImage = UIImage.init(named: "首页选中")
//        
//        ServerNavVC.tabBarItem.title = "二页"
//        ServerNavVC.tabBarItem.image = UIImage.init(named: "二页未选中")
//        ServerNavVC.tabBarItem.selectedImage = UIImage.init(named: "二页选中")
//        
//        CarNavVC.tabBarItem.title = "三页"
//        CarNavVC.tabBarItem.image = UIImage.init(named: "三页未选中")
//        CarNavVC.tabBarItem.selectedImage = UIImage.init(named: "三页选中")
//        
//        MineNavVC.tabBarItem.title = "四页"
//        MineNavVC.tabBarItem.image = UIImage.init(named: "四页未选中")
//        MineNavVC.tabBarItem.selectedImage = UIImage.init(named: "四页选中")
//        
//        let viewControllers = [homePageNavVC,ServerNavVC,CarNavVC,MineNavVC]
//
//        self.init()
//    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    
    //MARK: ==============UITabBarControllerDelegate==============
     func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        let nav = viewController as! UINavigationController

//        if (nav.viewControllers.first?.isKind(of: CarViewController.classForCoder()) == true) && (UserModelTool.isLogin() == false) {
//            
//            UtilTool.showAlertView("提示", setMsg: "当前没有登陆账号，是否去登陆", leftButtonTitle: "去登录", leftStyle:UIAlertAction.Style.default, rightButtonTitle: "不了", rightStyle: .default, vc: self) {
//                
//                GlobalData.loadingLoginViewController {
//
//                }
//                
//            } rightbuttonBlock: {
//                
//            }
//       
//            return false
//        }

        return true
    }
    
}



