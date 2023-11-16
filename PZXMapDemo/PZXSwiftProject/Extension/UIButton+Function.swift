//
//  UIView+Function.swift
//  xinyuancar
//
//  Created by 博识iOS One on 2020/11/25.
//

import Foundation

typealias BtnAction = (UIButton)->()




extension UIButton {
    
    func countDown(duration: Int, prefix: String?, suffix: String?, title: String?, bg: UIColor = .gray) {
        let prefixText = prefix ?? ""
        let suffixText = suffix ?? ""
        
        let color = self.backgroundColor
        
        let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.global())
        let startTime = Date().timeStampSecond
        codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))
        codeTimer.setEventHandler {
            let currentTime = Date().timeStampSecond
            let goTime = currentTime - startTime
            
            let count = duration - goTime
            
            if count <= 0 {
                codeTimer.cancel()
                DispatchQueue.main.async {
                    self.isEnabled = true
                    
                    self.backgroundColor = color
                    self.setTitle(title, for: .normal)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.setTitle("\(prefixText) \(count)S \(suffixText)", for: .normal)
            }
        }
        
        self.backgroundColor = bg
        self.setTitle("\(prefixText) \(duration)S \(suffixText)", for: .normal)
        
        self.isEnabled = false
        
        codeTimer.activate()
    }
    
    
    
    private struct AssociatedKeys{
           static var actionKey = "actionKey"
       }
    
    @objc dynamic var action: BtnAction? {
            set{
                objc_setAssociatedObject(self,&AssociatedKeys.actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
            }
            get{
                if let action = objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? BtnAction{
                    return action
                }
                return nil
            }
        }
    func DIY_button_add(action:@escaping  BtnAction) {
            self.action = action
            self.addTarget(self, action: #selector(touchUpInSideBtnAction), for: .touchUpInside)
        }
    
    @objc func touchUpInSideBtnAction(btn: UIButton) {
            if let action = self.action {
                action(self)
            }
       }

    
}
