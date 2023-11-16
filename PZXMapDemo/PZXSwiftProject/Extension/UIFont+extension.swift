//
//  UIFont+extension.swift
//  xinyuancar
//
//  Created by 博识iOS One on 2020/11/20.
//  Copyright © 2020 博识iOS One. All rights reserved.
//

import UIKit

extension UIFont {
    
    public enum PingFangSCFontStyle {
        case Medium
        case Regular
        case Semibold
    }
    
    static func PingFangFont(size: CGFloat, style: UIFont.PingFangSCFontStyle = .Medium) -> UIFont {
        switch style {
            case .Regular:
                return PingFang_SC_Regular_Font(size: size)
            case .Semibold:
                return PingFang_SC_Semibold_Font(size: size)
            default:
                return PingFang_SC_Medium_Font(size: size)
        }
    }
    
    //MARK: - 字体
    static func PingFang_SC_Medium_Font(size: CGFloat) -> UIFont {
        return UIFont.init(name: "PingFang-SC-Medium", size: size)!
    }
    
    static func PingFang_SC_Regular_Font(size: CGFloat) -> UIFont {
        return UIFont.init(name: "PingFang-SC-Regular", size: size)!
    }
    
    static func PingFang_SC_Semibold_Font(size: CGFloat) -> UIFont {
        return UIFont.init(name: "PingFang-SC-Semibold", size: size)!
    }
}
