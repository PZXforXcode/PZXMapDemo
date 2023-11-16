//
//  String+Field.swift
//  xinyuancar
//
//  Created by 博识iOS One on 2020/11/25.
//

import Foundation
import CommonCrypto

extension String {
    /// 正则匹配手机号
    var isMobile: Bool {
        /**
         * 手机号码
         * 移动：134 135 136 137 138 139 147 148 150 151 152 157 158 159  165 172 178 182 183 184 187 188 198
         * 联通：130 131 132 145 146 155 156 166 171 175 176 185 186
         * 电信：133 149 153 173 174 177 180 181 189 199
         * 虚拟：170
         */
        return isMatch("^(1[3-9])\\d{9}$")
    }
    
    /// 正则匹配用户身份证号15或18位
    var isUserIdCard: Bool {
        return isMatch("(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)")
    }
    
    /// 正则匹配用户密码6-18位数字和字母组合
    var isPassword: Bool {
        return isMatch("^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,14}")
    }
    
    /// 正则匹配URL
    var isURL: Bool {
        return isMatch("^[0-9A-Za-z]{1,50}")
    }
    
    /// 正则匹配用户姓名,20位的中文或英文
    var isUserName: Bool {
        return isMatch("^[a-zA-Z\\u4E00-\\u9FA5]+$")
    }
    
    /// 正则匹配用户email
    var isEmail: Bool {
        return isMatch("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
    }
    
    /// 判断是否都是数字
    var isNumber: Bool {
        return isMatch("^[0-9]*$")
    }
    
    /// 车架号
    var isFrame: Bool {
        return isMatch("^[A-Z0-9]+$")
    }
    
    /// 是中午输入键盘
    var isChineseKeyBoard: Bool {
        return isMatch("^[➋➌➍➎➏➐➑➒]+$")
    }
    
    /// 正则匹配车牌号
    var isLicenseNumber: Bool {
        return isMatch("^(([京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z](([0-9]{5}[DF])|([DF]([A-HJ-NP-Z0-9])[0-9]{4})))|([京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z][A-HJ-NP-Z0-9]{4}[A-HJ-NP-Z0-9挂学警港澳使领]))$")
    }
    
    /// 只能输入由26个英文字母组成的字符串
    var isLetter: Bool {
        return isMatch("^[A-Za-z]+$")
    }
    
    var isLowerLette: Bool {
        return isMatch("^[a-z]+$")
    }
    
    var isUpperLette: Bool {
        return isMatch("^[A-Z]+$")
    }
    
    var isLetterAndNumber: Bool {
        return isMatch("^[0-9A-Za-z]+$")
    }
    
    private func isMatch(_ pred: String ) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", pred)
        let isMatch: Bool = pred.evaluate(with: self)
        return isMatch
    }
    
    var utf8Encoded: Data? {
        return self.data(using: String.Encoding.utf8)
    }
    
    var existWhiteSpace: Bool {
        if let _ = self.range(of: " ") {
            return true
        }
        return false
    }
    
    var existNumberOrLetter: Bool {
        if let _ = self.rangeOfCharacter(from: .alphanumerics) {
            return true
        }
        return false
    }
}

extension String {
    func replacePriceString() -> String {
        return self.replacingOccurrences(of: ".00", with: "")
    }
}

extension String {
    //使用正则表达式替换
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: digestLen)
        
        return String(format: hash as String)
    }
}
