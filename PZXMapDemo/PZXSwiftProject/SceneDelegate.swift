//
//  SceneDelegate.swift
//  WidgetPlay
//
//  Created by pzx on 2023/4/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // 将窗口设置为应用程序的窗口对象
         if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
             appDelegate.window = window
         }
        
        settingRootViewController(window: window)

        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//            print("URLContexts: \(URLContexts)")
            print("URL0: \(URLContexts.first!.url)")
    }

}

extension SceneDelegate {
    
    //MARK: 设置根控制器
    func settingRootViewController(window:UIWindow) {
        
        window.backgroundColor = .white
        
//        let ServerStoryboard: UIStoryboard = UIStoryboard(name: "ServerViewController", bundle: nil)
        
        let homePageVC              = HomePageViewController()//首页
        let ServerVC           = MapViewController()//快讯
        let CarVC                = CarViewController()//行情
        let MineVC              = MineViewController()//个人中心
        
        let homePageNavVC = UINavigationController.init(rootViewController: homePageVC)
        let ServerNavVC = UINavigationController.init(rootViewController: ServerVC)
        let CarNavVC = UINavigationController.init(rootViewController: CarVC)
        let MineNavVC = UINavigationController.init(rootViewController: MineVC)
        
        homePageNavVC.tabBarItem.title = "首页"
        homePageNavVC.tabBarItem.image = UIImage.init(named: "首页未选中")
        homePageNavVC.tabBarItem.selectedImage = UIImage.init(named: "首页选中")
        
        ServerNavVC.tabBarItem.title = "二页"
        ServerNavVC.tabBarItem.image = UIImage.init(named: "二页未选中")
        ServerNavVC.tabBarItem.selectedImage = UIImage.init(named: "二页选中")
        
        CarNavVC.tabBarItem.title = "三页"
        CarNavVC.tabBarItem.image = UIImage.init(named: "三页未选中")
        CarNavVC.tabBarItem.selectedImage = UIImage.init(named: "三页选中")
        
        MineNavVC.tabBarItem.title = "四页"
        MineNavVC.tabBarItem.image = UIImage.init(named: "四页未选中")
        MineNavVC.tabBarItem.selectedImage = UIImage.init(named: "四页选中")
        
        let viewControllers = [homePageNavVC,ServerNavVC,CarNavVC,MineNavVC]
        
        let tabBarController = MainTabBarControllerViewController.init()
        tabBarController.setViewControllers(viewControllers, animated: true);
//        tabBarController.viewControllers = viewControllers;
        tabBarController.selectedIndex = 0
        
        settingCustomizeInterface()
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
        
    }
    //MARK: 设置标签栏样式
    func settingCustomizeInterface() {
        
        let selectColor = UIColor.red
        let unselectColor = UIColor.black
//        let tabbarBackgroundColor = UIColor.qmui_color(withHexString: "#84C9EF")
        let tabbarBackgroundColor = UIColor.white

        //iOS13以上设置
        if #available(iOS 13.0, *) {
            let tabBar13 = UITabBar.appearance()
            let appearance = UITabBarAppearance.init()
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.alignment = .center
            
            let normal = appearance.stackedLayoutAppearance.normal
            normal.titleTextAttributes = [NSAttributedString.Key.font: 15]
            
            let select = appearance.stackedLayoutAppearance.selected
            select.titleTextAttributes = [NSAttributedString.Key.font: 15]
            
            tabBar13.unselectedItemTintColor = unselectColor
            tabBar13.tintColor = selectColor
            //这里设置颜色
            tabBar13.backgroundColor = tabbarBackgroundColor
            
            
            
        }else {
            let normal = [NSAttributedString.Key.font: 15,NSAttributedString.Key.foregroundColor: unselectColor] as [NSAttributedString.Key : Any]
            let select = [NSAttributedString.Key.font: 15,NSAttributedString.Key.foregroundColor: selectColor] as [NSAttributedString.Key : Any]
            
            let tabBar = UITabBarItem.appearance()
            tabBar.setTitleTextAttributes(normal, for: .normal)
            tabBar.setTitleTextAttributes(select, for: .selected)
        }
        
        
        if #available(iOS 14.0, *) {
            
            print("2")

            let tabBar13 = UITabBar.appearance()
            
            let appearnce = UITabBarAppearance()
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : unselectColor
            ]
            itemAppearance.selected.titleTextAttributes =  [
                NSAttributedString.Key.foregroundColor : selectColor
            ]
            appearnce.stackedLayoutAppearance = itemAppearance
            appearnce.configureWithOpaqueBackground()
            appearnce.backgroundColor = tabbarBackgroundColor
            tabBar13.standardAppearance = appearnce
            if #available(iOS 15.0, *) {
                tabBar13.scrollEdgeAppearance = appearnce
            } else {
                // Fallback on earlier versions
            }
            
        }
        
        
    }
    
}
