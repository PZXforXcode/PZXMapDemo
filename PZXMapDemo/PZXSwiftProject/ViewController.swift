//
//  ViewController.swift
//  PZXSwiftProject
//
//  Created by 彭祖鑫 on 2021/5/27.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("AppVersion" + PZXAppInfo.appVersion);
        self.navigationController?.navigationBar.isHidden = true
        
        let Label = UILabel.init(frame: CGRect.init(x: 20, y: 20, width: 200, height: 100))
        Label.text = "我是登录页-点击屏幕任意地方模拟登录"
        self.view .addSubview(Label)

//        self.view.backgroundColor = UIColor.qmui_color(withHexString: "")
        
        
        let button = UIButton.init(type: .custom)
        button.frame = CGRect.init(x: 100, y: 300, width: 100, height: 44)
        button.setTitle("不登录进入", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(noLoginButtonPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
        
    }


    @objc func noLoginButtonPressed(sender : UIButton) {
        
        GlobalData.LoginSuccessViewController {
            
        }
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //明天来弄这里
        let data =  UserModel.init(nickName: "pzx", Token: "1112121", avatarUrl: "test")
        UserModelTool.saveUser(data)
        
        let data2 = UserModel.init(avatarUrl: "test12321312")
        UserModelTool.saveUser(data2)
        
        GlobalData.LoginSuccessViewController {
            
            
            let window = UIApplication.shared.keyWindow
            window!.makeToast("登陆成功", duration: 1.5, position:CSToastPositionBottom)
            
        }
    }
}

