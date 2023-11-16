//
//  String+Extension.swift
//  GZProject
//
//  Created by quark on 2019/12/9.
//  Copyright © 2019 BZDGuanZi. All rights reserved.
//

import UIKit

extension String {
    
    func pzx_SubString(to index: Int) -> String {
        return String(self[..<self.index(self.startIndex, offsetBy: index)])
    }
    
    func matchRegex(regular: String) -> Bool {
        return matchRegex(regular: regular, text: self, range: NSRange(location: 0, length: self.count))
    }
    
    func matchRegex(regular: String,text: String,range:NSRange) -> Bool {
        let regex = try? NSRegularExpression.init(pattern: regular, options: [])
        if let results = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)), results.count != 0 {
            return true
        }else {
            return false
        }
    }
    
    func isEnglishFirst() -> Bool {
        let regular = "[a-z,A-Z]{1}"
        return matchRegex(regular: regular, text: self, range: NSRange(location: 0, length: self.count))
    }
    
    func isEnglishAndNumber() -> Bool {
        let regular = "^[a-zA-Z0-9]+$"
        return matchRegex(regular: regular, text: self, range: NSRange(location: 0, length: self.count))
    }
    
    func isHaveChinese() -> Bool {
        let nsString = self as NSString
        if nsString.length != 0 {
            for i in 0...self.count-1 {
                let a = nsString.character(at: i)
                if a > 0x4E00 && a < 0x9FFF {
                    
                    return true
                }
            }
        }
        return false
    }
    
    // base64编码
    func toBase64() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    // base64解码
    func fromBase64() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    //计算字符串适应Laebl大小
    func calculatSize(font: UIFont, boundSize: CGSize) -> CGSize {
        let string = self as NSString
        let attributes = [NSAttributedString.Key.font : font] as [NSAttributedString.Key : Any]
        let boundingRect = string.boundingRect(with: boundSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return boundingRect.size;
    }
    
}
