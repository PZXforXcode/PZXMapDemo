//
//  PZXSwiftProject
//  ServerTableViewCell.swift
//  Created by pzx on 2021/7/6
//  
//  ***
//  *   GitHub:https://github.com/PZXforXcode
//  *   简书:https://www.jianshu.com/u/e2909d073047
//  *   qq:496912046
//  ***
        

import UIKit

class ServerTableViewCell: UITableViewCell {

    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
