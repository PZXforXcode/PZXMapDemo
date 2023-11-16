//
//  UIView+Extension.swift
//  GZProject
//
//  Created by quark on 2019/12/9.
//  Copyright © 2019 BZDGuanZi. All rights reserved.
//

import UIKit

extension UIView {
    
    var originX: CGFloat {
        get {
            return self.frame.origin.x
        }
        
        set {
            self.frame = CGRect(x: newValue, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var originY: CGFloat {
        get {
            return self.frame.origin.y
        }
        
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: newValue, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var frameMaxX: CGFloat {
        get {
            return self.frame.maxX
        }
        
        set {
            self.frame = CGRect(x: newValue - self.frame.size.width, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var frameMinX: CGFloat {
        get {
            return self.frame.minX
        }
        
        set {
            self.frame = CGRect(x: newValue, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var frameMidX: CGFloat {
        get {
            return self.frame.midX
        }
        
        set {
            self.frame = CGRect(x: newValue - self.frame.size.width*0.5, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var frameMaxY: CGFloat {
        get {
            return self.frame.maxY
        }
        
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: newValue - self.frame.size.height, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var frameMinY: CGFloat {
        get {
            return self.frame.minY
        }
        
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: newValue, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var frameMidY: CGFloat {
        get {
            return self.frame.midY
        }
        
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: newValue - self.frame.size.height*0.5, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var frameWidth: CGFloat {
        get {
            return self.frame.size.width
        }
        
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newValue, height: self.frame.size.height)
        }
    }
    
    var frameHeight: CGFloat {
        get {
            return self.frame.size.height
        }
        
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: newValue)
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.frame.midX
        }
        
        set {
            self.frame = CGRect(x: newValue - self.frame.size.width*0.5, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.frame.midY
        }
        
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: newValue - self.frame.size.height*0.5, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    
    func isContainSubView(subView: UIView) -> Bool {
        for view in self.subviews {
            if view.isEqual(subView) {
                return true
            }
        }
        return false
    }
    
    func viewRemoveFromSuperviewDelay(timeInterval: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval) {
            self.removeFromSuperview()
        }
    }
    
}
