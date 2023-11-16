//
//  PZXSwiftProject
//  ServerViewController.swift
//  Created by pzx on 2021/7/6
//  
//  ***
//  *   GitHub:https://github.com/PZXforXcode
//  *   简书:https://www.jianshu.com/u/e2909d073047
//  *   qq:496912046
//  ***
        

import UIKit
import SwiftyJSON
import Kingfisher

class ServerViewController: RootViewController {

    @IBOutlet weak var testTableView: UITableView!
    @IBOutlet weak var topEdge: NSLayoutConstraint!
//    var pCNBAMatch : PCNBAMatch?

    var dataSource:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = RandomColor();

        self.topEdge.constant = NAVIGATION_HEIGHT
        // Do any additional setup after loading the view.
            getData()


    }
    
    func getData() {
        
        var apiModel = APIModel(requestConfig: listTestAPi,paramDic: ["key":"c1b594e8250a0097cdfdd90b89c53db9"],flag: true)
        
        NetworkingManager.requestFunc(apiModel: &apiModel) { (requestModel) in
            
            self.view.hideAllToasts()
            self.view.makeToast(requestModel?.reason, duration: 1.5, position: CSToastPositionBottom)
            
            
//            if let anyObject = requestModel?.result {
//                    if let convertedModel = convertJSONToModel(jsonObject: anyObject, modelType: PCNBAMatch.self) {
//                        self.pCNBAMatch = convertedModel
//                        self.testTableView.reloadData()
//                    }
//                }


        } failure: { (failureError) in
            
            
        }
        
    }
    

}

extension ServerViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return self.dataSource["matchs"].array?.count ?? 0
        return  0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerTableViewCell") as! ServerTableViewCell
//        cell.rightLabel.text = StringSafe(dataSource["matchs"][indexPath.row]["date"].string)
        cell.rightLabel.text = ""
        let url = URL.init(string:"https://img1.baidu.com/it/u=1852955231,3943566939&fm=26&fmt=auto&gp=0.jpg")
        cell.leftImageView.kf.setImage(with: url,placeholder: nil)
        cell.leftImageView.contentMode = .scaleAspectFit
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    
}
