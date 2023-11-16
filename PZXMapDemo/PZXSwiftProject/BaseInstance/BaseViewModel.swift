//
//  PZXSwiftProject
//  BaseViewModel.swift
//  Created by pzx on 2021/7/6
//  
//  ***
//  *   GitHub:https://github.com/PZXforXcode
//  *   简书:https://www.jianshu.com/u/e2909d073047
//  *   qq:496912046
//  ***
        
import UIKit
import RxSwift
import RxCocoa
import HandyJSON

import Foundation

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

class BaseViewModel: HandyJSON {
    
    let disposeBag = DisposeBag()
 
    required init() {
        
    }
    
    public func mapping(mapper: HelpingMapper) {

    }
}

///MARK: inputAvailable
extension BaseViewModel {
    class func phoneNumberAvailable(_ phoneNum: String) -> Observable<Bool> {
        if phoneNum.isHaveChinese() == false && phoneNum.matchRegex(regular: "^1[0-9]{10}$") {
            return Observable.just(true)
        }else {
            return Observable.just(false)
        }
    }
    
    class func passwordAvailable(_ pwd: String) -> Observable<Bool> {
        if pwd.isHaveChinese() == false {
            return Observable.just(true)
        }else {
            return Observable.just(false)
        }
    }
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
    
    var notFailed: Bool {
        switch self {
        case .ok:
            return true
        case .empty:
            return true
        default:
            return false
        }
    }
    
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case .validating:
            return "正在输入"
        case let .failed(message):
            return message
        }
    }
}

